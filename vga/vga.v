`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//VS:￣￣￣￣￣￣|_____|￣￣￣￣￣￣￣￣￣￣￣￣|____|￣￣￣￣￣￣￣￣￣￣￣￣|_______
//
//HS:￣￣￣￣￣￣|_____|￣|_|￣|...|_|￣|_|￣|____|￣|_|￣|...|_|￣|_|￣|_____
//
//VS:￣￣￣￣￣￣|_____|￣￣￣￣￣￣￣￣￣￣￣￣|____|￣￣￣￣￣￣￣￣￣￣￣￣|_______
//        ^   ^     ^   ^          ^    ^    ^ 
//T:      d (e)a    b   c          d    e
//        front sync back           front 
//////////////////////////////////////////////////////////////////////////////////

module vga (
  input  wire        clk_i  , // -- input clock = 25MHz
  input  wire        rst_n  , // -- reset signal
  output wire        hsync  , // -- hsync signal
  output wire        vsync  , // -- vsync signal
  output wire [9: 0] hcnt_o , // -- herizontal pixel counter
  output wire [9: 0] vcnt_o , // -- vertical pixel counter
  output wire        pix_vld, // -- pixel valid
);

  // -- Herizontal parameters
  parameter LinePeriod   = 800;
  parameter H_SyncPulse  =  96;
  parameter H_FrontPorch =  16;
  parameter H_BackPorch  =  48;
  parameter H_ActivePix  = 640;
  parameter Hde_Start    = 144;
  parameter Hde_End      = 784;

  // -- Vertical parameters
  parameter FramePeriod  = 525;
  parameter V_SyncPulse  =   2;
  parameter V_FrontPorch =  10;
  parameter V_BackPorch  =  33;
  parameter V_ActivePix  = 480;
  parameter Vde_Start    =  35;
  parameter Vde_End      = 515;

  reg H_vld_r, V_vld_r;
  reg [9: 0] hcnt_r, vcnt_r;

  assign pix_vld = H_vld_r && V_vld_r;

  always @ (posedge clk_i or negedge rst_n) begin
    if (hcnt_r < LinePeriod)
      hcnt_r <= hcnt_r + 1;
    else
      hcnt_r <= 0;
  end

  always @ (posedge clk_i or negedge rst_n) begin
    if ((hcnt_r >= (H_ActivePix + H_FrontPorch)) &&
      (hcnt_r < (H_ActivePix + H_SyncPulse + H_FrontPorch)))
      hsync_r <= 0;
    else
      hsync_r <= 1;
  end

  always @ (posedge clk_i or negedge rst_n) begin
    if (hcnt_r == (H_ActivePix + H_SyncPulse + H_FrontPorch)) begin
      if (vcnt_r < FramePeriod)
        vcnt_r <= vcnt_r + 1;
      else
        vcnt_r <= 0;
    end
  end

  always @ (posedge clk_i or negedge rst_n) begin
    if ((vcnt_r >= (V_ActivePix + V_FrontPorch)) &&
      (vcnt_r < (V_ActivePix + V_SyncPulse + V_FrontPorch)))
      vsync_r <= 0;
    else
      vsync_r <= 1;
  end    

  always @ (posedge clk_i or negedge rst_n) begin
    if (hcnt_r < H_ActivePix)
      H_vld_r <= 1;
    else
      H_vld_r <= 0;
  end

  always @ (posedge clk_i or negedge rst_n) begin    
    if (vcnt_r < V_ActivePix)
      V_vld_r <= 1;
    else
      V_vld_r <= 0;
  end

  assign vcnt_o = (V_vld_r == 1 && H_vld_r == 1) ? vcnt_r - (Vde_Start + 1) : 10'd0;
  assign hcnt_o = (V_vld_r == 1 && H_vld_r == 1) ? hcnt_r - (Hde_Start + 1) : 10'd0;

endmodule
