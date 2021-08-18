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
    Date: 20-5-2021 */

/*

    Generates the standard /DTACK signal expected by the CPU,
    i.e. there is an idle cycle for each bus cycle

    If there is a special bus access, marked by bus_cs, and
    it takes longer to complete than one cycle, the extra time
    will be recovered for later. If bus_legit is high, the time
    will not be recovered as it is identified as legitim wait
    in the original system

    BUSn -and not just ASn- must be used so read-modify-write
    instructions have a second /DTACK signal generated for
    the write cycle

    Note that if jtframe_ramrq is used, then BUSn must also
    gate the SDRAM requests so you get a cs toggle in the
    middle of the read-modify-write cycles

*/

module jtframe_68kdtack
#(parameter W=5, RECOVERY=1, WD=6
)(
    input         rst,
    input         clk,
    output   reg  cpu_cen,
    output   reg  cpu_cenb,
    input         bus_cs,
    input         bus_busy,
    input         bus_legit,
    input         BUSn,   // BUSn = ASn | (LDSn & UDSn)
    input [W-1:0] num,  // numerator
    input [W-1:0] den,  // denominator

    output reg  DTACKn
);

localparam CW=W+WD;

reg [CW-1:0] cencnt=0;
reg wait1, halt;
wire over = cencnt>=den-1;

`ifdef SIMULATION
real rnum = num;
real rden = den;
initial begin
    if( rnum/rden<=3 ) begin
        $display("Error: den must be 3 or more, otherwise recovery won't work (%m)");
        $finish;
    end
end
`endif

always @(posedge clk, posedge rst) begin : dtack_gen
    if( rst ) begin
        DTACKn <= 1'b1;
        wait1  <= 1;
        halt   <= 0;
    end else begin
        if( BUSn ) begin // DSn is needed for read-modify-write cycles
            DTACKn <= 1;
            wait1  <= 1;
            halt   <= 0;
        end else if( !BUSn ) begin
            if( cpu_cen  ) wait1 <= 0;
            if( !wait1 ) begin
                if( !bus_cs || (bus_cs && !bus_busy) ) begin
                    DTACKn <= 0;
                    halt <= 0;
                end else begin
                    halt <= !bus_legit;
                end
            end
        end
    end
end

always @(posedge clk) begin
    cencnt  <= (over && !cpu_cen && (!halt || RECOVERY==0)) ? (cencnt+num-den) : (cencnt+num);
    if( halt ) begin
        cpu_cen  <= 0;
        cpu_cenb <= 0;
    end else begin
        cpu_cen <= over ? ~cpu_cen : 0;
        cpu_cenb<= cpu_cen;
    end
end

endmodule