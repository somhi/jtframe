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
    // emulation based on joysticks
    input     [6:0] joystick1, joystick2,
    input     [8:0] spinner_1, spinner_2,
    output    [1:0] dial_x,    dial_y
);

reg  [1:0] dial_pulse;
reg        LHBL_l, sel;
reg        inc_1p, inc_2p,
           dec_1p, dec_2p,
           up_1p, up_2p,
           last1,  last2;

wire       toggle1, toggle2, line,
           up_joy;

assign toggle1 = last1 != spinner_1[8],
       toggle2 = last2 != spinner_2[8];
assign up_joy  = dial_pulse[1] & line;
assign line    = LHBL & ~LHBL_l;

always @* begin
    inc_1p   = sel ? !joystick1[5] :  spinner_1[7];
    dec_1p   = sel ? !joystick1[6] : !spinner_1[7];
    inc_2p   = sel ? !joystick2[5] :  spinner_2[7];
    dec_2p   = sel ? !joystick2[6] : !spinner_2[7];
end

// The dial update rythm is set to once every four lines
always @(posedge clk) begin
    LHBL_l <= LHBL;
    if( line ) dial_pulse <= dial_pulse+2'd1;
    up_1p <= up_joy || toggle1;
    up_2p <= up_joy || toggle2;
    sel   <= up_joy;
end

always @(posedge clk) begin
    last1 <= spinner_1[8];
    last2 <= spinner_2[8];
end

jt4701_dialemu u_dial1p(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .pulse      ( up_1p         ),
    .inc        ( inc_1p        ),
    .dec        ( dec_1p        ),
    .dial       ( dial_x        )
);

jt4701_dialemu u_dial2p(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .pulse      ( up_2p         ),
    .inc        ( inc_2p        ),
    .dec        ( dec_2p        ),
    .dial       ( dial_y        )
);

endmodule