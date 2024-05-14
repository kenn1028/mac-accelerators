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

//***** Simplified BitBrick (sBB) Unit or 3x3 Baugh-Wooley Multiplier *****//
module s_bitbrick(
    input [1:0] x, // 2-bit Inputs
    input [1:0] y,
    input sx, // Control Flag Signals for Signed (1) or Unsigned Input (0)
    input sy,
    output [4:0] p // Reduced product to 5-bits
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
    
    wire HA_p5_in;
    assign p[4] = (xi[2] ^ yi[2]) & (xi[1] | xi[0]) & (yi[1] | yi[0]); // Simplified expression for p[4]     
endmodule

module signbit_ctrl (
    input sx, input sy,
    input [3:0] mode,
    output reg [4:1] hh_sx, output reg [4:1] hl_sx, output reg [4:1] lh_sx, output reg [4:1] ll_sx,
    output reg [4:1] hh_sy, output reg [4:1] hl_sy, output reg [4:1] lh_sy, output reg [4:1] ll_sy    
    );
    
    //** Configuration/Mode Parameters **//    
    localparam _2bx2b = 4'd0; 
    localparam _4bx4b = 4'd1; 
    localparam _8bx8b = 4'd2;                   

    // Assign BitBricks that are always connected to the signed/unsigned control signals (Default: 8bx8b Mode)
    always@(*) begin
        {hh_sx[2:1], hl_sx[2:1]} = {4{sx}};
        {hh_sy[1], hh_sy[3], lh_sy[1], lh_sy[3]} = {4{sy}};
    end

    //** Control Signal for Input Activations (sx) **//
    always@(*) begin
        case(mode)
            _2bx2b: begin
                {hh_sx[4:3], hl_sx[4:3]} = {4{sx}};
                {lh_sx[4:1], ll_sx[4:1]} = {8{sx}};
            end

            _4bx4b: begin
                {hh_sx[4:3], hl_sx[4:3]} = {4{sx}};
                {lh_sx[4:1], ll_sx[4:1]} = 8'b0;
            end

            default: begin
                {hh_sx[4:3], hl_sx[4:3]} = 4'b0;
                {lh_sx[4:1], ll_sx[4:1]} = 8'b0;
            end
        endcase
    end

    //** Control Signal for Input Weights (sy) **//
    always@(*) begin
        case(mode)
            _2bx2b: begin
                {hh_sy[2], hh_sy[4]} = {2{sy}};
                hl_sy[4:1] = {4{sy}};
                {lh_sy[2], lh_sy[4]} = {2{sy}};
                ll_sy[4:1] = {4{sy}};               
            end

            _4bx4b: begin
                {hh_sy[2], hh_sy[4]} = {2{sy}};
                hl_sy[4:1] = 4'b0;
                {lh_sy[2], lh_sy[4]} = {2{sy}};
                ll_sy[4:1] = 4'b0;                
            end

            default: begin
                {hh_sy[2], hh_sy[4]} = 2'b0;
                hl_sy[4:1] = 4'b0;
                {lh_sy[2], lh_sy[4]} = 2'b0;
                ll_sy[4:1] = 4'b0;                
            end
        endcase
    end

endmodule

//***** Top-Level Recursive Fusion Unit *****//
module rfu (
    input [7:0] x,
    input [7:0] y,
    input sx,
    input sy,
    input [3:0] mode,
    input clk,
    input en,
    input nrst,

    // output reg [63:0] product, // Sum Apart (SA)
    // output reg [127:0] sum // Sum Apart (SA)

    output reg [15:0] product, // Sum Together (ST)
    output reg [19:0] sum // Sum Together (ST)
    );

    //** Configuration/Mode Parameters **//    
    localparam _2bx2b = 4'd0; 
    localparam _4bx4b = 4'd1; 
    localparam _8bx8b = 4'd2;                   
                                                   
    //** Decomposition of 8bx8b input into four 4bx4b inputs or into 2bx2b inputs **//
    wire [3:0] xh, xl, yh, yl;
    assign xh = x[7:4]; assign xl = x[3:0];
    assign yh = y[7:4]; assign yl = y[3:0];   

    // Instantiate four bitbricks (BB) inside the fusion unit (FU) to handle 4b x 4b Multiplication 
    // Create 4 blocks of 4b x 4b BB to handle 8b x 8b
    // Notation: bb_xy_z where x and y represent positions of either high or low half and z as the block number
    // M = N = 8, n = m = 4

    // Control Signals (sx, sy, mode) Logic:
    // * By default, sx and sy are mapped to the 8bx8b datapath. For lower-precision modes, such as 4bx4b, the signed/unsigned
    //   signals are only used on the BitBricks that contain the MSB of the input operands.
    // * Otherwise, it checks on the respective BitBricks for the current mode (==) AND the current sign-bit (sx,sy)

    // Instantiate controller:
    wire [4:1] hh_sx, hl_sx, lh_sx, ll_sx, hh_sy, hl_sy, lh_sy, ll_sy;
    signbit_ctrl sign_ctrl(.sx(sx), .sy(sy), .mode(mode), 
                           .hh_sx(hh_sx), .hl_sx(hl_sx), .lh_sx(lh_sx), .ll_sx(ll_sx), 
                           .hh_sy(hh_sy), .hl_sy(hl_sy), .lh_sy(lh_sy), .ll_sy(ll_sy));

    // eg. sx on the BitBrick with all MSBs in the 8bx8b datapath would not be triggered as signed input unless
    //     the current mode is 2bx2b and sx = 1 which implies that all the 2-bit inputs across all (16) BitBricks
    //     will be processed as signed inputs.
    
    //****************** Block 1 = High-High, x[7:4] * y[7:4] ******************//
    wire [4:0] pp_hh_1, pp_hl_1, pp_lh_1, pp_ll_1;
    s_bitbrick bb_hh_1(.x(xh[3:2]), .y(yh[3:2]), .p(pp_hh_1), .sx(hh_sx[1]), .sy(hh_sy[1]));    
    s_bitbrick bb_hl_1(.x(xh[3:2]), .y(yh[1:0]), .p(pp_hl_1), .sx(hl_sx[1]), .sy(hl_sy[1]));    
    s_bitbrick bb_lh_1(.x(xh[1:0]), .y(yh[3:2]), .p(pp_lh_1), .sx(lh_sx[1]), .sy(lh_sy[1]));    
    s_bitbrick bb_ll_1(.x(xh[1:0]), .y(yh[1:0]), .p(pp_ll_1), .sx(ll_sx[1]), .sy(ll_sy[1]));    
    
    wire [7:0] pp_hh;
    // assign pp_hh = (pp_ll_1 + {pp_hl_1, 2'b0} + {pp_lh_1, 2'b0} + {pp_hh_1, 4'b0});
    // assign pp_hh = {pp_hh_1, pp_ll_1[3:0]} + {(pp_hl_1 + pp_lh_1), 2'b00}; // Merge + Add-Shift    
    assign pp_hh = {pp_hh_1, pp_ll_1[3:0]} + {({pp_hl_1[4], pp_hl_1} + {pp_lh_1[4], pp_lh_1}), 2'b00}; // Merge + Add-Shift w/ Sign Bit Extension   


    //******************  Block 2 = High-Low, x[7:4] * y[3:0] ******************//
    wire [4:0] pp_hh_2, pp_hl_2, pp_lh_2, pp_ll_2;
    s_bitbrick bb_hh_2(.x(xh[3:2]), .y(yl[3:2]), .p(pp_hh_2), .sx(hh_sx[2]), .sy(hh_sy[2]));    
    s_bitbrick bb_hl_2(.x(xh[3:2]), .y(yl[1:0]), .p(pp_hl_2), .sx(hl_sx[2]), .sy(hl_sy[2]));    
    s_bitbrick bb_lh_2(.x(xh[1:0]), .y(yl[3:2]), .p(pp_lh_2), .sx(lh_sx[2]), .sy(lh_sy[2]));    
    s_bitbrick bb_ll_2(.x(xh[1:0]), .y(yl[1:0]), .p(pp_ll_2), .sx(ll_sx[2]), .sy(ll_sy[2]));    
    
    wire [7:0] pp_hl;
    // assign pp_hl = (pp_ll_2 + {pp_hl_2, 2'b0} + {pp_lh_2, 2'b0} + {pp_hh_2, 4'b0});
    // assign pp_hl = {pp_hh_2, pp_ll_2[3:0]} + {(pp_hl_2 + pp_lh_2), 2'b00}; // Merge + Add-Shift  
    assign pp_hl = {pp_hh_2, pp_ll_2[3:0]} + {({pp_hl_2[4], pp_hl_2} + {pp_lh_2[4], pp_lh_2}), 2'b00}; // Merge + Add-Shift w/ Sign Bit Extension   


    //******************  Block 3 = Low-High, x[3:0] * y[7:4] ******************//
    wire [4:0] pp_hh_3, pp_hl_3, pp_lh_3, pp_ll_3;
    s_bitbrick bb_hh_3(.x(xl[3:2]), .y(yh[3:2]), .p(pp_hh_3), .sx(hh_sx[3]), .sy(hh_sy[3]));    
    s_bitbrick bb_hl_3(.x(xl[3:2]), .y(yh[1:0]), .p(pp_hl_3), .sx(hl_sx[3]), .sy(hl_sy[3]));    
    s_bitbrick bb_lh_3(.x(xl[1:0]), .y(yh[3:2]), .p(pp_lh_3), .sx(lh_sx[3]), .sy(lh_sy[3]));    
    s_bitbrick bb_ll_3(.x(xl[1:0]), .y(yh[1:0]), .p(pp_ll_3), .sx(ll_sx[3]), .sy(ll_sy[3]));    
    
    wire [7:0] pp_lh;
    // assign pp_lh = (pp_ll_3 + {pp_hl_3, 2'b0} + {pp_lh_3, 2'b0} + {pp_hh_3, 4'b0});  
    // assign pp_lh = {pp_hh_3, pp_ll_3[3:0]} + {(pp_hl_3 + pp_lh_3), 2'b00}; // Merge + Add-Shift   
    assign pp_lh = {pp_hh_3, pp_ll_3[3:0]} + {({pp_hl_3[4], pp_hl_3} + {pp_lh_3[4], pp_lh_3}), 2'b00}; // Merge + Add-Shift w/ Sign Bit Extension   

    //******************  Block 4 = Low-Low, x[3:0] * y[3:0] ******************//
    wire [4:0] pp_hh_4, pp_hl_4, pp_lh_4, pp_ll_4;
    s_bitbrick bb_hh_4(.x(xl[3:2]), .y(yl[3:2]), .p(pp_hh_4), .sx(hh_sx[4]), .sy(hh_sy[4]));    
    s_bitbrick bb_hl_4(.x(xl[3:2]), .y(yl[1:0]), .p(pp_hl_4), .sx(hl_sx[4]), .sy(hl_sy[4]));    
    s_bitbrick bb_lh_4(.x(xl[1:0]), .y(yl[3:2]), .p(pp_lh_4), .sx(lh_sx[4]), .sy(lh_sy[4]));    
    s_bitbrick bb_ll_4(.x(xl[1:0]), .y(yl[1:0]), .p(pp_ll_4), .sx(ll_sx[4]), .sy(ll_sy[4]));    
    
    wire [7:0] pp_ll;
    // assign pp_ll = (pp_ll_4 + {pp_hl_4, 2'b0} + {pp_lh_4, 2'b0} + {pp_hh_4, 4'b0});    
    // assign pp_ll = {pp_hh_4, pp_ll_4[3:0]} + {(pp_hl_4 + pp_lh_4), 2'b00}; // Merge + Add-Shift    
    assign pp_ll = {pp_hh_4, pp_ll_4[3:0]} + {({pp_hl_4[4], pp_hl_4} + {pp_lh_4[4], pp_lh_4}), 2'b00}; // Merge + Add-Shift w/ Sign Bit Extension

    //** Output Product Mapping based on chosen mode **//

    //--------------- Sum Apart Logic (SA) ---------------//
    // always@(*) begin
    //     case(mode)
    //        _8bx8b: begin
    //            // Sign-Bit Extension to 16-bits for BB Cluster 8-bit Products
    //            product[15:0] = {pp_hh, pp_ll} + {{{4{(pp_lh[7] & sy)}}, pp_lh} + {{4{(pp_hl[7] & sx)}}, pp_hl}, 4'b0}; // Recursive implementation of MFU on 8bx8b Datapath
    //            // product[15:0] = {{8{1'b0}}, pp_ll} + {{4{(pp_lh[7] & sy)}}, pp_lh, 4'b0} + {{4{(pp_hl[7] & sx)}}, pp_hl, 4'b0} + {pp_hh, 8'b0};            
    //        end
            
    //         _4bx4b: begin
    //             // Must map 4x8b BitBrick products to 64-bit output product register
    //             product[31:0] = {pp_hh, pp_hl, pp_lh, pp_ll};         
    //             product[63:32] = 0; 
    //         end
            
    //         _2bx2b: begin
    //             // Must map 16x4b BitBrick products to 64-bit output product register
    //             product = {pp_hh_1[3:0], pp_hl_1[3:0], pp_lh_1[3:0], pp_ll_1[3:0], 
    //                        pp_hh_2[3:0], pp_hl_2[3:0], pp_lh_2[3:0], pp_ll_2[3:0], 
    //                        pp_hh_3[3:0], pp_hl_3[3:0], pp_lh_3[3:0], pp_ll_3[3:0], 
    //                        pp_hh_4[3:0], pp_hl_4[3:0], pp_lh_4[3:0], pp_ll_4[3:0]};
    //         end

    //         default: product = 0;
    //     endcase
    // end 

    //--------------- Sum Together Logic (ST) ---------------//
    always@(*) begin
        case(mode)
            _8bx8b: begin
                // Sign-Bit Extension to 16-bits for BB Cluster 8-bit Products
                product[15:0] = {pp_hh, pp_ll} + {{{4{(pp_lh[7] & sy)}}, pp_lh} + {{4{(pp_hl[7] & sx)}}, pp_hl}, 4'b0}; // Recursive implementation of MFU on 8bx8b Datapath
                // product[15:0] = {{8{1'b0}}, pp_ll} + {{4{(pp_lh[7] & sy)}}, pp_lh, 4'b0} + {{4{(pp_hl[7] & sx)}}, pp_hl, 4'b0} + {pp_hh, 8'b0};            
            end

            _4bx4b: begin
                // Sign-Bit Extension to 10-bits for BB Cluster 8-bit Products
                product[9:0] = ({{2{pp_hh[7]}}, pp_hh} + {{2{pp_hl[7]}}, pp_hl} + {{2{pp_lh[7]}}, pp_lh} + {{2{pp_ll[7]}}, pp_ll});
                product[15:10] = 0;
            end

            _2bx2b: begin
                // Sign-Bit Extension to 8-bits for 6-bit BB Products
                product[7:0] = {{3{pp_hh_1[4]}}, pp_hh_1} + {{3{pp_hl_1[4]}}, pp_hl_1} + {{3{pp_lh_1[4]}}, pp_lh_1} + {{3{pp_ll_1[4]}}, pp_ll_1} +
                               {{3{pp_hh_2[4]}}, pp_hh_2} + {{3{pp_hl_2[4]}}, pp_hl_2} + {{3{pp_lh_2[4]}}, pp_lh_2} + {{3{pp_ll_2[4]}}, pp_ll_2} +
                               {{3{pp_hh_3[4]}}, pp_hh_3} + {{3{pp_hl_3[4]}}, pp_hl_3} + {{3{pp_lh_3[4]}}, pp_lh_3} + {{3{pp_ll_3[4]}}, pp_ll_3} +
                               {{3{pp_hh_4[4]}}, pp_hh_4} + {{3{pp_hl_4[4]}}, pp_hl_4} + {{3{pp_lh_4[4]}}, pp_lh_4} + {{3{pp_ll_4[4]}}, pp_ll_4};
                product[15:8] = 0;
            end

            default: product = 0;
        endcase
    end

    //** Output Accumulator Mapping based on chosen mode **//

    // Create buffer to check when precision mode changes for resetting sum/accumulator
    reg [3:0] mode_buffer; 
    always@(posedge clk) begin
        if(!nrst) begin
            mode_buffer <= 4'd15;
        end else begin
            mode_buffer <= mode; 
        end
    end

    //--------------- Sum Apart Logic (SA) ---------------//
    // always@(posedge clk) begin
    //     if (!nrst) begin
    //         sum <= 0;
    //     end else begin
    //         // Empty the sum when switching modes
    //         if (mode != mode_buffer) begin 
    //             // Check if the MAC Engine is in idle and the precision mode changes
    //             sum <= 0;
    //         end else begin
    //             // Otherwise, proceed with scaled accumulate operation if enabled
    //             if(en) begin
    //                 case(mode)
    //                     _8bx8b: begin
    //                         // Extend sign bit of 16-bit product in 8bx8b mode then accumulated to fit 20-bit sum when adding
    //                         sum[19:0] <= (sum[19:0] + {{4{product[15]}}, product[15:0]});                    
    //                         sum[127:20] <= 0;
    //                     end

    //                     _4bx4b: begin
    //                         // Map the 32-bit product register (4x8b products) to fit 4x12b = 48-bit sum w/ sign extend to 12b
    //                         sum[11:0] <= (sum[11:0] + {{4{product[7]}}, product[7:0]});
    //                         sum[23:12] <= (sum[23:12] + {{4{product[15]}}, product[15:8]});
    //                         sum[35:24] <= (sum[35:24] + {{4{product[23]}}, product[23:16]});
    //                         sum[47:36] <= (sum[47:36] + {{4{product[31]}}, product[31:24]});
    //                         sum[127:48] <= 0;
    //                     end

    //                     _2bx2b: begin
    //                         // Map the 64-bit product register (16x4b products) to fit 16x8b = 128-bit sum w/ sign extend to 8b
    //                         sum[7:0] <= (sum[7:0] + {{4{product[3]}}, product[3:0]});
    //                         sum[15:8] <= (sum[15:8] + {{4{product[7]}}, product[7:4]});
    //                         sum[23:16] <= (sum[23:16] + {{4{product[11]}}, product[11:8]});
    //                         sum[31:24] <= (sum[31:24] + {{4{product[15]}}, product[15:12]});
    //                         sum[39:32] <= (sum[39:32] + {{4{product[19]}}, product[19:16]});
    //                         sum[47:40] <= (sum[47:40] + {{4{product[23]}}, product[23:20]});
    //                         sum[55:48] <= (sum[55:48] + {{4{product[27]}}, product[27:24]});
    //                         sum[63:56] <= (sum[63:56] + {{4{product[31]}}, product[31:28]});
    //                         sum[71:64] <= (sum[71:64] + {{4{product[35]}}, product[35:32]}); //
    //                         sum[79:72] <= (sum[79:72] + {{4{product[39]}}, product[39:36]});
    //                         sum[87:80] <= (sum[87:80] + {{4{product[43]}}, product[43:40]}); //
    //                         sum[95:88] <= (sum[95:88] + {{4{product[47]}}, product[47:44]}); //
    //                         sum[103:96] <= (sum[103:96] + {{4{product[51]}}, product[51:48]});
    //                         sum[111:104] <= (sum[111:104] + {{4{product[55]}}, product[55:52]});
    //                         sum[119:112] <= (sum[119:112] + {{4{product[59]}}, product[59:56]}); //
    //                         sum[127:120] <= (sum[127:120] + {{4{product[63]}}, product[63:60]}); //                        
    //                     end

    //                     default: sum <= 0;
    //                 endcase
    //             end
    //         end
    //     end
    // end    

    //--------------- Sum Together Logic (ST) ---------------//
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
                        end

                        _4bx4b: begin
                            // Extend the sign bit of the 10-bit "product" (and sums) in 4bx4b mode to fit 12-bit sum when adding
                            sum[11:0] <= (sum[11:0] + {{2{product[9]}}, product[9:0]});
                            sum[19:12] <= 0;
                        end

                        _2bx2b: begin
                            // Extend the sign bit of the 8-bit "product" (and sums) in 2bx2b mode to fit 10-bit sum when adding
                            sum[9:0] <= (sum[9:0] + {{2{product[7]}}, product[7:0]});
                            sum[19:10] <= 0;
                        end                 
 
                        default: sum <= 0;
                    endcase
                end
            end
        end
    end    
endmodule