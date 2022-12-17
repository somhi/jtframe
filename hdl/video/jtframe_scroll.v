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
    Date: 15-12-2022 */
    

// Generic tile map generator with no scroll
// The ROM data must be in these format
// code, H parts, V part
// pixel data is 4bpp, and arrives in four bytes. Each byte is for a plane

module jtframe_scroll #( parameter
    SIZE =  8,    // 8x8, 16x16 or 32x32
    VA   = 10,
    CW   = 12,
    PW   =  8,
    MAP_HW = 9,    // size of the map in pixels
    MAP_VW = 9,
    VR   = SIZE==8 ? CW+3 : SIZE==16 ? CW+5 : CW+7,
    XOR_HFLIP = 0, // set to 1 so hflip gets ^ with flip
    XOR_VFLIP = 0  // set to 1 so vflip gets ^ with flip
)(
    input              rst,
    input              clk,
    input              pxl_cen,

    input              vs,

    input [MAP_VW-1:0] vdump,
    input [MAP_HW-1:0] hdump,
    input              blankn,  // if !blankn there are no ROM requests
    input              flip,    // Screen flip
    input      [ 8:0]  scrx,
    input      [ 8:0]  scry,

    output reg [VA-1:0]vram_addr,

    input      [CW-1:0]code,
    input      [PW-5:0]pal,
    input              hflip,
    input              vflip,

    output reg [VR-1:0]rom_addr,
    input      [31:0]  rom_data,
    output             rom_cs,
    input              rom_ok,      // ignored. It assumes that data is always right

    output     [PW-1:0]pxl
);

localparam VW = SIZE==8 ? 3 : SIZE==16 ? 4:5;

reg        vsl;
reg  [8:0] veff;
wire [8:0] heff;

assign heff = hdump + scrx;

always @(posedge clk) begin
    vsl <= vs;
    if( ~vs & vsl ) veff <= vdump + scry;
end

jtframe_tilemap #( 
    .SIZE       ( SIZE      ),
    .VA         ( VA        ),
    .CW         ( CW        ),
    .PW         ( PW        ),
    .MAP_HW     ( MAP_HW    ),
    .MAP_VW     ( MAP_VW    ),
    .XOR_HFLIP  ( XOR_HFLIP ),
    .XOR_VFLIP  ( XOR_VFLIP )
)u_tilemap(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .pxl_cen    ( pxl_cen   ),

    .vdump      ( veff      ),
    .hdump      ( heff      ),
    .blankn     ( blankn    ),
    .flip       ( flip      ),

    .vram_addr  ( vram_addr ),

    .code       ( code      ),
    .pal        ( pal       ),
    .hflip      ( hflip     ),
    .vflip      ( vflip     ),

    .rom_addr   ( rom_addr  ),
    .rom_data   ( rom_data  ),
    .rom_cs     ( rom_cs    ),
    .rom_ok     ( rom_ok    ),

    .pxl        ( pxl       )
);

endmodule