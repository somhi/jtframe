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

module jtframe_tilemap #( parameter
    SIZE =  8,    // 8x8, 16x16 or 32x32
    VA   = 10,
    CW   = 12,
    PW   =  8,
    VR   = SIZE==8 ? CW+3 : SIZE==16 ? CW+5 : CW+7,
    MAP_HW = 8,    // size of the map in pixels
    MAP_VW = 8,
    XOR_HFLIP = 0, // set to 1 so hflip gets ^ with flip
    XOR_VFLIP = 0  // set to 1 so vflip gets ^ with flip
)(
    input              rst,
    input              clk,
    input              pxl_cen,

    input [MAP_VW-1:0] vdump,
    input [MAP_HW-1:0] hdump,
    input              blankn,  // if !blankn there are no ROM requests
    input              flip,    // Screen flip

    output    [VA-1:0] vram_addr,

    input     [CW-1:0] code,
    input     [PW-5:0] pal,
    input              hflip,
    input              vflip,

    output reg [VR-1:0]rom_addr,
    input      [31:0]  rom_data,
    output             rom_cs,
    input              rom_ok,      // ignored. It assumes that data is always right

    output     [PW-1:0]pxl
);

localparam VW = SIZE==8 ? 3 : SIZE==16 ? 4:5;

reg  [  31:0] pxl_data;
reg  [PW-5:0] cur_pal;
wire          vf_g;
reg           hf_g;

initial begin
    if( SIZE==32 ) begin
        $display("WARNING %m: SIZE=32 has not been tested");
    end
end

assign rom_cs    = blankn;
assign pxl       = { cur_pal, hf_g ? {pxl_data[24], pxl_data[16], pxl_data[8], pxl_data[0]} :
                                     {pxl_data[31], pxl_data[23], pxl_data[15], pxl_data[7]} };
assign vf_g      = (flip & XOR_VFLIP[0])^vflip;

assign vram_addr[VA-1-:MAP_VW-VW]=vdump[MAP_VW-1:VW];
assign vram_addr[0+:MAP_HW-VW] = hdump[MAP_HW-1:VW];

always @(posedge clk) if(pxl_cen) begin
    if( hdump[2:0]==0 ) begin
        rom_addr[0+:VW] <= vdump[0+:VW]^{VW{vf_g}};
        rom_addr[VR-1-:CW] <= code;
        if( SIZE==16 ) rom_addr[VW]   <= hdump[3];
        if( SIZE==32 ) rom_addr[VW+1-:2] <= hdump[4:3];
        pxl_data <= rom_data;
        cur_pal  <= pal;
        hf_g     <= (flip & XOR_HFLIP[0])^hflip;
    end else begin
        pxl_data <= hf_g ? (pxl_data>>1) : (pxl_data<<1);
    end
end

endmodule