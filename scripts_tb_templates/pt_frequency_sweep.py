#############################################################################
#  School: University of the Philippines - Diliman
#  Student: PELAYO, Kenn Danielle C.
#
#  Project Name: Comparative Analysis and Implementation of Energy-Quality Scalable 
#                Multiply-Accumulate Architectures for TinyML Applications
#############################################################################

# Import Libraries
import csv
import subprocess

################# Note: Only edit these parameters! #########################

# Constants
area = 597.864 # in um2 (Note: make sure to change this after synthesis)
area_mm2 = area * (1/1000)**2 # in mm2

# Note: MAKE SURE THE LINE NUMBERS MATCH UP OR IT WOULD RUIN mac_engine_tb.sv
clk_period_line_num = 57
prec_sweep_line_num = 266

# Generate Range of Frequencies to Sweep
interval =    10500000 # 10.5 MHz
start_freq = 500000000 # 500 MHz
end_freq =   542000000 # 542 MHz
freq_list = list(range(start_freq, (end_freq + interval), interval))

#############################################################################

# Filepaths/Commands
constraints_path = "../cons/timing.sdc"
testbench_path = "mac_engine_tb.sv"
pt_simulation_log_path = "pt_simulation.log"
pt_report_log_path = "mac_engine_pt_power.rpt"
vcs_command = "vcs mac_engine_tb.sv ../mapped/mac_engine_mapped.v /cad/tools/libraries/dwc_logic_in_gf22fdx_sc7p5t_116cpp_base_csc20l/GF22FDX_SC7P5T_116CPP_BASE_CSC20L_FDK_RELV02R80/model/verilog/GF22FDX_SC7P5T_116CPP_BASE_CSC20L.v /cad/tools/libraries/dwc_logic_in_gf22fdx_sc7p5t_116cpp_base_csc20l/GF22FDX_SC7P5T_116CPP_BASE_CSC20L_FDK_RELV02R80/model/verilog/prim.v -full64 -debug_pp +neg_tchk -R -l vcs.log"

# Create CSV for Energy/Throughput Reports (https://www.freecodecamp.org/news/how-to-create-a-csv-file-in-python/)
with open('energy_throughput_report.csv', 'w', newline='') as pt_file:
    writer = csv.writer(pt_file)
    field = ["Frequency", "Precision", "Power", "Execution Time", "Throughput", "Energy/op", "GOPs/mm2"]
    writer.writerow(field)

