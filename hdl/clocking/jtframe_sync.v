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
    Date: 6-9-2021 */

module jtframe_sync #(parameter W=1)(
    input   clk,
    input   [W-1:0] raw,
    output  [W-1:0] sync
);

generate
    genvar i;
    for( i=0; i<W; i=i+1 ) begin : synchronizer
        reg [1:0] s;
        assign sync[i] = s[1];

        always @(posedge clk) begin
            s <= { s[0], raw[i] };
        end
    end
endgenerate

endmodule