`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/30 22:42:12
// Design Name: 
// Module Name: pwmGen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pwmGen(
    input                               clksys                     ,
    input                               clkpwm                     ,
    input                               rst_n                      ,
    input              [   7:0]         ctrl                       ,
    input              [  15:0]         fre_div                    ,
    input              [   7:0]         pattern                    ,
    input              [   7:0]         interval0                  ,
    input              [   7:0]         interval1                  ,
    input              [   7:0]         interval2                  ,
    input              [   7:0]         interval3                  ,
    output reg                          pwm                         
    );

wire                   [   3:0]         patternlist                ;
assign patternlist[0] = (pattern[7:6] == 2'b10)? 1'b1:((pattern[7:6] == 2'b01)? 1'b0 : 1'bz);
assign patternlist[1] = (pattern[5:4] == 2'b10)? 1'b1:((pattern[5:4] == 2'b01)? 1'b0 : 1'bz);
assign patternlist[2] = (pattern[3:2] == 2'b10)? 1'b1:((pattern[3:2] == 2'b01)? 1'b0 : 1'bz);
assign patternlist[3] = (pattern[1:0] == 2'b10)? 1'b1:((pattern[1:0] == 2'b01)? 1'b0 : 1'bz);

wire                    [  10:0]        threshold1;
wire                    [  10:0]        threshold2;
wire                    [  10:0]        threshold3;
assign threshold1 = interval0 + interval1;
assign threshold2 = threshold1 + interval2;
assign threshold3 = threshold2 + interval3;

reg                    [  15:0]         pwmcnt                     ;
wire                                    pwmcnt_full                ;
reg                                     pwmcntfull_etd             ;
reg                    [   3:0]         periodcnt                  ;
reg                    [   1:0]         perioddone                 ;

parameter                           IDLE = 1'b0                ;
parameter                           L0 = 1'b1                  ;

reg                                     currentstate, nextstate    ;
reg                    [   2:0]         pwmcurstate                ;

always@(posedge clksys or negedge rst_n) begin
    if(!rst_n) currentstate <= IDLE;
    else currentstate <= nextstate;
end

always@(*) begin
    case(currentstate)
        IDLE:begin
                if(ctrl[0]) nextstate = L0;
                else nextstate = IDLE;
            end
        L0:begin
                if(!ctrl[0]&perioddone[1]) nextstate = IDLE;
                else nextstate = L0;
        end
        default: nextstate = IDLE;
    endcase
end

always@(posedge clkpwm or negedge rst_n) begin
    if(!rst_n) pwmcurstate <= {IDLE, IDLE, IDLE};
    else pwmcurstate[2:0] <= {pwmcurstate[1:0], nextstate};
end

always@(posedge clkpwm or negedge rst_n) begin
    if(!rst_n) pwm <= 1'bz;
    else begin
        case(pwmcurstate[2])
            IDLE: pwm <= 1'bz;
            L0: begin
                if (pwmcnt < interval0) pwm <= patternlist[0];
                else if (pwmcnt  < threshold1) pwm <= patternlist[1];
                else if (pwmcnt  < threshold2) pwm <= patternlist[2];
                else if (pwmcnt  < threshold3) pwm <= patternlist[3];
                else pwm <= 1'bz;
            end
            default: pwm <= 1'bz;
        endcase
    end
end


always@(posedge clkpwm or negedge rst_n) begin
    if(!rst_n) pwmcnt <= 16'h0;
    else begin
        if(pwmcnt >= fre_div) pwmcnt <= 16'h0;
        else pwmcnt <= pwmcnt + 1'b1;
    end
end

assign pwmcnt_full = (pwmcnt == fre_div);


always@(posedge clkpwm or negedge rst_n) begin
    if(!rst_n) begin
        periodcnt <= 4'b0;
        pwmcntfull_etd <= 1'b0;
    end
    else begin
        if(pwmcnt_full) begin
            periodcnt <= periodcnt + 4'b1;
            pwmcntfull_etd <= 1'b1;
        end
        else begin
            if(pwmcntfull_etd) begin
                if(periodcnt >= 4'b1111) begin
                    periodcnt <= 4'b0;
                    pwmcntfull_etd <= 1'b0;
                end
                else begin
                    periodcnt <= periodcnt + 4'b1;
                end
            end
            else begin
                periodcnt <= 4'b0;
            end
        end
    end
end


always@(posedge clksys or negedge rst_n) begin
    if(!rst_n) perioddone <= 2'b0;
    else begin
        perioddone[1:0] <= {perioddone[0], pwmcntfull_etd};
    end
end


endmodule

