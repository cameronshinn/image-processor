//============================================================================
// top.v
//
// Do not modify this file (unless you are sure you need to)
//
// This code is generated by Terasic System Builder and modified by 
// M. Hildebrand and B. Baas
//
// 2018/02/05 First version
// 2018/04/24 Routed all board-level push buttons and switches to, and LEDs 
//            and displays from, the module comb_ckt_generator
//============================================================================

module top (
   //////////// CLOCKS //////////
   input               ADC_CLK_10,
   input               MAX10_CLK1_50,
   input               MAX10_CLK2_50,

   //////////// VGA SIGNALS //////////
   output reg [3:0]    VGA_R,
   output reg [3:0]    VGA_G,
   output reg [3:0]    VGA_B,
   output reg          VGA_HS,
   output reg          VGA_VS,

   //////////// KEYs //////////
   input      [1:0]    KEY,    // two board-level push buttons KEY1 - KEY0

   //////////// SWs //////////
   input      [9:0]    SW,     // ten board-level switches SW9 - SW0

   //////////// LEDs //////////
   output     [9:0]    LEDR,   // ten board-level LEDs LEDR9 - LEDR0

   //////////// 7-SEGMENT DISPLAYS //////////
   output     [7:0]    HEX0,   // board-level 7-segment display
   output     [7:0]    HEX1,   // board-level 7-segment display
   output     [7:0]    HEX2,   // board-level 7-segment display
   output     [7:0]    HEX3,   // board-level 7-segment display
   output     [7:0]    HEX4,   // board-level 7-segment display
   output     [7:0]    HEX5    // board-level 7-segment display
);


//============================================================================
//  reg and wire declarations
//============================================================================

// Signals for drawing to the display. 
wire [31:0]    col, row;
wire [3:0]     red, green, blue;

// Timing signals - don't touch these.
wire           h_sync, v_sync;
wire           disp_ena;
wire           vga_clk;

//============================================================================
// Your combinational logic block that determines RGB color outputs given
// a certain row and column pixel address. Also has all KEY push button and 
// SW switch values. The module also determines what is displayed on the
// LEDR LEDs and the HEX displays.
//============================================================================
comb_ckt_generator comb_ckt (
   .col   (col[9:0]),   // only bottom 10 bits needed to count to 640
   .row   (row[8:0]),   // only bottom 9 bits needed to count to 480
   .red   (red),        // 4-bit color output
   .green (green),      // 4-bit color output
   .blue  (blue),       // 4-bit color output
   .KEY   (KEY),        // two board-level push buttons KEY1 - KEY0
   .SW    (SW),         // ten board-level switches SW9 - SW0
   .LEDR  (LEDR),       // ten board-level LEDs LEDR9 - LEDR0
   .HEX0  (HEX0),       // board-level 7-segment display
   .HEX1  (HEX1),       // board-level 7-segment display
   .HEX2  (HEX2),       // board-level 7-segment display
   .HEX3  (HEX3),       // board-level 7-segment display
   .HEX4  (HEX4),       // board-level 7-segment display
   .HEX5  (HEX5)        // board-level 7-segment display
   );

//============================================================================
// Display-related and PLL stuff. Don't touch!
//============================================================================

// Register VGA output signals for timing purposes
always @(posedge vga_clk) begin
   if (disp_ena == 1'b1) begin
      VGA_R <= red;
      VGA_B <= blue;
      VGA_G <= green;
   end else begin
      VGA_R <= 4'd0;
      VGA_B <= 4'd0;
      VGA_G <= 4'd0;
   end
   VGA_HS <= h_sync;
   VGA_VS <= v_sync;
end

// Instantiate PLL to convert the 50 MHz clock to a 25 MHz clock for timing.
pll vgapll_inst (
    .inclk0    (MAX10_CLK1_50),
    .c0        (vga_clk)
    );

// Instantite VGA controller
vga_controller control (
   .pixel_clk  (vga_clk),
   .reset_n    (KEY[0]),
   .h_sync     (h_sync),
   .v_sync     (v_sync),
   .disp_ena   (disp_ena),
   .column     (col),
   .row        (row)
   );

endmodule

