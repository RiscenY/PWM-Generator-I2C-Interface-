//////////////////////////////////////////////////////////////////////
////                                                              ////
//// i2cSlaveTop.v                                                   ////
////                                                              ////
//// This file is part of the i2cSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// You will need to modify this file to implement your 
//// interface.
////                                                              ////
//// To Do:                                                       ////
//// 
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Steve Fielding and OPENCORES.ORG          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
`include "i2cSlave_define.v"


module i2cPWM_Top (
  clk,
  rst_n,
//  sdaOutEn,
//  sdaOut,
//  sdaIn,
  sda,
  scl,
  pwm
);
input clk;
input rst_n;
//output sdaOutEn;
//output sdaOut;
//input sdaIn;
inout sda;
input scl;
output wire pwm;

wire sdaOutEn, sdaOut, sdaIn;

assign sda = (sdaOutEn == 1'b0) ? sdaOut : 1'bz;
assign sdaIn = sda;

wire clk_100M, clk_200M;

// interface for pwm control
wire [7:0] ctrl;
wire [15:0] fre_div;
wire [7:0] pattern;
wire [7:0] interval [0:3];

clk_wiz_0 u_clk_gen
(
    // Clock out ports
    .clk_out1(clk_100M),     // output clk_out1
    .clk_out2(clk_200M),     // output clk_out2
    // Status and control signals
    .resetn(rst_n), // input resetn
    .locked(),       // output locked
   // Clock in ports
    .clk_in1(clk));      // input clk_in1

i2cSlave u_i2cSlave(
  .clk(clk_100M),
  .rst(!rst_n),
  .sdaOutEn(sdaOutEn), //active low,
  .sdaOut(sdaOut),
  .sdaIn(sdaIn),
  .scl(scl),
  .myReg0(ctrl),
  .myReg1(fre_div[15:8]),
  .myReg2(fre_div[7:0]),
  .myReg3(pattern),
  .myReg4(interval[0]),
  .myReg5(interval[1]),
  .myReg6(interval[2]),
  .myReg7(interval[3])
);
//
pwmGen u_pwmGen(
  .clksys(clk_100M),
  .clkpwm(clk_200M),
  .rst_n(rst_n),
  .ctrl(ctrl),
  .fre_div(fre_div),
  .pattern(pattern),
  .interval0(interval[0]),
  .interval1(interval[1]),
  .interval2(interval[2]),
  .interval3(interval[3]),
  .pwm(pwm)
);

endmodule


 
