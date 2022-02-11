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

module jtframe_debug #(
    parameter COLORW=4
) (
    input clk,
    input rst,

    input            shift,         // count step 16, instead of 1
    input            ctrl,          // reset debug_bus
    input            debug_plus,
    input            debug_minus,
    input            debug_rst,
    input      [3:0] key_gfx,
    input      [7:0] key_digit,
    // overlay the value on video
    input              pxl_cen,
    input [COLORW-1:0] rin,
    input [COLORW-1:0] gin,
    input [COLORW-1:0] bin,
    input              lhbl,
    input              lvbl,

    // combinational output
    output reg [COLORW-1:0] rout,
    output reg [COLORW-1:0] gout,
    output reg [COLORW-1:0] bout,
    // debug features
    output reg [7:0] debug_bus,
    output reg [3:0] gfx_en
);

reg        last_p, last_m;
integer    cnt;
reg  [3:0] last_gfx;
reg        last_digit;

wire [7:0] step = shift ? 16 : 1;

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        debug_bus <= 0;
        gfx_en    <= 4'hf;
        last_digit <= 0;
    end else begin
        last_p   <= debug_plus;
        last_m   <= debug_minus;
        last_gfx <= key_gfx;
        last_digit <= |key_digit;


        if( ctrl && (debug_plus||debug_minus) ) begin
            debug_bus <= 0;
        end else begin
            if( debug_plus & ~last_p ) begin
                debug_bus <= debug_bus + step;
            end else if( debug_minus & ~last_m ) begin
                debug_bus <= debug_bus - step;
            end
            if( shift && key_digit!=0 && !last_digit ) begin
                debug_bus <= debug_bus ^ { key_digit[0],
                    key_digit[1],
                    key_digit[2],
                    key_digit[3],
                    key_digit[4],
                    key_digit[5],
                    key_digit[6],
                    key_digit[7] };
            end
        end
        for(cnt=0; cnt<4; cnt=cnt+1)
            if( key_gfx[cnt] && !last_gfx[cnt] ) gfx_en[cnt] <= ~gfx_en[cnt];
    end
end

// Video overlay
reg [8:0] vcnt,hcnt;
reg       lvbl_l, lhbl_l, osd_on;

always @(posedge clk) if(pxl_cen) begin
    lvbl_l <= lvbl;
    lhbl_l <= lhbl;
    if (!lvbl)
        vcnt <= 0;
    else if( lhbl && !lhbl_l )
        vcnt <= vcnt + 9'd1;
    if(!lhbl)
        hcnt <= 0;
    else hcnt <= hcnt + 9'd1;
    osd_on <= debug_bus != 0 && vcnt[8:3]==6'h18 && hcnt[8:6] == 3'b010;
end

always @* begin
    rout = rin;
    gout = gin;
    bout = bin;
    if( osd_on && hcnt[2:0]!=0 ) begin
        rout[COLORW-1:COLORW-2] = {2{debug_bus[ ~hcnt[5:3] ]}};
        gout[COLORW-1:COLORW-2] = {2{debug_bus[ ~hcnt[5:3] ]}};
        bout[COLORW-1:COLORW-2] = {2{debug_bus[ ~hcnt[5:3] ]}};
    end
end

endmodule