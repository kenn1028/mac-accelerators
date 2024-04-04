`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.11.2023 13:19:57
// Design Name: 
// Module Name: fusion_unit_tb
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


module fusion_unit_tb();

// Input/Output (I/O) Instantiation
//reg [7:0] x,y;
reg [1:0] x, y;
reg sx, sy;
//reg [1:0] mode;
wire [5:0] pp;
//wire [15:0] product;

//// Unit-Under-Test (UUT) Instantiation - BitBrick
bitbrick UUT(
    .x(x),
    .y(y),
    .sx(sx),
    .sy(sy),
    .p(pp)
);

// Unit-Under-Test (UUT) Instantiation - Fusion Unit 
//fusion_unit UUT(
//    .x(x),
//    .y(y),
//    .sx(sx),
//    .sy(sy),
//    .mode(mode),
//    .product(product)
//);

// Testbench - BitBrick
initial begin
    sx = 1'b0;
    sy = 1'b1;
    x = 2'b01;
    y = 2'b11;
    #10
    sx = 1'b0;
    sy = 1'b1;
    x = 2'b11;
    y = 2'b11;
    #10
//    sx = 1'b0;
//    sy = 1'b1;
//    x = 2'b10;
//    y = 2'b01;
//    #1    
//    sx = 1'b1;
//    sy = 1'b0;
//    x = 2'b11;
//    y = 2'b01;
//    #1    
    $finish;
end

// Testbench - Fusion Unit
//initial begin
//    sx = 1'b0;
//    sy = 1'b0;
//    x = ~(8'd12) + 1'b1;
//    y = ~(8'd8) + 1'b1;
//    mode = 2'b00;
////    x = ~(8'd2) + 1'b1;
////    y = ~(8'd2) + 1'b1;
//    #50
//    sx = 1'b0;
//    sy = 1'b1;    
//    x = ~(8'd13) + 1'b1;
//    y = 8'd13;
//    #50
//    sx = 1'b1;
//    sy = 1'b0;    
//    x = ~(8'd23) + 1'b1;
//    y = 8'd75;
//    #50
//    sx = 1'b1;
//    sy = 1'b1;    
//    x = ~(8'd42) + 1'b1;
//    y = ~(8'd61) + 1'b1;
////    x = 4'd5;
//    #50     
//    $finish;
//end

endmodule
