`timescale 1ns / 1ps

module ad_converter (
  input  wire       sys_clk      , // -- sys_clk = 100MHz
  input  wire       rst_n        , // -- reset signal
  input  wire [7:0] AD_digits_in , // -- ad digits input
  output reg        AD_clk       , // -- ad clock
  output reg  [7:0] AD_digits_out, // -- ad digits output
  output wire       data_vld
);

  parameter AD_clk_max_cnt = 49;    // -- 1MHz clock counter parameter

  reg [31:0] AD_clk_cnt;
  reg AD_clk_pos_detect_r0;
  reg AD_clk_pos_detect_r1;
  wire AD_clk_neg_detect;
  
  initial begin
    AD_clk_cnt <= 32'd0;
    AD_clk <= 1'b0;
    AD_clk_pos_detect_r0 <= 1'b0;
    AD_clk_pos_detect_r1 <= 1'b0;
  end
  
  // -- AD_clock negedge detect
  assign AD_clk_neg_detect = (!AD_clk_pos_detect_r0 && 
    AD_clk_pos_detect_r1) ? 1'b1: 1'b0;
  always @ (posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      AD_clk_pos_detect_r0 <= 1'b0;
      AD_clk_pos_detect_r1 <= 1'b0;
    end
    else begin
      AD_clk_pos_detect_r0 <= AD_clk;
      AD_clk_pos_detect_r1 <= AD_clk_pos_detect_r0;
    end
  end
  
  // -- 1MHz clock generator
  always @ (posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      AD_clk_cnt <= 32'd0;
      AD_clk <= 1'b0;
    end
    else if (AD_clk_cnt == AD_clk_max_cnt) begin
      AD_clk_cnt <= 32'd0;
      AD_clk <= ~ AD_clk;
    end
    else if (AD_clk_cnt != AD_clk_max_cnt) begin
      AD_clk_cnt <= AD_clk_cnt + 1;
    end
  end
  
  // -- synchronize data
  always @ (posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      AD_digits_out <= 8'd0;
    end
    else begin
      AD_digits_out <= AD_digits_in;
    end
  end
  
  // -- buffer done flag
  assign data_vld = AD_clk_neg_detect;

endmodule
