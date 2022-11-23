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

module jtframe_lfbuf_ctrl #(parameter
    CLK96   =   0,   // assume 48-ish MHz operation by default
    VW      =   8,
    HW      =   9
)(
    input               rst,    // hold in reset for >150 us
    input               clk,

    input               lhbl,
    input               ln_done,
    input      [VW-1:0] vrender,
    input      [VW-1:0] ln_v,
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

    // cell RAM (PSRAM) signals
    output reg [ 21:16] cr_addr,
    inout      [  15:0] cr_adq,
    input               cr_wait,
    output              cr_clk,
    output reg          cr_advn,
    output reg          cr_cre,
    output     [   1:0] cr_cen, // chip enable
    output reg          cr_oen,
    output reg          cr_wen,
    output     [   1:0] cr_dsn
);

reg  [ 3:0] st;
wire [ 7:0] vram; // current row (v) being processed through the external RAM
reg  [15:0] adq_reg;
reg         lhbl_l, do_rd, do_wr,
            csn, ln_done_l;
wire        fb_over;

localparam [3:0] INIT       = 0,
                 WAIT_CFG   = 1,
                 WAIT_REF   = 2,
                 SET_REF    = 3,
                 IDLE       = 4,
                 BREAK      = 5,
                 WRITE_LINE = 6,
                 WRITE_WAIT = 7,
                 WRITEOUT   = 8,
                 // CLEAR      = 9,
                 READ_LINE  = 10,
                 READ_WAIT  = 11,
                 READIN     = 12;

localparam AW = HW+VW;

localparam [21:0] BUS_CFG = {
    2'd0, // reserved
    2'd2, // bus configuration register
    2'd0, // reserved
    1'b0, // synchronous burst access
    1'b1, // variable latency
    3'd3, // default latency counter
    1'b1, // wait is active high
    1'b0, // reserved
    1'b1, // asserted one data cycle before delay (default)
    2'd0, // reserved
    2'd1, // drive strength (default)
    1'b1, // burst wrap
    3'd7  // continuous burst
}, REF_CFG = {
    2'd0, // reserved
    2'd0, // refresh configuration register
    13'd0, // reserved
    1'b1, // deep power power down disabled
    1'd0, // reserved
    1'b1, // use bottom half of the array (or all of it)
    AW == 21 ? 2'd0 : // full array    (4096 x 16 bits = 64Mbit per chip half)
    AW == 20 ? 2'd1 : // half the array(2048 x 16 bits)
    AW == 19 ? 2'd2 : // 1/4 the array (1024 x 16 bits)
               2'd3   // 1/8 the array (512k x 16 bits)
};

