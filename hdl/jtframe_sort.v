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
    Date: 14-1-2022 */

module jtframe_sort(
    input      [7:0] debug_bus,
    input      [3:0] busin,
    output reg [3:0] busout
);

always @* begin
    case( debug_bus[4:0] )
        0: busout = { busin[3], busin[2], busin[1], busin[0] };
        1: busout = { busin[3], busin[2], busin[0], busin[1] };
        2: busout = { busin[3], busin[1], busin[2], busin[0] };
        3: busout = { busin[3], busin[1], busin[0], busin[2] };
        4: busout = { busin[3], busin[0], busin[1], busin[2] };
        5: busout = { busin[3], busin[0], busin[2], busin[1] };

        6: busout = { busin[2], busin[3], busin[1], busin[0] };
        7: busout = { busin[2], busin[3], busin[0], busin[1] };
        8: busout = { busin[2], busin[1], busin[3], busin[0] };
        9: busout = { busin[2], busin[1], busin[0], busin[3] };
       10: busout = { busin[2], busin[0], busin[1], busin[3] };
       11: busout = { busin[2], busin[0], busin[3], busin[1] };

       12: busout = { busin[1], busin[2], busin[3], busin[0] };
       13: busout = { busin[1], busin[2], busin[0], busin[3] };
       14: busout = { busin[1], busin[3], busin[2], busin[0] };
       15: busout = { busin[1], busin[3], busin[0], busin[2] };
       16: busout = { busin[1], busin[0], busin[3], busin[2] };
       17: busout = { busin[1], busin[0], busin[2], busin[3] };

       18: busout = { busin[0], busin[2], busin[1], busin[3] };
       19: busout = { busin[0], busin[2], busin[3], busin[1] };
       20: busout = { busin[0], busin[1], busin[2], busin[3] };
       21: busout = { busin[0], busin[1], busin[3], busin[2] };
       22: busout = { busin[0], busin[3], busin[1], busin[2] };
       23: busout = { busin[0], busin[3], busin[2], busin[1] };
       default: busout = busin;
    endcase
end

endmodule
