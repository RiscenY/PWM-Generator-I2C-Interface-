// -------------------------- testHarness.v -----------------------
`include "timescale.v"

module testHarness ();

reg rst_n;
reg clk; 
reg i2cHostClk;
wire sda;
wire scl;
wire sdaOutEn;
wire sdaOut;
wire sdaIn;
wire [2:0] adr;
wire [7:0] masterDout;
wire [7:0] masterDin;
wire we;
wire stb;
wire cyc;
wire ack;
wire scl_pad_i;
wire scl_pad_o;
wire scl_padoen_o;
wire sda_pad_i;
wire sda_pad_o;
wire sda_padoen_o;
wire pwm;

initial begin
$dumpfile("wave.vcd");
$dumpvars(0, testHarness); 
end


i2cPWM_Top u_i2cPWM_Top (
  .clk(clk),
  .rst_n(rst_n),
  .sda(sda),
  .scl(scl),
  .pwm(pwm)
);



i2c_master_top #(.ARST_LVL(1'b1)) u_i2c_master_top (
  .wb_clk_i(clk), 
  .wb_rst_i(!rst_n),
  .arst_i(!rst_n),
  .wb_adr_i(adr),
  .wb_dat_i(masterDout),
  .wb_dat_o(masterDin),
  .wb_we_i(we),
  .wb_stb_i(stb),
  .wb_cyc_i(cyc),
  .wb_ack_o(ack),
  .wb_inta_o(),
  .scl_pad_i(scl_pad_i),
  .scl_pad_o(scl_pad_o),
  .scl_padoen_o(scl_padoen_o),
  .sda_pad_i(sda_pad_i),
  .sda_pad_o(sda_pad_o),
  .sda_padoen_o(sda_padoen_o)
);

wb_master_model #(.dwidth(8), .awidth(3)) u_wb_master_model (
  .clk(clk), 
  .rst(!rst_n), 
  .adr(adr), 
  .din(masterDin), 
  .dout(masterDout), 
  .cyc(cyc), 
  .stb(stb), 
  .we(we), 
  .sel(), 
  .ack(ack), 
  .err(1'b0), 
  .rty(1'b0)
);

//assign sda = (sdaOutEn == 1'b0) ? sdaOut : 1'bz;
//assign sdaIn = sda;

assign sda = (sda_padoen_o == 1'b0) ? sda_pad_o : 1'bz;
assign sda_pad_i = sda;
pullup(sda);

assign scl = (scl_padoen_o == 1'b0) ? scl_pad_o : 1'bz;
assign scl_pad_i = scl;
pullup(scl);


// ******************************  Clock section  ******************************
//approx 125MHz clock
`define CLK_HALF_PERIOD 4
always begin
  #`CLK_HALF_PERIOD clk <= 1'b0;
  #`CLK_HALF_PERIOD clk <= 1'b1;
end


// ******************************  reset  ****************************** 
task reset;
begin
  rst_n <= 1'b0;
  #10000
  rst_n <= 1'b1;
  @(posedge clk);
  @(posedge clk);
  @(posedge clk);
end
endtask

endmodule
