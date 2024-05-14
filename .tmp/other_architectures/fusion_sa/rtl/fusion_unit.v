`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.11.2023 12:43:35
// Design Name: 
// Module Name: fusion_unit
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

//***** Define Full-Adders and Half-Adders *****//
module full_adder(input a, input b, input ci, output sum, output co);
    assign sum = a ^ b ^ ci;
    assign co = (a & b) | (b & ci) | (ci & a);
endmodule

module half_adder(input a, input b, output sum, output co);
    assign sum = a ^ b;
    assign co = a & b;
endmodule

//***** BitBrick Unit or 3x3 Baugh-Wooley Multiplier *****//
module bitbrick(
    input [1:0] x, // 2-bit Inputs
    input [1:0] y,
    input sx, // Control Flag Signals for Signed (1) or Unsigned Input (0)
    input sy,
    output [5:0] p
    );
       
    // Initialize 3-bit Operands (Extend 2-bits Unsigned or create 3-bits Signed)
    wire [2:0] xi, yi;
    assign xi = {sx & x[1] , x};
    assign yi = {sy & y[1] , y};
       
    // Multiplier
    wire [2:0] pp0, pp1, pp2; // PPG
    
    // Partial Product Generation (PPG)
    assign pp0 = {~(xi[2] & yi[0]), (xi[1] & yi[0]), (xi[0] & yi[0])};
    assign pp1 = {~(xi[2] & yi[1]), (xi[1] & yi[1]), (xi[0] & yi[1])};
    assign pp2 = {(xi[2] & yi[2]), ~(xi[1] & yi[2]), ~(xi[0] & yi[2])};    
    
    // Partial Product Reduction (PPR) - Following Actual Implementation 
    assign p[0] = pp0[0];  // p[0]
    
    wire HA_p1_co;
    half_adder HA_p1 (.a(pp0[1]), .b(pp1[0]), .sum(p[1]), .co(HA_p1_co)); // p[1]
    
    wire HA_p2_co, FA_p2_co, HA_p2_in;
    full_adder FA_p2 (.a(pp1[1]), .b(pp2[0]), .ci(HA_p1_co), .sum(HA_p2_in), .co(FA_p2_co));
    half_adder HA_p2 (.a(pp0[2]), .b(HA_p2_in), .sum(p[2]), .co(HA_p2_co)); // p[2]
    
    wire HA_p3_co, FA_p3_co, HA_p3_in;
    full_adder FA_p3b (.a(pp1[2]), .b(pp2[1]), .ci(FA_p2_co), .sum(HA_p3_in), .co(FA_p3_co));
    full_adder FA_p3a (.a(HA_p3_in), .b(HA_p2_co), .ci(1'b1), .sum(p[3]), .co(HA_p3_co)); // p[3] + 1'b1 on nth bit
//    half_adder HA_p3 (.a(HA_p3_in), .b(HA_p2_co), .sum(p[3]), .co(HA_p3_co)); // p[3]
    
    wire FA_p4_co, HA_p5_in;
    full_adder FA_p4 (.a(pp2[2]), .b(FA_p3_co), .ci(HA_p3_co), .sum(p[4]), .co(HA_p5_in)); // p[4]
//    full_adder FA_p4 (.a(pp2[2]), .b(FA_p3_co), .ci(HA_p3_co), .sum(p[4]), .co(p[5])); // p[4] & p[5]
        
    assign p[5] = ~(HA_p5_in); // Invert Sign Bit
    
//    assign p = xi * yi;
    
endmodule

//***** Top-Level (Original) Fusion Unit *****//
module fusion_unit (
    input [7:0] x,
    input [7:0] y,
    input sx,
    input sy,
    input [1:0] mode,
    input clk,
    input en,
    input nrst,
    output reg [63:0] product,
    output reg [127:0] sum
    );

    //** Configuration/Mode Parameters **//    
    localparam _2bx2b = 2'b00;                  
    localparam _4bx4b = 2'b01;                  
    localparam _8bx8b = 2'b10;               
                                                   
    //** Decomposition of 8bx8b input into four 4bx4b inputs or into 2bx2b inputs **//
    wire [3:0] xh, xl, yh, yl;
    assign xh = x[7:4]; assign xl = x[3:0];
    assign yh = y[7:4]; assign yl = y[3:0];   

    // Instantiate four bitbricks (BB) inside the fusion unit (FU) to handle 4b x 4b Multiplication 
    // Create 4 blocks of 4b x 4b BB to handle 8b x 8b
    // Notation: bb_xy_z where x and y represent positions of either high or low half and z as the block number
    // M = N = 8, n = m = 4

    // Control Signals (sx, sy, mode) Logic
    // By default, sx and sy are mapped to the 8bx8b datapath.
    // Otherwise, it checks on the respective BitBricks for the current mode (==) AND the current sign-bit (sx,sy)

    // eg. sx on the BitBrick with all MSBs in the 8bx8b datapath would not be triggered as signed input unless
    //     the current mode is 2bx2b and sx = 1 which implies that all the 2-bit inputs across all (16) BitBricks
    //     will be processed as signed inputs.
    
    // Block 1 = High-High, x[7:4] * y[7:4]
    wire [5:0] pp_hh_1, pp_hl_1, pp_lh_1, pp_ll_1;
    bitbrick bb_hh_1(.x(xh[3:2]), .y(yh[3:2]), .sx(sx), .sy(sy), .p(pp_hh_1)); 
    bitbrick bb_hl_1(.x(xh[3:2]), .y(yh[1:0]), .sx(sx), .sy(mode == _2bx2b && sy), .p(pp_hl_1));
    bitbrick bb_lh_1(.x(xh[1:0]), .y(yh[3:2]), .sx(mode == _2bx2b && sx), .sy(sy), .p(pp_lh_1));
    bitbrick bb_ll_1(.x(xh[1:0]), .y(yh[1:0]), .sx(mode == _2bx2b && sx), .sy(mode == _2bx2b && sy), .p(pp_ll_1));
    
    wire [7:0] pp_hh;
    assign pp_hh = (pp_ll_1 + {pp_hl_1, 2'b0} + {pp_lh_1, 2'b0} + {pp_hh_1, 4'b0});

    //  Block 2 = High-Low, x[7:4] * y[3:0]
    wire [5:0] pp_hh_2, pp_hl_2, pp_lh_2, pp_ll_2;
    bitbrick bb_hh_2(.x(xh[3:2]), .y(yl[3:2]), .sx(sx), .sy((mode == _4bx4b && sy) | (mode == _2bx2b && sy)), .p(pp_hh_2)); 
    bitbrick bb_hl_2(.x(xh[3:2]), .y(yl[1:0]), .sx(sx), .sy(mode == _2bx2b && sy), .p(pp_hl_2));
    bitbrick bb_lh_2(.x(xh[1:0]), .y(yl[3:2]), .sx(mode == _2bx2b && sx), .sy((mode == _4bx4b && sy) | (mode == _2bx2b && sy)), .p(pp_lh_2));
    bitbrick bb_ll_2(.x(xh[1:0]), .y(yl[1:0]), .sx(mode == _2bx2b && sx), .sy(mode == _2bx2b && sy), .p(pp_ll_2));
    
    wire [7:0] pp_hl;
    assign pp_hl = (pp_ll_2 + {pp_hl_2, 2'b0} + {pp_lh_2, 2'b0} + {pp_hh_2, 4'b0});

    //  Block 3 = Low-High, x[3:0] * y[7:4]
    wire [5:0] pp_hh_3, pp_hl_3, pp_lh_3, pp_ll_3;
    bitbrick bb_hh_3(.x(xl[3:2]), .y(yh[3:2]), .sx((mode == _4bx4b && sx) | (mode == _2bx2b && sx)), .sy(sy), .p(pp_hh_3)); 
    bitbrick bb_hl_3(.x(xl[3:2]), .y(yh[1:0]), .sx((mode == _4bx4b && sx) | (mode == _2bx2b && sx)), .sy(mode == _2bx2b & sy), .p(pp_hl_3));
    bitbrick bb_lh_3(.x(xl[1:0]), .y(yh[3:2]), .sx(mode == _2bx2b && sx), .sy(sy), .p(pp_lh_3));
    bitbrick bb_ll_3(.x(xl[1:0]), .y(yh[1:0]), .sx(mode == _2bx2b && sx), .sy(mode == _2bx2b && sy), .p(pp_ll_3));
    
    wire [7:0] pp_lh;
    assign pp_lh = (pp_ll_3 + {pp_hl_3, 2'b0} + {pp_lh_3, 2'b0} + {pp_hh_3, 4'b0});  
    
    //  Block 4 = Low-Low, x[3:0] * y[3:0]
    wire [5:0] pp_hh_4, pp_hl_4, pp_lh_4, pp_ll_4;
    bitbrick bb_hh_4(.x(xl[3:2]), .y(yl[3:2]), .sx((mode == _4bx4b && sx) | (mode == _2bx2b && sx)), .sy((mode == _4bx4b && sy) | (mode == _2bx2b && sy)), .p(pp_hh_4)); 
    bitbrick bb_hl_4(.x(xl[3:2]), .y(yl[1:0]), .sx((mode == _4bx4b && sx) | (mode == _2bx2b && sx)), .sy(mode == _2bx2b && sy), .p(pp_hl_4));
    bitbrick bb_lh_4(.x(xl[1:0]), .y(yl[3:2]), .sx(mode == _2bx2b && sx), .sy((mode == _4bx4b && sy) | (mode == _2bx2b && sy)), .p(pp_lh_4));
    bitbrick bb_ll_4(.x(xl[1:0]), .y(yl[1:0]), .sx(mode == _2bx2b && sx), .sy(mode == _2bx2b && sy), .p(pp_ll_4));
    
    wire [7:0] pp_ll;
    assign pp_ll = (pp_ll_4 + {pp_hl_4, 2'b0} + {pp_lh_4, 2'b0} + {pp_hh_4, 4'b0});    

    //** Output Product Mapping based on chosen mode **//
    always@(*) begin
        case(mode)
            _8bx8b: begin
                // Signed-Bit Extension for pp_hl and pp_lh depending on sx and sy
                product[15:0] = {{8{1'b0}}, pp_ll} + {{4{(pp_lh[7] & sy)}}, pp_lh, 4'b0} + {{4{(pp_hl[7] & sx)}}, pp_hl, 4'b0} + {pp_hh, 8'b0};
                product[63:16] = 0;
            end
            
            _4bx4b: begin
                // Must map 4x8b BitBrick products to 64-bit output product register
                product[31:0] = {pp_hh, pp_hl, pp_lh, pp_ll};         
                product[63:32] = 0; 
            end
            
            _2bx2b: begin
                // Must map 16x4b BitBrick products to 64-bit output product register
                product = {pp_hh_1[3:0], pp_hl_1[3:0], pp_lh_1[3:0], pp_ll_1[3:0], 
                           pp_hh_2[3:0], pp_hl_2[3:0], pp_lh_2[3:0], pp_ll_2[3:0], 
                           pp_hh_3[3:0], pp_hl_3[3:0], pp_lh_3[3:0], pp_ll_3[3:0], 
                           pp_hh_4[3:0], pp_hl_4[3:0], pp_lh_4[3:0], pp_ll_4[3:0]};
            end

            default: product = 0;
        endcase
    end 


    //** Output Accumulator Mapping based on chosen mode **//
    reg [1:0] mode_buffer; // Create buffer to check when precision mode changes for resetting sum/accumulator
    always@(posedge clk) begin
        if(!nrst) begin
            mode_buffer <= 2'b11;
        end else begin
            mode_buffer <= mode; 
        end
    end

    always@(posedge clk) begin
        if (!nrst) begin
            sum <= 0;
        end else begin
            // Empty the sum when switching modes
            if (mode != mode_buffer) begin 
                // Check if the MAC Engine is in idle and the precision mode changes
                sum <= 0;
            end else begin
                // Otherwise, proceed with scaled accumulate operation if enabled
                if(en) begin
                    case(mode)
                        _8bx8b: begin
                            // Extend sign bit of 16-bit product in 8bx8b mode then accumulated to fit 20-bit sum when adding
                            sum[19:0] <= (sum[19:0] + {{4{product[15]}}, product[15:0]});                    
                            sum[127:20] <= 0;
                        end

                        _4bx4b: begin
                            // Map the 32-bit product register (4x8b products) to fit 4x12b = 48-bit sum w/ sign extend to 12b
                            sum[11:0] <= (sum[11:0] + {{4{product[7]}}, product[7:0]});
                            sum[23:12] <= (sum[23:12] + {{4{product[15]}}, product[15:8]});
                            sum[35:24] <= (sum[35:24] + {{4{product[23]}}, product[23:16]});
                            sum[47:36] <= (sum[47:36] + {{4{product[31]}}, product[31:24]});
                            sum[127:48] <= 0;
                        end

                        _2bx2b: begin
                            // Map the 64-bit product register (16x4b products) to fit 16x8b = 128-bit sum w/ sign extend to 8b
                            sum[7:0] <= (sum[7:0] + {{4{product[3]}}, product[3:0]});
                            sum[15:8] <= (sum[15:8] + {{4{product[7]}}, product[7:4]});
                            sum[23:16] <= (sum[23:16] + {{4{product[11]}}, product[11:8]});
                            sum[31:24] <= (sum[31:24] + {{4{product[15]}}, product[15:12]});
                            sum[39:32] <= (sum[39:32] + {{4{product[19]}}, product[19:16]});
                            sum[47:40] <= (sum[47:40] + {{4{product[23]}}, product[23:20]});
                            sum[55:48] <= (sum[55:48] + {{4{product[27]}}, product[27:24]});
                            sum[63:56] <= (sum[63:56] + {{4{product[31]}}, product[31:28]});
                            sum[71:64] <= (sum[71:64] + {{4{product[35]}}, product[35:32]}); //
                            sum[79:72] <= (sum[79:72] + {{4{product[39]}}, product[39:36]});
                            sum[87:80] <= (sum[87:80] + {{4{product[43]}}, product[43:40]}); //
                            sum[95:88] <= (sum[95:88] + {{4{product[47]}}, product[47:44]}); //
                            sum[103:96] <= (sum[103:96] + {{4{product[51]}}, product[51:48]});
                            sum[111:104] <= (sum[111:104] + {{4{product[55]}}, product[55:52]});
                            sum[119:112] <= (sum[119:112] + {{4{product[59]}}, product[59:56]}); //
                            sum[127:120] <= (sum[127:120] + {{4{product[63]}}, product[63:60]}); //                        
                        end

                        default: sum <= 0;
                    endcase
                end
            end
        end
    end    

//    assign product = pp_ll + {pp_lh, 4'b0} + {pp_hl, 4'b0} + {pp_hh, 8'b0};
//    assign product = {{8{1'b0}}, pp_ll} + {{4{(pp_lh[7] & sy)}}, pp_lh, 4'b0} + {{4{(pp_hl[7] & sx)}}, pp_hl, 4'b0} + {pp_hh, 8'b0}; // Signed-Bit Extension for pp_hl and pp_lh depending on sx and sy
//    assign product = {{8{pp_ll[7]}}, pp_ll} + {{4{pp_lh[7]}}, pp_lh} + {{4{pp_hl[7]}}, pp_hl} + pp_hh;
    
    // 4b x 4b Datapath Control Signal Positions (sx, sy)
//    wire [5:0] pp_hh, pp_hl, pp_lh, pp_ll; // 4b x 4b multiplication sign flags
//    bitbrick bb_hh(.x(xh), .y(yh), .sx(sx), .sy(sy), .p(pp_hh)); 
//    bitbrick bb_hl(.x(xh), .y(yl), .sx(sx), .sy(1'b0), .p(pp_hl));
//    bitbrick bb_lh(.x(xl), .y(yh), .sx(1'b0), .sy(sy), .p(pp_lh));
//    bitbrick bb_ll(.x(xl), .y(yl), .sx(1'b0), .sy(1'b0), .p(pp_ll));
    
//    assign product = pp_ll + {pp_lh, 2'b0} + {pp_hl, 2'b0} + {pp_hh, 4'b0};
       
endmodule
