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

//***** Multiplier Module (for post-synthesis observation) *****//
module mult (
    input signed [7:0] x,
    input signed [7:0] y,
    output signed [15:0] product
);
    assign product = x*y;
endmodule

//***** Top-Level Baseline Data-Gated Precision-Scalable MAC (PSMAC) Unit *****//
module psmac (
    input [7:0] x,
    input [7:0] y,
    // input sx,
    // input sy,
    input [3:0] mode,
    input clk,
    input en,
    input nrst,
    output [15:0] product, // Sum Together (ST)
    output reg [19:0] sum // Sum Together (ST)
    );

    //** Configuration/Mode Parameters **//    
    localparam _2bx2b = 4'd0; localparam _4bx4b = 4'd1; localparam _8bx8b = 4'd2;                   
    localparam _2bx4b = 4'd3; localparam _4bx2b = 4'd4;
    localparam _4bx8b = 4'd5; localparam _8bx4b = 4'd6;
    localparam _2bx8b = 4'd7; localparam _8bx2b = 4'd8;

    //** Data Gating the LSBs for Precision-Scalable MAC (PSMAC) Mode **//
    reg [7:0] gated_x, gated_y;
    always@(*) begin
        case(mode)
            _2bx2b: begin
                gated_x = x & 8'b1100_0000;
                gated_y = y & 8'b1100_0000;
            end
            _4bx4b: begin
                gated_x = x & 8'b1111_0000;
                gated_y = y & 8'b1111_0000;
            end
            _8bx8b: begin
                gated_x = x;
                gated_y = y;
            end
            _2bx4b: begin
                gated_x = x & 8'b1100_0000;
                gated_y = y & 8'b1111_0000;
            end
            _4bx2b: begin
                gated_x = x & 8'b1111_0000;
                gated_y = y & 8'b1100_0000;
            end
            _4bx8b: begin
                gated_x = x & 8'b1111_0000;
                gated_y = y;
            end
            _8bx4b: begin
                gated_x = x;
                gated_y = y & 8'b1111_0000;
            end
            _2bx8b: begin
                gated_x = x & 8'b1100_0000;
                gated_y = y;
            end
            _8bx2b: begin
                gated_x = x;
                gated_y = y & 8'b1100_0000;
            end
            default: begin
                gated_x = x;
                gated_y = y;
            end
        endcase
    end

    //** Multiplier Module Instantiation **//
    mult simple_mult (.x(gated_x), .y(gated_y), .product(product));

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

    always@(posedge clk) begin
        if (!nrst) begin
            sum <= 0;
        end else begin
            // Empty the sum when switching modes
            if (mode != mode_buffer) begin 
                // Check if the MAC Engine is in idle and the precision mode changes
                sum <= 0;
            end else begin
                if(en) begin
                    sum <= sum + {{4{product[15]}}, product}; // Extend product to 20 bits before accumulating
                end
            end
        end
    end

endmodule
