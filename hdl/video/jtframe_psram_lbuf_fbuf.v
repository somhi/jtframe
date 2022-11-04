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
// the frame is stored in two PSRAM chips

// This module is not fully tested yet
module jtframe_psram_lbuf_fbuf #(parameter
    CLK96   =   0,   // assume 48-ish MHz operation by default
    DW      =  16,
    VW      =   8,
    HW      =   9,
    HSTART  =   0,
    HEND    = 255,
    ALPHA   =   0
)(
    input               clk,
    input               pxl_cen,

    output              fb_hs,
    output     [VW-1:0] fb_v,
    input      [VW-1:0] vrender,
    input               vs,     // vertical sync, the buffer is swapped here
    input               lvbl,   // vertical blank, active low
    input               lhbl,   // vertical blank, active low

    // data writting
    input               ln_done,
    input      [HW-1:0] ln_addr,
    input      [DW-1:0] ln_data,
    input               ln_we,

    // PSRAM chip 0
    output     [ 21:16] psram0_addr,
    inout      [  15:0] psram0_adq,
    output     [   1:0] psram0_dsn,
    output              psram0_csn,
    output              psram0_oen,
    output              psram0_wen,
    output              psram0_cre,

    // PSRAM chip 1
    output     [ 21:16] psram1_addr,
    inout      [  15:0] psram1_adq,
    output     [   1:0] psram1_dsn,
    output              psram1_csn,
    output              psram1_oen,
    output              psram1_wen,
    output              psram1_cre,

    output     [DW-1:0] pxl
);

localparam    BW=VW+HW+1;

wire       [BW-1:0] bwr_addr;
wire       [  15:0] bwr_din;
wire       [   1:0] bwr_dsn;
wire                bwr_cs, bwr_we, bwr_ok;



jtframe_psram_rand #(.CLK96(CLK96)) u_psram0(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .addr       ( req0_addr     ),       // 8 M x 16 bit = 16 MByte
    .din        ( req0_din      ),
    .dout       ( req0_dout     ),
    .dsn        ( req0_dsn      ),
    .cs         ( req0_cs       ),
    .we         ( req0_we       ),
    .ok         ( req0_ok       ),
    // PSRAM chip 0
    psram_clk   ( psram0_clk    ),
    psram_cre   ( psram0_cre    ),
    psram_cen   ( psram0_cen    ),
    psram_addr  ( psram0_addr   ),
    psram_adq   ( psram0_adq    ),
    psram_dsn   ( psram0_dsn    ),
    psram_oen   ( psram0_oen    ),
    psram_wen   ( psram0_wen    )
);

jtframe_lbuf_fbuf #(
    .DW     (  16 ),
    .VW     (   8 ),
    .HW     (   9 ),
    .HSTART (   0 ),
    .HEND   ( 255 ),
    .ALPHA  (   0 )
) u_lbuf_fbuf(
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

endmodule