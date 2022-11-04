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
    Date: 30-10-2022 */

// Frame buffer built on top of two line buffers
// the frame buffer is assumed to be done on a 16-bit memory
// It uses 4x lines of internal BRAM.
// The idea is to use a regular object double line buffer to collect the line from the object processing unit
// at the same time, the previous line is dumped to the SDRAM
// in the mean time, one line is read from the SDRAM into another line buffer and
// the previous line is dumped from the same line buffer to the screen

// This module is not fully tested yet
module jtframe_lbuf_fbuf #(parameter
    DW      =  16,
    VW      =   8,
    HW      =   9,
    HSTART  =   0,
    HEND    = 255,
    ALPHA   =   0
)(
    input               clk,
    input               pxl_cen,

    output reg          fb_hs,
    output reg [VW-1:0] fb_v,
    input      [VW-1:0] vrender,
    input               vs,     // vertical sync, the buffer is swapped here
    input               lvbl,   // vertical blank, active low
    input               lhbl,   // vertical blank, active low

    // data writting
    input               ln_done,
    input      [HW-1:0] ln_addr,
    input      [DW-1:0] ln_data,
    input               ln_we,

    // output data to buffer
    output     [BW-1:0] bwr_addr,
    output reg [  15:0] bwr_din,
    output     [   1:0] bwr_dsn,
    output reg          bwr_cs,
    output              bwr_we,
    input               bwr_ok,

    // input data from buffer
    output     [BW-1:0] brd_addr,
    input               brd_ok,
    output reg          brd_cs,
    input      [  15:0] brd_data,
    input               hs,
    input      [HW-1:0] hdump,

    output     [DW-1:0] pxl
);

localparam    BW=VW+HW+1;

reg           frame, vsl, hsl, line=0,
              lwr_done, lrd_done, lwr_wt,
              fwr_done, fwr_done_l;

reg  [VW-1:0] v2fb, vstart=0, vend=0;
reg  [HW-1:0] h2fb, fb2h;
wire          fb2h_we, dln_rd;

assign dln_rd   = pxl_cen && !bwr_cs;
assign bwr_we   = 1;
assign bwr_dsn  = 0;
assign bwr_addr = { frame, v2fb, h2fb };
assign brd_addr = {~frame, vrender, fb2h };

`ifdef SIMULATION
initial begin
    if( DW>16 ) begin
        $display("jtframe_framebuf: cannot handle pixels of more than 16 bits");
        $finish;
    end
end
`endif

// Capture the vstart/vend values
always @(posedge clk) begin
    lvbl_l <= lvbl;
    if( !lvbl &&  lvbl_l ) vend   <= vrender;
    if(  lvbl && !lvbl_l ) vstart <= vrender;
end

// count lines so objects get drawn in the line buffer
// and dumped from there to the SDRAM
always @(posedge clk) begin
    fb_hs <= 0;
    vsl     <= vs;
    fwr_done_l <= fwr_done;
    if( !lwr_done ) lwr_wt <= 0; // prevents counting fb_v up twice
    if( vs && !vsl ) begin
        frame    <= ~frame;
        fb_v   <= vstart;
        fwr_done <= 0;
        v2fb     <= vend;
    end
    if( lwr_done && ln_done && !fwr_done_l && !lwr_wt ) begin
        fb_v <= fb_v + 1'd1;
        v2fb   <= fb_v;
        lwr_wt <= 1;
        if( fb_v == vend )
            fwr_done <= 1;
        else
            fb_hs <= 1;
    end
end

// Read the line buffer to dump to the frame buffer
always @(posedge clk) begin
    if( fb_hs && !fwr_done ) begin
        h2fb     <= 0;
        lwr_done <= 0;
    end
    if( !lwr_done ) begin
        if( dln_rd ) begin
            bwr_cs <= 1;
            bwr_din <= 0; // way around DW!=16
            bwr_din[DW-1:0] <= aux;
        end
        if( bwr_ok && bwr_cs ) begin
            h2fb   <= h2fb + 1'd1;
            bwr_cs <= 0;
            if( h2fb == HEND ) begin
                lwr_done <= 1;
            end
        end
    end
end

assign fb2h_we = brd_cs & brd_ok;

wire [DW-1:0] aux;

always @(posedge clk) begin
    hsl <= hs;
    if( hs & ~hsl ) begin
        line <= ~line;
        fb2h <= HSTART;
        lrd_done <= 0;
    end
    if( !lrd_done ) begin
        if( pxl_cen ) begin
            brd_cs <= 1;
        end
        if( brd_ok & brd_cs ) begin
            fb2h   <= fb2h + 1'd1;
            brd_cs <= 0;
            if( fb2h == HEND ) lrd_done <= 1;
        end
    end
end

// double line buffer to collect input data
jtframe_obj_buffer #(
    .DW     (   DW    ),
    .AW     (   HW    ),
    .ALPHA  (  ALPHA  )
) u_linein(
    .clk        ( clk       ),
    .LHBL       ( fb_hs     ),
    .flip       ( 1'b0      ),
    // New data writes
    .wr_data    ( ln_data   ),
    .wr_addr    ( ln_addr   ),
    .we         ( ln_we     ),
    // Old data reads (and erases)
    .rd_addr    ( h2fb      ),
    .rd         ( dln_rd    ),
    .rd_data    ( aux       )
);

jtframe_dual_ram #(.dw(DW),.aw(HW+1)) u_lineout(
    // Read from SDRAM, write to line buffer
    .clk0   ( clk       ),
    .data0  ( brd_data[DW-1:0]  ),
    .addr0  ( { line, fb2h } ),
    .we0    ( fb2h_we   ),
    .q0     (           ),
    // Read from line buffer to screen
    .clk1   ( clk       ),
    .data1  ( {DW{1'b0}}),
    .addr1  ( {~line, hdump} ),
    .we1    ( 1'b0      ),
    .q1     ( pxl       )
);

endmodule