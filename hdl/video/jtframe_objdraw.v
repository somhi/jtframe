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

// Draws 16x16 sprites in a double-line buffer
// Assumes that the inputs are still during drawing,
// otherwise set LATCH=1
// LATCH=1 will introduce an extra 1-clock per drawing
// operation, so use LATCH=0 when throughput is critical

module jtframe_objdraw#( parameter
    CW    = 12,    // code width
    PW    =  8,    // pixel width (lower four bits come from ROM)
    SWAPH =  0,    // swaps the two horizontal halves of the tile
    HJUMP =  0,    // set to 0 if hdump is a continuous count
                   // set to 1 if hdump jumps from  FF to 180  (like KIWI)
                   // set to 2 if hdump jumps from 1FF to  80  (like JTTORA)
    LATCH =  0,    // If set, latches code, xpos, ysub, hflip, vflip and pal when draw is set and busy is low
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
reg     [8:0] aeff, hdf;
wire          buf_we;

reg  [CW-1:0] dr_code;
reg    [ 8:0] dr_xpos;
reg    [ 3:0] dr_ysub;
reg           dr_hflip, dr_vflip, dr_draw;
reg  [PW-5:0] dr_pal;

generate
    if( LATCH ) begin
        always @(posedge clk) if( !busy ) begin
            dr_draw  <= draw;
            dr_code  <= code;
            dr_xpos  <= xpos;
            dr_ysub  <= ysub;
            dr_hflip <= hflip;
            dr_vflip <= vflip;
            dr_pal   <= pal;
        end
    end else begin
        always @* begin
            dr_draw  = draw;
            dr_code  = code;
            dr_xpos  = xpos;
            dr_ysub  = ysub;
            dr_hflip = hflip;
            dr_vflip = vflip;
            dr_pal   = pal;
        end
    end
endgenerate

always @* begin
    case( HJUMP )
        1: begin
            aeff = { buf_addr[8], buf_addr[8] | buf_addr[7], buf_addr[6:0] }; // 100~17F is translated to 180~1FF
            hdf  = hdump ^ { 1'b0, flip&~hdump[8], {7{flip}} };
        end
        2: begin
            aeff = { buf_addr[8],~buf_addr[8] | buf_addr[7], buf_addr[6:0] }; //  00~ 7F is translated to  80~ FF
            hdf  = hdump ^ { 1'b0, flip&hdump[8], {7{flip}} }; // untested line
        end
        default: begin
            aeff = buf_addr;
            hdf  = hdump ^ { 1'b0, , {8{flip}} }; // untested line
        end
    endcase
end

jtframe_draw #(
    .CW   ( CW    ),
    .PW   ( PW    ),
    .SWAPH( SWAPH )
)u_draw(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .draw       ( dr_draw   ),
    .busy       ( busy      ),
    .code       ( dr_code   ),
    .xpos       ( dr_xpos   ),
    .ysub       ( dr_ysub   ),
    .hflip      ( dr_hflip  ),
    .vflip      ( dr_vflip  ),
    .pal        ( dr_pal    ),
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
    .flip       ( 1'b0      ),
    .LHBL       ( ~hs       ),
    // New line writting
    .we         ( buf_we    ),
    .wr_data    ( buf_din   ),
    .wr_addr    ( aeff      ),
    // Previous line reading
    .rd         ( pxl_cen   ),
    .rd_addr    ( hdf       ),
    .rd_data    ( pxl       )
);

endmodule