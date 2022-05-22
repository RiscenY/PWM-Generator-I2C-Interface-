// ---------------------------------- testcase0.v ----------------------------
`include "timescale.v"
`include "i2cSlave_define.v"
`include "i2cSlaveTB_defines.v"

module testCase0();

testHarness u_testHarness();
multiByteReadWrite u_multiByteReadWrite();

//reg ack;
//reg [7:0] data;
reg [31:0] dataWord_high;
reg [31:0] dataWord_low;
//reg [7:0] dataRead;
//reg [7:0] dataWrite;

initial
begin
  $write("\n\n");
  testHarness.reset;
  #1000;

  // set i2c master clock scale reg PRER = (125MHz / (5 * 400KHz) ) - 1 = 3Eh
  $write("Testing register read/write\n");
  testHarness.u_wb_master_model.wb_write(1, `PRER_LO_REG , 8'h3E);
  testHarness.u_wb_master_model.wb_write(1, `PRER_HI_REG , 8'h00);
  testHarness.u_wb_master_model.wb_cmp(1, `PRER_LO_REG , 8'h3E);

  // enable i2c master
  testHarness.u_wb_master_model.wb_write(1, `CTR_REG , 8'h80);

  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'h04, 32'h05323232, `SEND_STOP);
  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'h00, 32'h0000c789, `SEND_STOP);
  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'h00, 32'h0100c789, `SEND_STOP);
  multiByteReadWrite.read({`I2C_ADDRESS, 1'b0}, 8'h04, 32'h0, dataWord_high, `NULL);
  multiByteReadWrite.read({`I2C_ADDRESS, 1'b0}, 8'h00, 32'h0, dataWord_low, `NULL);
  multiByteReadWrite.write({`I2C_ADDRESS, 1'b0}, 8'h00, 32'h0000c789, `SEND_STOP);


  $write("Finished all tests\n");
  $stop;	

end

endmodule