assign cr_cen  = { 1'b1, csn }; // I call it csn to avoid the confusion with the common cen (clock enable) signal
assign cr_dsn  = 0;
assign fb_dout =  cr_oen ? 16'd0 : cr_adq;
assign cr_adq  = !cr_advn ? adq_reg : !cr_oen ? 16'hzzzz : fb_din;
assign cr_clk  = clk;
assign fb_over = &fb_addr;
assign vram    = do_rd ? vrender : ln_v;

`ifdef SIMULATION
wire bad_rd = do_rd & lhbl;
always @(posedge clk) begin
    if( bad_rd ) begin
        $display("%m read from PSRAM extended over active line period");
        //$finish;
    end
end
`endif

always @( posedge clk, posedge rst ) begin
    if( rst ) begin
        do_rd <= 0;
        do_wr <= 0;
    end else begin
        lhbl_l    <= lhbl;
        ln_done_l <= ln_done;
        if( lhbl_l & ~lhbl ) do_rd <= 1;
        if( st==READIN && (&rd_addr)) do_rd <= 0;
        if( ln_done & ~ln_done_l    ) do_wr <= 1;
        if( st==WRITEOUT && fb_over ) do_wr <= 0;
    end
end

always @( posedge clk, posedge rst ) begin
    if( rst ) begin
        st      <= INIT;
        cr_advn <= 0;
        cr_oen  <= 1;
        cr_cre  <= 0;
        csn     <= 1;
        fb_addr <= 0;
        fb_clr  <= 0;
        fb_done <= 1;
        rd_addr <= 0;
        scr_we  <= 0;
        line    <= 0;
    end else begin
        fb_done <= 0;
        cr_advn <= 1;
        if( fb_clr ) begin
            // the line is cleared outside the state machine so a
            // do_rd operation can happen independently
            fb_addr <= fb_addr + 1'd1;
            if( fb_over ) begin
                fb_clr  <= 0;
            end
        end
        case( st )
            INIT: begin
                { cr_addr, adq_reg } <= BUS_CFG;
                csn     <= 0;
                cr_advn <= 0;
                cr_cre  <= 1;
                cr_oen  <= 1;
                cr_wen  <= 0;
                st      <= WAIT_CFG;
            end
            WAIT_CFG: begin
                if( cr_wait ) begin
                    csn    <= 1;
                    cr_wen <= 1;
                    st     <= SET_REF;
                end
            end
            SET_REF: begin
                { cr_addr, adq_reg } <= REF_CFG;
                csn     <= 0;
                cr_advn <= 0;
                cr_cre  <= 1;
                cr_oen  <= 1;
                cr_wen  <= 0;
                st      <= WAIT_REF;
            end
            WAIT_REF: begin
                if( cr_wait ) begin
                    csn    <= 1;
                    cr_wen <= 1;
                    st     <= IDLE;
                end
            end
    // Wait for requests
            IDLE: begin
                csn     <= 1;
                cr_wen  <= 1;
                cr_cre  <= 0;
                adq_reg <= { vram[VW-6:0], {16+5-VW{1'b0}} };
                cr_addr <= { do_rd ^ frame, vram[VW-1-:5]  };
                if( do_rd ) begin
                    // it doesn't matter if vrender changes after do_rd
                    // is set as it is latched in { cr_addr, adq_reg }
                    csn     <= 0;
                    rd_addr <= 0;
                    cr_oen  <= 1;
                    st      <= READ_LINE;
                end else if( do_wr && !fb_clr ) begin
                    csn     <= 0;
                    fb_addr <= 0;
                    cr_oen  <= 1;
                    st      <= WRITE_LINE;
                end
            end
            BREAK: begin
                adq_reg[HW-1:0] <= do_wr ? fb_addr : rd_addr;
                csn <= 0;
                st  <= cr_wen ? READ_LINE : WRITE_LINE;
            end
    ////////////// Write line from internal BRAM to PSRAM
            WRITE_LINE: begin
                cr_advn <= 0;
                cr_wen  <= 0; // write burst
                st      <= WRITE_WAIT;
            end
            WRITE_WAIT: begin
                if( cr_wait ) st <= WRITEOUT;
            end
            WRITEOUT: begin
                fb_addr <= fb_addr + 1'd1;
                if( &fb_addr[6:0] ) begin // 128 pixels chunk to keep csn low for less than 4us
                    csn    <= 1;
                    st     <= fb_over /* full line read */ ? IDLE : BREAK;
                    if( fb_over ) begin
                        fb_clr  <= 1;
                        line    <= ~line;
                        fb_done <= 1;
                    end
                end
            end
    ////////////// Read line from PSRAM to internal BRAM
            READ_LINE: begin
                cr_advn <= 0;
                cr_wen  <= 1; // read burst
                scr_we  <= 1;
                st      <= READ_WAIT;
            end
            READ_WAIT: begin
                cr_oen <= 0;
                if( cr_wait ) st <= READIN;
            end
            READIN: begin
                rd_addr <= rd_addr + 1'd1;
                if( &rd_addr[6:0] ) begin // 128 pixels chunk to keep csn low for less than 4us
                    csn    <= 1;
                    cr_oen <= 1;
                    scr_we <= 0;
                    st     <= &rd_addr /* full line read */ ? IDLE : BREAK;
                end
            end
            default: st <= IDLE;
        endcase
    end
end

endmodule