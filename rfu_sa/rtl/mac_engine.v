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
    input [1:0] mode,
    input clk,
    input nrst,
    input en,
    input [7:0] batch_size,
    input ready,
    output reg valid,
    output reg [127:0] OBUF, // Output Buffer

    output [63:0] product, // Wire for monitoring fusion_unit scaled precision modes
    output [127:0] sum // Wire for monitoring fusion_unit scaled precision modes
    );
    
    //** Buffers **//
    reg [7:0] IBUF [1:0]; // Input Buffer
    reg [7:0] WBUF [1:0]; // Weight Buffer
    
    //** State Parameters **//
    reg [2:0] state;
    localparam s_idle = 3'd0;
    localparam s_busy = 3'd1;
    localparam s_wait = 3'd2;
    
    //** State Transitions **//
    reg [7:0] ctr;
    always@(posedge clk) begin
        if (!nrst) begin
            state <= s_idle;
            valid <= 0;
            ctr <= 0;
        end else begin
            case(state)
                s_idle: begin
                    if(en) state <= s_busy;
                end

                s_busy: begin
                    if (ctr == (batch_size + 2)) begin
                        state <= s_wait;
                        valid <= 1'b1;
                        ctr <= 0;
                    end else begin
                        state <= s_busy;
                        ctr <= ctr + 1;
                    end     
                end

                s_wait: begin
                    if (ready) begin
                        valid <= 0;
                        state <= s_idle;
                    end
                end
            endcase
        end
    end

    //** Configuration/Mode Parameters **//    
    localparam _2bx2b = 2'b00;                  
    localparam _4bx4b = 2'b01;                  
    localparam _8bx8b = 2'b10;
 
    reg [1:0] mode_buffer; // Create buffer to check when precision mode changes for resetting OBUF
    always@(posedge clk) begin
        if(!nrst) begin
            mode_buffer <= 2'b11;
        end else begin
            mode_buffer <= mode; 
        end
    end

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

            // case(state)
            //     s_idle: begin
            //         IBUF[1][7:0] <= activations; // Load Current Activations to Buffer
            //         WBUF[1][7:0] <= weights;  

            //         if(en) begin
            //             IBUF[0][7:0] <= IBUF[1][7:0]; // Place inputs on top of Stack
            //             WBUF[0][7:0] <= WBUF[1][7:0];                
            //         end else begin
            //             IBUF[0][7:0] <= 0; // Set inputs to 0 to have no switching activity
            //             WBUF[0][7:0] <= 0;                
            //         end
            //     end
                        
            //     s_busy: begin
            //         IBUF[1][7:0] <= activations; // Load Next Input Activations
            //         WBUF[1][7:0] <= weights;        
            //     end                   
            // endcase        
        end

    end

    //** Fusion Units (FU) Instantiations **//
    // wire [15:0] product;
    rfu RFU1 (
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
    
    //** Valid Output Signal Counter **//
    reg [7:0] ctr;
    always@(posedge clk) begin
        if (!nrst) begin
            ctr <= 0;
            valid <= 0;
        end else begin
            if (en) begin
                if (ctr == batch_size + 1) begin
                    valid <= 1'b1;
                end else begin
                    ctr = ctr + 1;
                end
            end
        end
    end

    //** Output Buffer with Valid-Ready Handshake **//
    always@(posedge clk) begin
        if (!nrst) begin
            OBUF <= 0;
        end else begin
            if (valid && ready) 
            // Move the final sum to the output buffer if Valid and receiver is Ready
                OBUF <= sum; 
        end
    end


    // //** Output Buffer (OBUF)/Accumulator **//
    // always@(posedge clk) begin
    //     if (!nrst) begin
    //         OBUF <= 0;
    //     end else begin
    //         // Empty the OBUF when switching modes
    //         if (mode != mode_buffer) begin 
    //             // Check if the MAC Engine is in idle and the precision mode changes
    //             OBUF <= 0;
    //         end else begin
    //             // Otherwise, proceed with scaled accumulate operation if enabled
    //             if(en) begin
    //                 case(mode)
    //                     _8bx8b: begin
    //                         // Extend sign bit of 16-bit product in 8bx8b mode then accumulated to fit 20-bit OBUF when adding
    //                         OBUF[19:0] <= (OBUF[19:0] + {{4{product[15]}}, product[15:0]});                    
    //                         OBUF[127:20] <= 0;
    //                     end

    //                     _4bx4b: begin
    //                         // Map the 32-bit product register (4x8b products) to fit 4x12b = 48-bit OBUF w/ sign extend to 12b
    //                         OBUF[11:0] <= (OBUF[11:0] + {{4{product[7]}}, product[7:0]});
    //                         OBUF[23:12] <= (OBUF[23:12] + {{4{product[15]}}, product[15:8]});
    //                         OBUF[35:24] <= (OBUF[35:24] + {{4{product[23]}}, product[23:16]});
    //                         OBUF[47:36] <= (OBUF[47:36] + {{4{product[31]}}, product[31:24]});
    //                         OBUF[127:48] <= 0;
    //                     end

    //                     _2bx2b: begin
    //                         // Map the 64-bit product register (16x4b products) to fit 16x8b = 128-bit OBUF w/ sign extend to 8b
    //                         OBUF[7:0] <= (OBUF[7:0] + {{4{product[3]}}, product[3:0]});
    //                         OBUF[15:8] <= (OBUF[15:8] + {{4{product[7]}}, product[7:4]});
    //                         OBUF[23:16] <= (OBUF[23:16] + {{4{product[11]}}, product[11:8]});
    //                         OBUF[31:24] <= (OBUF[31:24] + {{4{product[15]}}, product[15:12]});
    //                         OBUF[39:32] <= (OBUF[39:32] + {{4{product[19]}}, product[19:16]});
    //                         OBUF[47:40] <= (OBUF[47:40] + {{4{product[23]}}, product[23:20]});
    //                         OBUF[55:48] <= (OBUF[55:48] + {{4{product[27]}}, product[27:24]});
    //                         OBUF[63:56] <= (OBUF[63:56] + {{4{product[31]}}, product[31:28]});
    //                         OBUF[71:64] <= (OBUF[71:64] + {{4{product[35]}}, product[35:32]}); //
    //                         OBUF[79:72] <= (OBUF[79:72] + {{4{product[39]}}, product[39:36]});
    //                         OBUF[87:80] <= (OBUF[87:80] + {{4{product[43]}}, product[43:40]}); //
    //                         OBUF[95:88] <= (OBUF[95:88] + {{4{product[47]}}, product[47:44]}); //
    //                         OBUF[103:96] <= (OBUF[103:96] + {{4{product[51]}}, product[51:48]});
    //                         OBUF[111:104] <= (OBUF[111:104] + {{4{product[55]}}, product[55:52]});
    //                         OBUF[119:112] <= (OBUF[119:112] + {{4{product[59]}}, product[59:56]}); //
    //                         OBUF[127:120] <= (OBUF[127:120] + {{4{product[63]}}, product[63:60]}); //                        
    //                     end
                        
    //                     default: OBUF <= 0;
    //                 endcase
    //             end
    //         end
    //     end
    // end
endmodule
