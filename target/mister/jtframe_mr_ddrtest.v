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
    Date: 7-3-2019 */

module jtframe_mr_ddrtest(
    input             clk,
    input             rst,
    input      [ 7:0] debug_bus,
    input             vs,

    output            ddram_clk,
    input             ddram_busy,
    output reg [ 7:0] ddram_burstcnt,
    output reg [28:0] ddram_addr,
    input      [63:0] ddram_dout,
    input             ddram_dout_ready,
    output reg        ddram_rd,
    output     [63:0] ddram_din,
    output reg [ 7:0] ddram_be,
    output            ddram_we,
    output reg [ 7:0] st_dout
);

reg vsl, busy;
reg [7:0] din_cnt, cnt;

assign ddram_clk = clk;
assign ddram_we = 0;

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        vsl      <= 0;
        busy     <= 1;
        ddram_be <= 0;
        ddram_rd <= 0;
        din_cnt  <= 0;
        cnt      <= 0;
        st_dout  <= 0;
        ddram_burstcnt <= 0;
    end else begin
        vsl <= vs; 
        st_dout <= debug_bus[7] ? din_cnt : { 3'd0, ddram_dout_ready, 3'd0, ddram_busy };
        if( vs && !vsl && !busy) begin
            cnt      <= 0;
            din_cnt  <= cnt;
            busy     <= 1;
            ddram_rd <= 1;
            ddram_addr[20:18] <= debug_bus[7:5];
            ddram_burstcnt    <= 8'h1 << debug_bus[2:0];
            case(debug_bus[4:3])
                0: ddram_be <= 8'b0000_0001;
                1: ddram_be <= 8'b0000_0011;
                2: ddram_be <= 8'b0000_1111;
                3: ddram_be <= 8'b1111_1111;
            endcase
        end
        if( vs && !vsl && busy) begin
            busy <= 0;
            ddram_rd <= 0;
        end
        if( busy && !ddram_busy ) begin
            ddram_rd <= 0;
            if( ddram_dout_ready ) cnt <= cnt +1'd1;
        end
    end
end

endmodule