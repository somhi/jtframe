/*  This file is part of JTFRAME.
    JTFRAME program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTFRAME program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTFRAME.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 20-11-2022 */

module jtframe_lfbuf_ddr_ctrl #(parameter
    CLK96   =   0,   // assume 48-ish MHz operation by default
    VW      =   8,
    HW      =   9
)(
    input               rst,    // hold in reset for >150 us
    input               clk,
    input               pxl_cen,

    input               lhbl,
    input               ln_done,
    input      [VW-1:0] vrender,
    input      [VW-1:0] ln_v,
    input               vs,
    // data written to external memory
    input               frame,
    output reg [HW-1:0] fb_addr,
    input      [  15:0] fb_din,
    output reg          fb_clr,
    output reg          fb_done,

    // data read from external memory to screen buffer
    // during h blank
    output     [  15:0] fb_dout,
    output reg [HW-1:0] rd_addr,
    output reg          line,
    output reg          scr_we,

    output              ddram_clk,
    input               ddram_busy,
    output      [7:0]   ddram_burstcnt,
    output reg [31:3]   ddram_addr,
    input      [63:0]   ddram_dout,
    input               ddram_dout_ready,
    output reg          ddram_rd,
    output     [63:0]   ddram_din,
    output      [7:0]   ddram_be,
    output reg          ddram_we,

    // Status
    input       [7:0]   st_addr,
    output reg  [7:0]   st_dout
);

reg    [ 3:0] st;
reg    [ 1:0] cntup; // use a larger count to capture data using Signal Tap
wire   [ 7:0] vram; // current row (v) being processed through the external RAM
reg  [HW-1:0] hblen, hlim, hcnt;
reg           lhbl_l, do_wr, do_rd, startup, readyl,
              ln_done_l, vsl, brstin, busyl;
reg           ddram_wait;
wire          fb_over;
wire          rding, wring;

localparam [3:0] IDLE       = { 2'd0, 2'd0 }, // h0
                 WRITE_WAIT = { 2'd1, 2'd1 }, // h5
                 WRITEOUT   = { 2'd1, 2'd2 }, // h6
                 READ_WAIT  = { 2'd2, 2'd1 }, // h9
                 READIN     = { 2'd2, 2'd2 }; // ha

localparam AW = HW+VW;