# Sweep through each frequency and precision mode
prec_list = ['2bx2b', '4bx4b', '8bx8b']
for freq in freq_list:
    # Read Constraints File
    with open(constraints_path, 'r', encoding='utf-8') as cons_file: 
        constraints_data = cons_file.readlines()

    # Rewrite Constraints File / Clock Frequency
    constraints_data[1] = "set CLK_FREQUENCY           {}\n".format(freq)
    with open(constraints_path, 'w', encoding='utf-8') as cons_file: 
        cons_file.writelines(constraints_data)

    # Perform tests on each precision mode.
    for prec in prec_list:
        # Read Testbench File
        with open(testbench_path, 'r', encoding='utf-8') as tb_file: 
            tb_data = tb_file.readlines()

        # Change Testbench CLK_PERIOD
        tb_data[clk_period_line_num + 1] = "localparam CLK_PERIOD = " + str(round(int((1/freq)*(1E12)), -1)) + ";\n"

        # Rewrite Testbench based on current precision mode
        # Note: For the baseline data-gated MAC, instead of 209, all tests must be repeated 200 times for 51 test cases.
        if (prec == '2bx2b'):
            tb_data[prec_sweep_line_num + 1] = "    repeat (209) begin\n"
            tb_data[prec_sweep_line_num + 2] = "        test_precision(_2bx2b, 8'd4);\n"
            tb_data[prec_sweep_line_num + 3] = "    end\n"

            tb_data[prec_sweep_line_num + 5] = "    // repeat (209) begin\n"
            tb_data[prec_sweep_line_num + 6] = "    //     test_precision(_4bx4b, 8'd13);\n"
            tb_data[prec_sweep_line_num + 7] = "    // end\n"

            tb_data[prec_sweep_line_num + 9] = "    // repeat (200) begin\n"
            tb_data[prec_sweep_line_num + 10] = "    //     test_precision(_8bx8b, 8'd51);\n"
            tb_data[prec_sweep_line_num + 11] = "    // end\n"                       
        elif (prec == '4bx4b'):
            tb_data[prec_sweep_line_num + 1] = "    // repeat (209) begin\n"
            tb_data[prec_sweep_line_num + 2] = "    //     test_precision(_2bx2b, 8'd4);\n"
            tb_data[prec_sweep_line_num + 3] = "    // end\n"

            tb_data[prec_sweep_line_num + 5] = "    repeat (209) begin\n"
            tb_data[prec_sweep_line_num + 6] = "        test_precision(_4bx4b, 8'd13);\n"
            tb_data[prec_sweep_line_num + 7] = "    end\n"

            tb_data[prec_sweep_line_num + 9] = "    // repeat (200) begin\n"
            tb_data[prec_sweep_line_num + 10] = "    //     test_precision(_8bx8b, 8'd51);\n"
            tb_data[prec_sweep_line_num + 11] = "    // end\n"              
        elif (prec == '8bx8b'):
            tb_data[prec_sweep_line_num + 1] = "    // repeat (209) begin\n"
            tb_data[prec_sweep_line_num + 2] = "    //     test_precision(_2bx2b, 8'd4);\n"
            tb_data[prec_sweep_line_num + 3] = "    // end\n"

            tb_data[prec_sweep_line_num + 5] = "    // repeat (209) begin\n"
            tb_data[prec_sweep_line_num + 6] = "    //     test_precision(_4bx4b, 8'd13);\n"
            tb_data[prec_sweep_line_num + 7] = "    // end\n"

            tb_data[prec_sweep_line_num + 9] = "    repeat (200) begin\n"
            tb_data[prec_sweep_line_num + 10] = "        test_precision(_8bx8b, 8'd51);\n"
            tb_data[prec_sweep_line_num + 11] = "    end\n"               

        with open(testbench_path, 'w', encoding='utf-8') as tb_file: 
            tb_file.writelines(tb_data)

        # Read power.tcl Script
        with open("power.tcl", 'r', encoding='utf-8') as tcl_file: 
            tcl_data = tcl_file.readlines()

        # Change clock period accordingly
        tcl_data[19] = "create_clock -period " + str(int((1/freq)*(1E12))) +" -name CLK [get_ports clk]\n" # in picoseconds

        with open("power.tcl", 'w', encoding='utf-8') as tcl_file: 
            tcl_file.writelines(tcl_data)

        # Run Synopsys VCS using the current frequency constraints and precision mode
        return_code = subprocess.run(vcs_command, shell=True)

        # Run Synopsys PT and the corresponding compile.tcl Script
        return_code = subprocess.run("pt_shell -file power.tcl", shell=True)

        # Read Synopsys PT Simulation and Analysis Reports
        with open(pt_simulation_log_path, 'r', encoding='utf-8') as sim_file: 
            sim_data = sim_file.readlines()
        with open(pt_report_log_path, 'r', encoding='utf-8') as power_file: 
            power_data = power_file.readlines()

        # Parse Simulation Log for Execution Time
        for lines in sim_data:
            if "Total" in lines.split():
                exec_time = float(lines.split()[-1]) * (10E-9) # in nanoseconds

        # Parse Power Analysis for Power Report
        keywords = ["mac_engine", "PSMAC1", "PFU1", "FU1", "MFU1", "RFU1"]
        buffer = []

        for lines in power_data:
            if any(word in lines.split() for word in keywords):
                buffer.append(lines.split())

        engine_power = float(buffer[1][-2]) # in mW
        fu_power = float(buffer[2][-2]) # in mW

        # Calculate Energy and Throughput
        energy = ((fu_power*exec_time)/20000)*(1E12) # in fJ
        throughput = 20000/exec_time
        throughput_per_area = (throughput/(1E9))/area_mm2 # in GOPs/mm2
        
        # Write/Append into CSV file
        with open('energy_throughput_report.csv', 'a', newline='') as pt_file:
            writer = csv.writer(pt_file)
            writer.writerow([freq, prec, fu_power, exec_time, throughput, energy, throughput_per_area])