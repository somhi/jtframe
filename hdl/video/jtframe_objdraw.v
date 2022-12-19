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
    Date: 18-12-2022 */

// Draws a 16x16 tile

module jtframe_objdraw#( parameter
    CW    = 12,    // code width
    PW    =  8,    // pixel width (lower four bits come from ROM)
    SWAPH =  0,    // swaps the two horizontal halves of the tile
    // object line buffer
    FLIP_OFFSET = 0,
    ALPHA       = 0
)(
    input               rst,
    input               clk,
    input               pxl_cen,
    input               hs,
    input               flip,
    input        [ 8:0] hdump,

    input               draw,
    output              busy,
    input    [CW-1:0]   code,
    input      [ 8:0]   xpos,
    input      [ 3:0]   ysub,

    input               hflip,
    input               vflip,
    input      [PW-5:0] pal,

    output     [CW+6:2] rom_addr,
    output              rom_cs,
    input               rom_ok,
    input      [31:0]   rom_data,

    output     [PW-1:0] pxl
);

wire [PW-1:0] buf_din;
wire    [8:0] buf_addr;
wire          buf_we;

jtframe_draw #(
    .CW   ( CW    ),
    .PW   ( PW    ),
    .SWAPH( SWAPH )
)u_draw(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .draw       ( draw      ),
    .busy       ( busy      ),
    .code       ( code      ),
    .xpos       ( xpos      ),
    .ysub       ( ysub      ),
    .hflip      ( hflip     ),
    .vflip      ( vflip     ),
    .pal        ( pal       ),
    .rom_addr   ( rom_addr  ),
    .rom_cs     ( rom_cs    ),
    .rom_ok     ( rom_ok    ),
    .rom_data   ( rom_data  ),

    .buf_addr   ( buf_addr  ),
    .buf_we     ( buf_we    ),
    .buf_din    ( buf_din   )
);

jtframe_obj_buffer #(
    .DW         ( PW          ),
    .ALPHA      ( ALPHA       ),
    .FLIP_OFFSET( FLIP_OFFSET )
) u_linebuf(
    .clk        ( clk       ),
    .flip       ( flip      ),
    .LHBL       ( ~hs       ),
    // New line writting
    .we         ( buf_we    ),
    .wr_data    ( buf_din   ),
    .wr_addr    ( buf_addr  ),
    // Previous line reading
    .rd         ( pxl_cen   ),
    .rd_addr    ( hdump     ),
    .rd_data    ( pxl       )
);

endmodule