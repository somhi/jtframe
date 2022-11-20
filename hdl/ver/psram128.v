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
    Date: 20-11-2022 */

// Pseudo SRAM
// simple simulation model based on AS1C8M16PL-70BIN data sheet

module psram128(
    input   [21:16] a,
    input   [  1:0] cen,
    input           clk,
    input           advn,
    input           wen,
    input           oen,
    input           cre,
    input           lbn,
    input           ubn,
    output          wt,
    inout   [15 :0] adq
);

    psram64 u_psram0(
        .a    ( a     ),
        .cen  ( cen[0]),
        .clk  ( clk   ),
        .advn ( advn  ),
        .wen  ( wen   ),
        .oen  ( oen   ),
        .cre  ( cre   ),
        .lbn  ( lbn   ),
        .ubn  ( ubn   ),
        .wt   ( wt    ),
        .adq  ( adq   )
    );

    psram64 u_psram1(
        .a    ( a     ),
        .cen  ( cen[1]),
        .clk  ( clk   ),
        .advn ( advn  ),
        .wen  ( wen   ),
        .oen  ( oen   ),
        .cre  ( cre   ),
        .lbn  ( lbn   ),
        .ubn  ( ubn   ),
        .wt   ( wt    ),
        .adq  ( adq   )
    );

endmodule

module psram64(
    input   [21:16] a,
    input           cen,
    input           clk,
    input           advn,
    input           wen,
    input           oen,
    input           cre,
    input           lbn,
    input           ubn,
    inout           wt,
    inout    [15:0] adq
);

reg [15:0] mem[0:2**22-1];
reg [21:0] addr;
reg [ 2:0] wtk;
reg [ 3:0] st;
reg        wt_reg, do_rd, do_cfg;

localparam [3:0] IDLE  = 0,
                 WAIT  = 1,
                 READ  = 2,
                 WRITE = 3;

assign adq = (!oen && !cen) ? mem[addr] : 16'hzzzz;
assign wt  = cen ? 1'bz : wt_reg;

integer k;
initial begin
    wt_reg <= 0;
    st <= IDLE;
    for(k=0;k<2*22-1;k++) mem[k] = 0;
end

always @(posedge clk) begin
    case( st )
        IDLE: begin
            do_rd  <= 0;
            do_cfg <= 0;
            if( !cen && !advn && !cre ) begin
                do_rd <= wen;
                addr  <= { a, adq };
                wt_reg<= 0;
                wtk   <= 3;
                st    <= WAIT;
            end
            if( !cen && !advn && cre ) begin
                do_cfg <= 1;   // the cre function isn't implemented
                wt_reg<= 0;     // just a work around so it won't halt the sim
                wtk   <= 3;
                st    <= WAIT;
            end
        end
        WAIT: begin
            if( wtk==0 ) st <= do_cfg ? IDLE : do_rd ? READ : WRITE;
            wt_reg <= wtk==0;
            wtk <= wtk-1;
        end
        READ: begin
            wt_reg <= 0;
            addr   <= addr + 1'd1;
            if( cen ) st <= IDLE;
        end
        WRITE: begin
            wt_reg <= 0;
            addr   <= addr + 1'd1;
            if( cen ) 
                st <= IDLE;
            else
                mem[addr] <= { ubn ? mem[addr][15:8] : adq[15:8], lbn ? mem[addr][7:0] : adq[7:0] };
        end
    endcase
end

endmodule