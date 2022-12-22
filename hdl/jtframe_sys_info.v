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
    Date: 22-12-2022 */

// see debug.md for a table describing the st_dout vs st_addr

module jtframe_sys_info(
    input               rst,
    input               clk,
    input               sample,
    input               dip_pause,
    input               LVBL,
    input         [3:0] ba_rdy,
    input         [7:0] st_addr,
    output reg    [7:0] st_dout
);

parameter MFREQ = `JTFRAME_MCLK;
    
// Frame counter
wire [15:0] frame_cnt;
wire        frame_up;
// Frequency reporting
reg  [16:0] freq_cnt=0; // Must be able to count up to 96000
reg  [ 7:0] srate;
wire [ 7:0] scnt;
reg         sl, LVBLl;
wire        sample_clr, sample_up;
// SDRAM stats
wire [ 7:0] stats;

assign frame_up   = LVBL & ~LVBLl & dip_pause;
assign sample_clr = freq_cnt == MFREQ-1;
assign sample_up  = sample & ~sl;

always @(posedge clk, posedge rst) begin
    if( rst ) begin
        LVBLl     <= 0;
        st_dout   <= 0;
    end else begin
        LVBLl <= LVBL;
        case( st_addr[7:6] )
            0: st_dout <= stats;
            1: st_dout <= st_addr[0] ? frame_cnt[15:8] : frame_cnt[7:0];
            2: st_dout <= srate;
            default: st_dout <= 0;
        endcase
    end
end

jtframe_bcd_cnt #(.DIGITS(4)) u_frame_cnt(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .clr        ( 1'b0       ),
    .up         ( frame_up   ),
    .cnt        ( frame_cnt  )
);

jtframe_bcd_cnt #(.DIGITS(2),.WRAP(0)) u_sample_cnt(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .clr        ( sample_clr ),
    .up         ( sample_up  ),
    .cnt        ( scnt       )
);

always @(posedge clk) begin
    sl <= sample;
    freq_cnt <= freq_cnt + 1'd1;
    if( sample_clr ) begin // updated every 1ms
        freq_cnt <= 0;
        srate    <= scnt;
    end
end

jtframe_sdram_stats u_stats(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .rdy        ( ba_rdy        ),
    .LVBL       ( LVBL          ),
    .st_addr    ( st_addr       ),
    .st_dout    ( stats         )
);

endmodule