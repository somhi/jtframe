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
    Date: 8-5-2021 */

module jtframe_debug(
    input clk,
    input rst,

    input            shift,         // count step 16, instead of 1
    input            ctrl,          // reset debug_bus
    input            debug_plus,
    input            debug_minus,
    input            debug_rst,
    input      [3:0] key_gfx,
    // debug features
    output reg [7:0] debug_bus,
    output reg [3:0] gfx_en
);

reg        last_p, last_m;
integer    cnt;
reg  [3:0] last_gfx;

wire [7:0] step = shift ? 16 : 1;

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        debug_bus <= 0;
        gfx_en    <= 4'hf;
    end else begin
        last_p   <= debug_plus;
        last_m   <= debug_minus;
        last_gfx <= key_gfx;


        if( ctrl && (debug_plus||debug_minus) ) begin
            debug_bus <= 0;
        end else begin
            if( debug_plus & ~last_p ) begin
                debug_bus <= debug_bus + step;
            end else if( debug_minus & ~last_m ) begin
                debug_bus <= debug_bus - step;
            end
        end
        for(cnt=0; cnt<4; cnt=cnt+1)
            if( key_gfx[cnt] && !last_gfx[cnt] ) gfx_en[cnt] <= ~gfx_en[cnt];
    end
end

endmodule