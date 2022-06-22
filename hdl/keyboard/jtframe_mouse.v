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
    along with JTFRAME. If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 22-6-2022 */

module jtframe_mouse(
    input              rst,
    input              clk,
    input              lock,

    input signed [8:0] mouse_dx,
    input signed [8:0] mouse_dy,
    input        [7:0] mouse_f,
    input              mouse_st,
    input              mouse_idx,
    output reg  [15:0] mouse_1p,
    output reg  [15:0] mouse_2p,

    output reg  [ 2:0] but_1p,
    output reg  [ 2:0] but_2p
);

function [7:0] cv( input [8:0] min ); // convert to the right format
    `ifdef JTFRAME_MOUSE_NO2COMPL
        // some games cannot handle 2's complement, so
        // a conversion to sign plus magnitude is provided here
        cv = { min[8], min[8] ? -min[7:1] : min[7:1] };
    `else
        cv = min[8:1];
    `endif
endfunction

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        mouse_1p <= 0;
        mouse_2p <= 0;
        but_1p   <= 0;
        but_2p   <= 0;
    end else begin
        if( mouse_st && !lock ) begin
            if( !mouse_idx ) begin
                mouse_1p <= { cv(mouse_dy), cv(mouse_dx) };
                but_1p   <= mouse_f[2:0];
            end else begin
                mouse_2p <= { cv(mouse_dy), cv(mouse_dx) };
                but_2p   <= mouse_f[2:0];
            end
        end
    end
end

endmodule
