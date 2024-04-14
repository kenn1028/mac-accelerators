`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2023 14:00:49
// Design Name: 
// Module Name: mac_engine
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

module mac_engine(
    input [7:0] activations,
    input [7:0] weights,
    input sx,
    input sy,
    input [3:0] mode,
    input clk,
    input nrst,
    input en,
    input [7:0] batch_size,
    input ready,
    output reg valid,

    //--------------- Sum Apart Logic (SA) ---------------//
    output reg [127:0] OBUF, // Output Buffer
    output [63:0] product, // Wire for monitoring fusion_unit scaled precision modes
    output [127:0] sum // Wire for monitoring fusion_unit scaled precision modes

    //--------------- Sum Together Logic (ST) ---------------//
    // output reg [19:0] OBUF, // Output Buffer
    // output [15:0] product, // Wire for monitoring fusion unit scaled precision modes
    // output [19:0] sum // Wire for monitoring fusion unit scaled precision modes    
    
    );
    
    //** Buffers **//
    reg [7:0] IBUF [1:0]; // Input Buffer
    reg [7:0] WBUF [1:0]; // Weight Buffer
    
    //** State Parameters **//
    reg [2:0] state;
    localparam s_idle = 3'd0;
    localparam s_busy = 3'd1;
    localparam s_wait = 3'd2;
    
    //** State Transitions and Valid-Ready Handshake**//
    reg [7:0] ctr;
    always@(posedge clk) begin
        if (!nrst) begin
            state <= s_idle;
            valid <= 0;
            ctr <= 0;
        end else begin
            case(state)
                s_idle: begin
                    if(en) begin 
                        state <= s_busy;
                    end
                end

                s_busy: begin
                    // Count for batch_size + 1 (delay from clearing OBUF) before asserting Valid signal and wait for Ready
                    if (ctr == (batch_size + 1)) begin
                        state <= s_wait;
                        valid <= 1'b1;
                        ctr <= 1;
                    end else begin
                        state <= s_busy;
                        ctr <= ctr + 1;
                    end     
                end

                s_wait: begin
                    // Wait for the Receiver to be Ready before de-asserting the Valid signal and move to Idle state.
                    if (ready) begin
                        valid <= 0;
                        state <= s_idle;
                    end
                end
            endcase
        end
    end

    //** Configuration/Mode Parameters **//    
    localparam _2bx2b = 4'd0; 
    localparam _4bx4b = 4'd1; 
    localparam _8bx8b = 4'd2;                   

    //** Accelerator Datapath **//        
    always@(posedge clk) begin
        if (!nrst) begin
            IBUF[1][7:0] <= 0;
            WBUF[1][7:0] <= 0;
            IBUF[0][7:0] <= 0;
            WBUF[0][7:0] <= 0;
        end else begin
            IBUF[1][7:0] <= activations; // Load Current Activations to Buffer
            WBUF[1][7:0] <= weights;  

            if(en) begin
                IBUF[0][7:0] <= IBUF[1][7:0]; // Place inputs on top of Stack
                WBUF[0][7:0] <= WBUF[1][7:0];                
            end else begin
                IBUF[0][7:0] <= 0; // Set inputs to 0 to have no switching activity
                WBUF[0][7:0] <= 0;                
            end                  
        end

    end

    //** Proposed Fusion Units (PFU) Instantiations **//
    proposed PFU1 (
        .x(IBUF[0][7:0]),
        .y(WBUF[0][7:0]),
        .sx(sx),
        .sy(sy),
        .mode(mode),
        .clk(clk),
        .en(en),
        .nrst(nrst),
        .product(product),
        .sum(sum)
    );

    // //** Output Buffer with Valid-Ready Handshake **//
    // always@(posedge clk) begin
    //     if (!nrst) begin
    //         OBUF <= 0;
    //     end else begin
    //         if (valid && ready) 
    //         // Move the final sum to the output buffer if Valid and receiver is Ready
    //             OBUF <= sum; 
    //     end
    // end

endmodule
