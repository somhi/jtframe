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

// Draws one line of a 16x16 tile
// It could be extended to 32x32 easily

module jtframe_draw#( parameter
    CW = 12,    // code width
    PW =  8     // pixel width (lower four bits come from ROM)
)(
    input               rst,
    input               clk,

    input               draw,
    output reg          busy,
    input    [CW-1:0]   code,
    input      [ 8:0]   xpos,
    input      [ 3:0]   ysub,

    input               hflip,
    input               vflip,
    input      [PW-5:0] pal,

    output     [CW+6:2] rom_addr,
    output reg          rom_cs,
    input               rom_ok,
    input      [31:0]   rom_data,

    output reg [ 8:0]   buf_addr,
    output              buf_we,
    output     [PW-1:0] buf_din
);

// Each tile is 16x16 and comes from the same ROM
// but it looks like the sprites have the two 8x16 halves swapped

reg  [31:0] pxl_data;
reg         rom_lsb;
reg  [ 3:0] cnt;
wire [ 3:0] ysubf, pxl;

assign ysubf   = ysub^{4{vflip}};
assign buf_din = { pal, pxl };
assign pxl     = hflip ?
    { pxl_data[23], pxl_data[ 7], pxl_data[31], pxl_data[15] } :
    { pxl_data[16], pxl_data[ 0], pxl_data[24], pxl_data[ 8] };

assign rom_addr = { code, ysubf[3], rom_lsb, ysubf[2:0] };
assign buf_we   = busy & ~cnt[3];

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        rom_cs   <= 0;
        buf_addr <= 0;
        pxl_data <= 0;
        busy     <= 0;
        cnt      <= 0;
    end else begin
        if( !busy ) begin
            if( draw ) begin
                rom_lsb  <= hflip; // 14+4 = 18 (+2=20)
                rom_cs   <= 1;
                buf_addr <= xpos;
                busy     <= 1;
                cnt      <= 8;
            end
        end else begin
            if( rom_ok && rom_cs && cnt[3]) begin
                pxl_data <= rom_data;
                cnt[3]   <= 0;
                if( rom_lsb^hflip ) begin
                    rom_cs <= 0;
                end else begin
                    rom_cs <= 1;
                end
            end
            if( !cnt[3] ) begin
                cnt      <= cnt+1'd1;
                buf_addr <= buf_addr+1'd1;
                pxl_data <= hflip ? pxl_data << 1 : pxl_data >> 1;
                rom_lsb  <= ~hflip;
                if( cnt[2:0]==7 && !rom_cs ) busy <= 0;
            end
        end
    end
end

endmodule