assign {rding, wring} = st[3-:2];
assign ddram_be       = 8'h3; // only use lower 16 bits
assign ddram_burstcnt = 8'h80;
assign fb_dout        = ddram_dout[15:0];
assign ddram_din      = { 48'd0, fb_din };
assign ddram_clk      = clk;
assign fb_over        = &fb_addr;
assign vram           = lhbl ? ln_v : vrender;

always @(posedge clk) begin
    readyl <= ddram_dout_ready;
    busyl  <= ddram_busy;
    case( st_addr[2:0] )
        0: st_dout <= { brstin, 3'd0,
                        st };
        1: st_dout <= { 3'd0, ddram_busy, 3'd0,ddram_dout_ready };
        2: st_dout <= { 3'd0, ddram_we, 3'd0, ddram_rd };
        3: st_dout <= rd_addr[7:0];
        4: st_dout <= fb_addr[7:0];
        5: st_dout <= {3'd0, busyl, 3'd0, readyl };
        default: st_dout <= 0;
    endcase
end

always @( posedge clk, posedge rst ) begin
    if( rst ) begin
        hblen  <= 0;
        hlim   <= 0;
        hcnt   <= 0;
        lhbl_l <= 0;
        cntup  <= 0;
        startup<= 0;
    end else if(pxl_cen) begin
        lhbl_l  <= lhbl;
        vsl     <= vs;
        hcnt    <= hcnt+1'd1;
        startup <= &cntup;
        if( ~lhbl & lhbl_l ) begin // enters blanking
            hcnt   <= 0;
            hlim   <= hcnt - hblen; // H limit below which we allow do_wr events
        end
        if( lhbl & ~lhbl_l ) begin // leaves blanking
            hblen <= hcnt;
        end
        if( vs & ~vsl & ~&cntup ) cntup <= cntup+1'd1;
    end
end

always @( posedge clk, posedge rst ) begin
    if( rst ) begin
        do_wr <= 0;
    end else begin
        ln_done_l <= ln_done;
        if( ln_done & ~ln_done_l    ) do_wr <= 1;
        if( st==WRITEOUT && fb_over ) do_wr <= 0;
    end
end

always @( posedge clk, posedge rst ) begin
    if( rst ) begin
        st         <= IDLE;
        ddram_we   <= 0;
        ddram_rd   <= 0;
        ddram_addr <= 0;
        fb_addr    <= 0;
        fb_clr     <= 0;
        fb_done    <= 1;
        rd_addr    <= 0;
        scr_we     <= 0;
        line       <= 0;
        do_rd      <= 0;
        brstin     <= 0;
        ddram_wait <= 0;
    end else if(startup) begin
        fb_done <= 0;
        ddram_wait <= ddram_wait>>1;
        if (lhbl_l & ~lhbl & ~rding) do_rd <= 1;
        if( fb_clr ) begin
            // the line is cleared outside the state machine so a
            // read operation can happen independently
            fb_addr <= fb_addr + 1'd1;
            if( fb_over ) begin
                fb_clr  <= 0;
            end
        end
        if( !ddram_busy && !ddram_wait) begin
            ddram_rd <= 0;
            case( st )
                IDLE: begin
                    ddram_addr <= 0;
                    // ddram_addr[3+:1+HW+VW] <= { lhbl ^ frame, vram, {HW{1'b0}} };
                    scr_we    <= 0;
                    if( do_rd ) begin
                        // it doesn't matter if vrender changes after the LHBL edge
                        ddram_rd   <= 1;
                        ddram_wait <= ~0;
                        rd_addr    <= 0;
                        do_rd      <= 0;
                        scr_we     <= 1;
                        brstin     <= 0;
                        st         <= READIN;
                    end
                    else if( do_wr && !fb_clr && hcnt<hlim && lhbl ) begin
                        // do not start too late so it doesn't run over H blanking
                        ddram_we   <= 1;
                        ddram_wait <= ~0;
                        fb_addr    <= 0;
                        st         <= WRITEOUT;
                    end
                end
        ////////////// Write line from internal BRAM to PSRAM
                WRITE_WAIT: begin
                    st       <= WRITEOUT;
                    ddram_we <= 1;
                    ddram_wait <= ~0;
                    ddram_addr[3+:HW] <= fb_addr;
                end
                WRITEOUT: begin
                    fb_addr  <= fb_addr + 1'd1;
                    if( &fb_addr[6:0] ) begin
                        st  <= fb_over /* full line read */ ? IDLE : WRITE_WAIT;
                        ddram_we <= 0;
                        if( fb_over ) begin
                            fb_clr  <= 1;
                            line    <= ~line;
                            fb_done <= 1;
                        end
                    end
                end
        ////////////// Read line from PSRAM to internal BRAM
                READ_WAIT: begin
                    ddram_addr[3+:HW] <= rd_addr;
                    ddram_rd   <= 1;
                    ddram_wait <= ~0;
                    scr_we     <= 1;
                    st         <= READIN;
                end
                READIN: begin
                    if( ddram_dout_ready ) begin
                        brstin <= 1;
                        rd_addr <= rd_addr + 1'd1;
                    end
                    // if( ddram_dout_ready ) begin
                    //     brstin <= 1;
                    //     if (~&rd_addr & brstin) rd_addr <= rd_addr + 1'd1;
                    // end else if( brstin ) begin
                    //     scr_we <= 0;
                    //     brstin <= 0;
                    //     st     <= &rd_addr ? IDLE : READ_WAIT;
                    // end
                end
                default: st <= IDLE;
            endcase
        end
    end
end

endmodule