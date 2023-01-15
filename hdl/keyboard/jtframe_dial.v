/*  This file is part of JT_FRAME.
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
    Date: 15-1-2023 */

// Dial emulation using joystick, mouse or spinner

module jtframe_dial(
    input           rst,
    input           clk,
    input           LHBL,
    input     [6:0] joystick1,
    input     [6:0] joystick2,
    output    [1:0] dial_x,
    output    [1:0] dial_y
);

reg  [1:0] dial_pulse;
reg        LHBL_l;


// The dial update ryhtm is set to once every four lines
always @(posedge clk) begin
    LHBL_l <= LHBL;
    if( LHBL && !LHBL_l ) dial_pulse <= dial_pulse+2'd1;
end

jt4701_dialemu u_dial1p(
    .clk        ( clk           ),
    .rst        ( rst           ),
    .pulse      ( dial_pulse[1] ),
    .inc        ( ~joystick1[5] ),
    .dec        ( ~joystick1[6] ),
    .dial       ( dial_x        )
);

jt4701_dialemu u_dial2p(
    .clk        ( clk           ),
    .rst        ( rst           ),
    .pulse      ( dial_pulse[1] ),
    .inc        ( ~joystick2[5] ),
    .dec        ( ~joystick2[6] ),
    .dial       ( dial_y        )
);

endmodule