`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2023 15:39:25
// Design Name: 
// Module Name: mac_engine_tb
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

module mac_engine_tb();

// Set the number of tests using the following parameter
localparam NUMBER_OF_TEST = 8'd51;
localparam SIGNED_X = 1'b1;
localparam SIGNED_Y = 1'b1;
localparam ARCHITECTURE =  1'b0; // 0 = Sum Apart (SA), 1 = Sum Together (ST)

// MAC Engine I/O Signals
reg [7:0] curr_activation;      
reg [7:0] curr_weight;                    
// reg sx;                        
// reg sy;                                   
reg [3:0] mode;          
reg clk;                           
reg nrst;    
reg en;
reg ready;
reg [7:0] batch_size;
wire valid;                   

//--------------- Sum Apart Logic (SA) ---------------//
wire [63:0] product;
wire [127:0] sum;
// wire reg [127:0] OBUF;

//--------------- Sum Together Logic (ST) ---------------//
// wire [15:0] product; 
// wire [19:0] sum; 
// wire [19:0] OBUF; 

// Testbench Signals/Parameters
integer l;
integer activ_file, a, weight_file, w;
integer sumv_file, ov;
integer sumtb_file, otb;
integer sump_file, op; 
integer count, count_sum;
localparam NULL = 0;
localparam CLK_PERIOD = 1820;

integer exec_time_counter;
integer exec_time_file;
wire [31:0] exec_time; 
assign exec_time = (exec_time_counter*CLK_PERIOD)/1000; // in nanoseconds

// Configuration/Mode Parameters   
localparam _2bx2b = 4'd0; localparam _4bx4b = 4'd1; localparam _8bx8b = 4'd2;                   
localparam _2bx4b = 4'd3; localparam _4bx2b = 4'd4;
localparam _4bx8b = 4'd5; localparam _8bx4b = 4'd6;
localparam _2bx8b = 4'd7; localparam _8bx2b = 4'd8;          

// Filepaths
// localparam activations_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/test_activations.txt";
// localparam weights_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/test_weights.txt";
// localparam sump_2b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum2b_python.txt";
// localparam sump_4b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum4b_python.txt";
// localparam sump_8b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum8b_python.txt";
// localparam sump_2bx4b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum2bx4b_python.txt";
// localparam sump_4bx2b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum4bx2b_python.txt";
// localparam sump_4bx8b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum4bx8b_python.txt";
// localparam sump_8bx4b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum8bx4b_python.txt";
// localparam sump_2bx8b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum2bx8b_python.txt";
// localparam sump_8bx2b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum8bx2b_python.txt";

// localparam sumtb_2b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum2b_tb.txt";
// localparam sumtb_4b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum4b_tb.txt";
// localparam sumtb_8b_filepath = "E:/School_Stuff/EEE_Microlab/Prelim/proposed_sa/proposed_sa.srcs/sim_1/imports/new/sum8b_tb.txt";

localparam activations_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/test_activations.txt";
localparam weights_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/test_weights.txt";
localparam sump_2b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum2b_python.txt";
localparam sump_4b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum4b_python.txt";
localparam sump_8b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum8b_python.txt";
localparam sump_2bx4b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum2bx4b_python.txt";
localparam sump_4bx2b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum4bx2b_python.txt";
localparam sump_4bx8b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum4bx8b_python.txt";
localparam sump_8bx4b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum8bx4b_python.txt";
localparam sump_2bx8b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum2bx8b_python.txt";
localparam sump_8bx2b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum8bx2b_python.txt";

localparam pyscript_filepath = "python3 /home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/generate_test_files.py";
localparam exec_time_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/pt_simulation.log";

// localparam sumtb_2b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum2b_tb.txt";
// localparam sumtb_4b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum4b_tb.txt";
// localparam sumtb_8b_filepath = "/home/kpelayo/Documents/Pelayo_196_199/proposed_sa/sim/sum8b_tb.txt";


//********************* Create pseudo-wires for better representation during low-precision operations *********************//

//--------------- Sum Together Logic (ST) ---------------//
// wire [9:0] product_4bx4b_ST;
// assign product_4bx4b_ST = product[9:0];
// wire [11:0] sum_4bx4b_ST;
// assign sum_4bx4b_ST = sum[11:0];

// wire [7:0] product_2bx2b_ST;
// assign product_2bx2b_ST = product[7:0];
// wire [9:0] sum_2bx2b_ST;
// assign sum_2bx2b_ST = sum[9:0];

// wire [13:0] product_4bx8b_ST;
// assign product_4bx8b_ST = product[13:0];
// wire [11:0] product_2bx8b_ST;
// assign product_2bx8b_ST = product[11:0];

// wire [15:0] sum_4bx8b_ST;
// assign sum_4bx8b_ST = sum[15:0];
// wire [13:0] sum_2bx8b_ST;
// assign sum_2bx8b_ST = sum[13:0];

//--------------- Sum Apart Logic (SA) ---------------//
// Assume controller knows how to properly access the 128b register based on the "mode" signal
wire [19:0] sum_8bx8b; // Output Buffer/Accumulator (8bx8b Default)    
wire [11:0] sum_4bx4b [3:0]; // 4 x 12b 
wire [7:0] sum_2bx2b [15:0]; // 16 x 8b

// Map the continuous 128b register into arrays that properly group low-precision sums
genvar i;
localparam BITWIDTH_4bx4b = 12;
localparam BITWIDTH_2bx2b = 8;

generate
    for (i = 0; i < 16; i = i+1) begin : generate_block_1
        if (i == 0) begin : generate_block_2
            assign sum_8bx8b = sum[19:0];
            assign sum_4bx4b [i][11:0] = sum[11:0];
            assign sum_2bx2b [i][7:0] = sum[7:0];
        end else if (i > 0 && i < 4) begin : generate_block_3
            assign sum_4bx4b [i][11:0] = sum[((BITWIDTH_4bx4b * i) + BITWIDTH_4bx4b - 1):(BITWIDTH_4bx4b * i)];
            assign sum_2bx2b [i][7:0] = sum[((BITWIDTH_2bx2b * i) + BITWIDTH_2bx2b - 1):(BITWIDTH_2bx2b * i)];       
        end else if (i >= 4) begin : generate_block_4
            assign sum_2bx2b [i][7:0] = sum[((BITWIDTH_2bx2b * i) + BITWIDTH_2bx2b - 1):(BITWIDTH_2bx2b * i)];               
        end
    end
endgenerate

// Do the same for the 64b register of the FU current product
wire [15:0] product_8bx8b; // 16b   
wire [7:0] product_4bx4b [3:0]; // 4 x 8b 
wire [3:0] product_2bx2b [15:0]; // 16 x 4b

genvar j;
localparam BITWIDTHp_4bx4b = 8;
localparam BITWIDTHp_2bx2b = 4;
generate
    for (j = 0; j < 16; j = j+1) begin : generate_block_5
        if (j == 0) begin : generate_block_6
            assign product_8bx8b = product[15:0];
            assign product_4bx4b [j][7:0] = product[7:0];
            assign product_2bx2b [j][3:0] = product[3:0];
        end else if (j > 0 && j < 4) begin : generate_block_7
            assign product_4bx4b [j][7:0] = product[((BITWIDTHp_4bx4b * j) + BITWIDTHp_4bx4b - 1):(BITWIDTHp_4bx4b * j)];
            assign product_2bx2b [j][3:0] = product[((BITWIDTHp_2bx2b * j) + BITWIDTHp_2bx2b - 1):(BITWIDTHp_2bx2b * j)];       
        end else if (j >= 4) begin : generate_block_8
            assign product_2bx2b [j][3:0] = product[((BITWIDTHp_2bx2b * j) + BITWIDTHp_2bx2b - 1):(BITWIDTHp_2bx2b * j)];               
        end
    end
endgenerate

// Do the same for the input activations and weights
wire [7:0] activation_8bx8b; // 16b   
wire [3:0] activation_4bx4b [1:0]; // 2 x 4b 
wire [1:0] activation_2bx2b [3:0]; // 4 x 2b

wire [7:0] weight_8bx8b; // 16b   
wire [3:0] weight_4bx4b [1:0]; // 2 x 4b 
wire [1:0] weight_2bx2b [3:0]; // 4 x 2b

genvar k;
generate
    for (k = 0; k < 4; k = k+1) begin : generate_block_9
        if (k == 0) begin : generate_block_10
            assign activation_8bx8b = curr_activation[7:0];
            assign activation_4bx4b [k][3:0] = curr_activation[3:0];
            assign activation_2bx2b [k][1:0] = curr_activation[1:0];

            assign weight_8bx8b = curr_weight[7:0];
            assign weight_4bx4b [k][3:0] = curr_weight[3:0];
            assign weight_2bx2b [k][1:0] = curr_weight[1:0];                 
        end else if (k > 0 && k < 2) begin : generate_block_11
            assign activation_4bx4b [k][3:0] = curr_activation[((4 * k) + 4 - 1):(4 * k)];
            assign activation_2bx2b [k][1:0] = curr_activation[((2 * k) + 2 - 1):(2 * k)];

            assign weight_4bx4b [k][3:0] = curr_weight[((4 * k) + 4 - 1):(4 * k)];
            assign weight_2bx2b [k][1:0] = curr_weight[((2 * k) + 2 - 1):(2 * k)];       
        end else if (k >= 2) begin : generate_block_12
            assign activation_2bx2b [k][1:0] = curr_activation[((2 * k) + 2 - 1):(2 * k)];    
            assign weight_2bx2b [k][1:0] = curr_weight[((2 * k) + 2 - 1):(2 * k)];               
        end
    end
endgenerate

//************************************************************************************************************************//

// Unit-Under-Test (UUT) Instantiation
mac_engine UUT(
    .activations(curr_activation), .weights(curr_weight),
    // .sx(sx), .sy(sy),
    .mode(mode),
    .clk(clk),
    .nrst(nrst),
    .en(en),
    .batch_size(batch_size),
    .ready(ready),
    .valid(valid),
    // .OBUF(OBUF),

    .product(product),
    .sum(sum)
);

// Clock Signals
always #(CLK_PERIOD/2) clk = ~clk;

// Create a task for iterating through all test cases for each precision mode
task test_precision;
    input [3:0] test_mode;
    input [7:0] number_of_tests;
    begin
        // Enable the MAC engine and set the precision mode
        en = 1'b1;
        ready = 1'b1;
        nrst = 1'b1;
        // #(CLK_PERIOD); // Setup Time for Input Buffers
        mode = test_mode;
        batch_size = number_of_tests;
        
        // Test data over the same number of clock cyles
        // + 1 cycles for sum since it empties it first, delaying it by 1 cycle
        #(CLK_PERIOD * (number_of_tests + 1)); 

        // Turn off Enable signal after 1 clock cycle
        #(CLK_PERIOD); 
        en = 1'b0;
        ready = 1'b0;
    
        // Wait for another 2 clock cycles for next set of tests and clear accumulator register
        #(CLK_PERIOD);
        nrst = 1'b0;
        #(CLK_PERIOD);

        // Generate New Random Test Cases
        $system(pyscript_filepath);
    end
endtask

// Testbench Proper
initial begin
    $dumpfile("mac_engine.dump");
    $dumpvars(0, mac_engine_tb);
        
    $vcdplusfile("mac_engine_tb.vpd");
    $vcdpluson;
    $vcdplusmemon;
    $sdf_annotate("../mapped/mac_engine_mapped.sdf", UUT);

    clk = 1'b0; nrst = 1'b0; en = 1'b0; mode = 4'd15;
    // sx = SIGNED_X; sy = SIGNED_Y; // Sets unsigned activations and signed weights
    curr_activation = 0; curr_weight = 0;
    exec_time_counter = 0;

    #(CLK_PERIOD * 2) nrst = 1'b1; #(CLK_PERIOD * 6);

    //********* Start Testing each Precision Modes using randomized inputs *********//
    // repeat (209) begin
    //     test_precision(_2bx2b, 8'd4);
    // end

    // repeat (209) begin
    //     test_precision(_4bx4b, 8'd13);
    // end

    repeat (200) begin
        test_precision(_8bx8b, 8'd51);
    end

    // test_precision(_2bx4b, NUMBER_OF_TEST);
    // test_precision(_4bx2b, NUMBER_OF_TEST);
    // test_precision(_4bx8b, NUMBER_OF_TEST);
    // test_precision(_8bx4b, NUMBER_OF_TEST);
    // test_precision(_2bx8b, NUMBER_OF_TEST);
    // test_precision(_8bx2b, NUMBER_OF_TEST);
    
    $display("\nSimulation Finished :)\n");
    $display("\nTotal Execution Time : %f ns \n", exec_time);

    // Open and Write Total Execution Time
    exec_time_file = $fopen(exec_time_filepath,"w+");
    if (exec_time_file == NULL) begin
        $display("Cannot open pt_simulation.log");
        $finish;
    end     

    $fwrite(exec_time_file, "Total execution time: %f", exec_time);

    // Close text files
    $fclose(activ_file);
    $fclose(weight_file);    
    $fclose(sump_file);
    $fclose(exec_time_file);

    // Validate text files (Discontinued, just check immediately every clock cycle)
    // validate_sum(_2bx2b, NUMBER_OF_TEST);
    // validate_sum(_4bx4b, NUMBER_OF_TEST);
    // validate_sum(_8bx8b, NUMBER_OF_TEST);

    $finish;
end

//***** Create internal counter for measuring the total execution time when the MAC is enabled *****//
always@(posedge clk) begin
    if (en) begin
        exec_time_counter <= exec_time_counter + 1;
    end
end

//***** For synchronization of test inputs when reading through .txt file ($fscanf) *****//
always@(negedge clk) begin
    if (!nrst) begin
        curr_activation <= 0;
        curr_weight <= 0;        
        count <= 0;
    end else begin
        if (en) begin
            if (count == 0) begin // Check at (count == 0) to only run once
                activ_file = $fopen(activations_filepath,"r");
                if (activ_file == NULL) begin
                    $display("Cannot open activations.txt");
                    $finish;
                end 

                weight_file = $fopen(weights_filepath,"r");
                if (weight_file == NULL) begin
                    $display("Cannot open weights.txt");
                    $finish;
                end    
            end else if (count == (NUMBER_OF_TEST + 1)) begin
                // If end of file has been reached, set inputs to zero.
                if ($feof(activ_file) || $feof(weight_file)) begin
                    // $display("End of file reached");
                    curr_activation <= 0;
                    curr_weight <= 0;
                end
            end

            // Load each binary input into 1D registers every negedge clock cycle
            a <= $fscanf(activ_file,"%b", curr_activation);
            w <= $fscanf(weight_file,"%b", curr_weight);

            count <= count + 1; // Increment Counter

        end else begin // If disabled, set inputs to 0
            curr_activation <= 0;
            curr_weight <= 0;
            count <= 0;
        end
    end
end

//***** For synchronization of test outputs when reading through the generated Python .txt file ($fread) *****//
reg [127:0] sum_py_sa, sum_tb_sa;
reg [19:0] sum_py_st, sum_tb_st;

always@(negedge clk) begin
    if (!nrst) begin     
        count_sum <= 0;
    end else begin
        if (en) begin
            // Choose which Python text files to read-on based on current precision mode
            if (count_sum == 0) begin 
                if (mode == _8bx8b) begin
                    $display("\nValidating Output Buffer (sum) Values in 8bx8b Mode...");
                    // Open the 8bx8b Text Files
                    sump_file = $fopen(sump_8b_filepath,"r");
                    if (sump_file == NULL) begin
                        $display("Cannot open sum8b_python.txt");
                    end                    
                end else if (mode == _4bx4b) begin
                    $display("\nValidating Output Buffer (sum) Values in 4bx4b Mode...");
                    // Open the 4bx4b Text Files
                    sump_file = $fopen(sump_4b_filepath,"r");
                    if (sump_file == NULL) begin
                        $display("Cannot open sum4b_python.txt");
                    end                       
                end else if (mode == _2bx2b) begin
                    $display("\nValidating Output Buffer (sum) Values in 2bx2b Mode...");
                    // Open the 2bx2b Text Files
                    sump_file = $fopen(sump_2b_filepath,"r");
                    if (sump_file == NULL) begin
                        $display("Cannot open sum2b_python.txt");
                    end                 

                // Asymmetric Precision Modes for Original Fusion Unit (FU) only      
                end else if (mode == _2bx4b) begin
                    $display("\nValidating Output Buffer (sum) Values in 2bx4b Mode...");
                    // Open the 2bx4b Text Files
                    sump_file = $fopen(sump_2bx4b_filepath,"r");
                    if (sump_file == NULL) begin
                        $display("Cannot open sum2bx4b_python.txt");
                    end                       
                end else if (mode == _4bx2b) begin
                    $display("\nValidating Output Buffer (sum) Values in 4bx2b Mode...");
                    // Open the 4bx2b Text Files
                    sump_file = $fopen(sump_4bx2b_filepath,"r");
                    if (sump_file == NULL) begin
                        $display("Cannot open sum4bx2b_python.txt");
                    end                       
                end else if (mode == _4bx8b) begin
                    $display("\nValidating Output Buffer (sum) Values in 4bx8b Mode...");
                    // Open the 4bx8b Text Files
                    sump_file = $fopen(sump_4bx8b_filepath,"r");
                    if (sump_file == NULL) begin
                        $display("Cannot open sum4bx8b_python.txt");
                    end                       
                end else if (mode == _8bx4b) begin
                    $display("\nValidating Output Buffer (sum) Values in 8bx4b Mode...");
                    // Open the 8bx4b Text Files
                    sump_file = $fopen(sump_8bx4b_filepath,"r");
                    if (sump_file == NULL) begin
                        $display("Cannot open sum8bx4b_python.txt");
                    end                       
                end else if (mode == _2bx8b) begin
                    $display("\nValidating Output Buffer (sum) Values in 2bx8b Mode...");
                    // Open the 2bx8b Text Files
                    sump_file = $fopen(sump_2bx8b_filepath,"r");
                    if (sump_file == NULL) begin
                        $display("Cannot open sum2bx8b_python.txt");
                    end                       
                end else if (mode == _8bx2b) begin
                    $display("\nValidating Output Buffer (sum) Values in 8bx2b Mode...");
                    // Open the 8bx2b Text Files
                    sump_file = $fopen(sump_8bx2b_filepath,"r");
                    if (sump_file == NULL) begin
                        $display("Cannot open sum8bx2b_python.txt");
                    end                       
                end      

                // (Discontinued) Choose which text files to write-on depending on the current precision mode
                // if (mode == _2bx2b) begin
                //     sumv_file = $fopen(sumtb_2b_filepath,"w+");
                //     if (sumv_file == NULL) begin
                //         $display("Cannot open sum2b_tb.txt");
                //         $finish;
                //     end
                // end else if (mode == _4bx4b) begin
                //     sumv_file = $fopen(sumtb_4b_filepath,"w+");
                //     if (sumv_file == NULL) begin
                //         $display("Cannot open sum4b_tb.txt");
                //         $finish;
                //     end
                // end else if (mode == _8bx8b) begin
                //     sumv_file = $fopen(sumtb_8b_filepath,"w+");
                //     if (sumv_file == NULL) begin
                //         $display("Cannot open sum8b_tb.txt");
                //         $finish;
                //     end                   
                // end   
                    
            // Start reading the current value of sum and compare to current line/test case in the generated Python text file 
            end else if ((count_sum < (NUMBER_OF_TEST + 2)) && (count_sum > 1)) begin
                // $fwrite(sumv_file, "%h\n", sum); // (Discontinued writing to .txt, immediately checks instead)

                if (ARCHITECTURE == 1'b0) begin // Sum Apart (SA) 128-bit Accumulator
                    op = $fscanf(sump_file,"%h", sum_py_sa); 
                end else if (ARCHITECTURE == 1'b1) begin // Sum Together (SA) 20-bit Accumulator
                    op = $fscanf(sump_file,"%h", sum_py_st);                 
                end

                if ((sum == sum_py_sa) | (sum == sum_py_st)) begin
                    if (ARCHITECTURE == 1'b0) begin // Sum Apart (SA) 128-bit Accumulator
                        $display("OUTPUT BUFFER MATCH %h (reference) == %h (output)", sum_py_sa, sum);
                    end else if (ARCHITECTURE == 1'b1) begin // Sum Together (SA) 20-bit Accumulator
                        $display("OUTPUT BUFFER MATCH %h (reference) == %h (output)", sum_py_st, sum);                
                    end                                        
                end else begin
                    if (ARCHITECTURE == 1'b0) begin // Sum Apart (SA) 128-bit Accumulator
                        $display("OUTPUT BUFFER MISMATCH %h (reference) != %h (output)", sum_py_sa, sum);
                        $display("POINTS OF MISMATCH: %h", (sum_py_sa ^ sum));
                    end else if (ARCHITECTURE == 1'b1) begin // Sum Together (SA) 20-bit Accumulator
                        $display("OUTPUT BUFFER MISMATCH %h (reference) != %h (output)", sum_py_st, sum);
                        $display("POINTS OF MISMATCH: %h", (sum_py_st ^ sum));
                    end                    
                end                
            end

            count_sum <= count_sum + 1;

        end else begin
            // If disabled wait for another clock cycle before resetting to zero.
            if (count_sum >= (NUMBER_OF_TEST + 2)) begin
                // $fwrite(sumv_file, "%h\n", sum); // (Discontinued writing to .txt, immediately checks instead)

                if (ARCHITECTURE == 1'b0) begin // Sum Apart (SA) 128-bit Accumulator
                    op = $fscanf(sump_file,"%h", sum_py_sa); 
                end else if (ARCHITECTURE == 1'b1) begin // Sum Together (SA) 20-bit Accumulator
                    op = $fscanf(sump_file,"%h", sum_py_st);                 
                end

                if ((sum == sum_py_sa) | (sum == sum_py_st)) begin
                    if (ARCHITECTURE == 1'b0) begin // Sum Apart (SA) 128-bit Accumulator
                        $display("OUTPUT BUFFER MATCH %h (reference) == %h (output)", sum_py_sa, sum);
                    end else if (ARCHITECTURE == 1'b1) begin // Sum Together (SA) 20-bit Accumulator
                        $display("OUTPUT BUFFER MATCH %h (reference) == %h (output)", sum_py_st, sum);                
                    end                                        
                end else begin
                    if (ARCHITECTURE == 1'b0) begin // Sum Apart (SA) 128-bit Accumulator
                        $display("OUTPUT BUFFER MISMATCH %h (reference) != %h (output)", sum_py_sa, sum);
                        $display("POINTS OF MISMATCH: %h", (sum_py_sa ^ sum));
                    end else if (ARCHITECTURE == 1'b1) begin // Sum Together (SA) 20-bit Accumulator
                        $display("OUTPUT BUFFER MISMATCH %h (reference) != %h (output)", sum_py_st, sum);
                        $display("POINTS OF MISMATCH: %h", (sum_py_st ^ sum));
                    end                    

                end

                count_sum <= 0; // Reset counter

            end else begin
                count_sum <= 0; // Reset counter

                // $fclose(sumv_file);
                // $display("Validation finished. \n");
            end
        end
    end
end

// //****** Create a task for parsing through sum_python.txt and sum_tb.txt files for output validation (DISCONTINUED, just check immediately) ******//
// task validate_sum;
//     input [1:0] test_mode;
//     input [15:0] number_of_tests;

//     reg [127:0] sum_py, sum_tb;
//     begin
//         if (test_mode == _8bx8b) begin
//             $display("Validating Output Buffer (sum) Values in 8bx8b Mode...");
//             // Open the 8bx8b Text Files
//             sump_file = $fopen(sump_8b_filepath,"r");
//             if (sump_file == NULL) begin
//                 $display("Cannot open sum8b_python.txt");
//             end                    
//             sumtb_file = $fopen(sumtb_8b_filepath,"r");
//             if (sumtb_file == NULL) begin
//                 $display("Cannot open sum8b_tb.txt");
//             end            
//         end else if (test_mode == _4bx4b) begin
//             $display("Validating Output Buffer (sum) Values in 4bx4b Mode...");
//             // Open the 4bx4b Text Files
//             sump_file = $fopen(sump_4b_filepath,"r");
//             if (sump_file == NULL) begin
//                 $display("Cannot open sum4b_python.txt");
//             end                       
//             sumtb_file = $fopen(sumtb_4b_filepath,"r");
//             if (sumtb_file == NULL) begin
//                 $display("Cannot open sum4b_tb.txt");
//             end            
//         end else if (test_mode == _2bx2b) begin
//             $display("Validating Output Buffer (sum) Values in 2bx2b Mode...");
//             // Open the 2bx2b Text Files
//             sump_file = $fopen(sump_2b_filepath,"r");
//             if (sump_file == NULL) begin
//                 $display("Cannot open sum2b_python.txt");
//             end                       
//             sumtb_file = $fopen(sumtb_2b_filepath,"r");
//             if (sumtb_file == NULL) begin
//                 $display("Cannot open sum2b_tb.txt");
//             end                       
//         end

//         // Parse through the text files and compare
//         for (l = 0; l < (number_of_tests + 1); l = l+1) begin
//             otb = $fscanf(sumtb_file,"%h", sum_tb);
//             op = $fscanf(sump_file,"%h", sum_py);  

//             if (sum_tb != sum_py) begin
//                 $display("OUTPUT BUFFER MISMATCH %h (reference) != %h (output)", sum_py, sum_tb);
//                 $display("POINTS OF MISMATCH: %h", (sum_py ^ sum_tb));
//             end else begin
//                 $display("OUTPUT BUFFER MATCH %h (reference) == %h (output)", sum_py, sum_tb);
//             end
//         end
      
//         $display("Validation finished. \n");

//         $fclose(sump_file);
//         $fclose(sumtb_file);
//     end    
// endtask

endmodule

