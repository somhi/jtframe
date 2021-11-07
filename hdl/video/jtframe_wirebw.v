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
    Date: 25-9-2019 */

module jtframe_wirebw #(parameter WIN=4, WOUT=5) (
    input  clk,
    input  spl_in,
    input  [WIN-1:0] r_in,
    input  [WIN-1:0] g_in,
    input  [WIN-1:0] b_in,
    input  HS_in,
    input  VS_in,
    input  HB_in,
    input  VB_in,
    input  enable,
    // filtered video
    output            HS_out,
    output            VS_out,
    output            HB_out,
    output            VB_out,
    output [WOUT-1:0] r_out,
    output [WOUT-1:0] g_out,
    output [WOUT-1:0] b_out
);

wire [3:0] dly;

jtframe_sh #(.width(4), .stages(4)) u_sh(
    .clk    ( clk              ),
    .clk_en ( spl_in           ),
    .din    ( {HS_in,  VS_in,  HB_in,  VB_in  } ),
    .drop   ( dly              )
);

assign {HS_out, VS_out, HB_out, VB_out } =
    enable ? dly : {HS_in,  VS_in,  HB_in,  VB_in  };

jtframe_wirebw_unit #(.WIN(WIN),.WOUT(WOUT)) u_rfilter(
    .clk    ( clk       ),
    .spl_in ( spl_in    ),
    .enable ( enable    ),
    .din    ( r_in      ),
    .dout   ( r_out     )
);

jtframe_wirebw_unit #(.WIN(WIN),.WOUT(WOUT)) u_gfilter(
    .clk    ( clk       ),
    .spl_in ( spl_in    ),
    .enable ( enable    ),
    .din    ( g_in      ),
    .dout   ( g_out     )
);

jtframe_wirebw_unit #(.WIN(WIN),.WOUT(WOUT)) u_bfilter(
    .clk    ( clk       ),
    .spl_in ( spl_in    ),
    .enable ( enable    ),
    .din    ( b_in      ),
    .dout   ( b_out     )
);

endmodule

module jtframe_wirebw_unit #(
    parameter WIN  = 4, // input data width
              WOUT = 6, // output data width
              WC   = 5, // coefficient width
              N    = 5, // order, this is only meant to be used with N=3, 5, 7 atmost
              AW=WIN+WC+3, // accumulator width
    parameter [N*WC-1:0] COEFF = { 5'd0, 5'd7, 5'd20, 5'd7, 5'd0 }
) (
    input   clk,        // at least N clock pulses between spl_in strobes
    input   spl_in,     // input sample strobe
    input   [WIN-1:0] din,
    input   enable,
    output  [WOUT-1:0] dout
);

localparam MW=WIN*N; // memory width

reg [  MW-1:0] mem;
reg [N*WC-1:0] coeff;
reg [     N:0] steps;
reg [  AW-1:0] acc, prod, result;
reg            run;
reg [WOUT-1:0] pdout;

wire [N*WC-1:0] coeff_rotate = { coeff[WC*(N-1)-1:0], coeff[N*WC-1:N*(WC-1)] };
wire [  MW-1:0] mem_rotate   = { mem[MW-WIN-1:0], mem[MW-1:MW-WIN] };

always @( coeff, mem ) begin
    prod = coeff[WC-1:0] * mem[WIN-1:0];
end

always @(*) begin
    result = acc >> (WC-(WOUT-WIN));
    if ( result > {WOUT{1'b1}} ) result = { {AW-WOUT{1'b0}}, {WOUT{1'b1}} } ;
end

function [WOUT-1:0] ext; // extends the input from WIN to WOUT
    input [WIN-1:0] a;
    ext = { a, {WOUT-WIN{1'b0}} } | (a>>(2*WIN-WOUT)) ;
endfunction

// Mux it to avoid adding a clock cycle
assign dout = enable ? pdout : ext(din);

always @( posedge clk ) begin
    if( spl_in ) begin
        mem   <= { mem[MW-WIN-1:0], din };
        run   <= enable;
        acc   <= {AW{1'd0}};
        steps <= {{N{1'd0}}, 1'd1};
        coeff <= COEFF;
        pdout <= result[WOUT-1:0];
    end else if(!steps[N]) begin
        steps <= steps<<1;
        acc   <= acc + prod;
        if( run ) begin
            coeff <= coeff_rotate;
            mem   <= mem_rotate;
        end
        if( steps[N-1] ) run <= 1'd0;
    end
end

endmodule