# Import Libraries
import csv
import subprocess

# Filepaths
constraints_path = "cons/timing.sdc"
area_log_path = "logs/area_report.log"
timing_log_path = "logs/timing_report.log"

# Generate Range of Frequencies to Sweep
interval =     1000000 # 1 MHz
start_freq = 545000000 # 545 MHz
end_freq =   800000000 # 800 MHz
freq_list = list(range(start_freq, (end_freq + interval), interval))

# Create CSV for Slack (https://www.freecodecamp.org/news/how-to-create-a-csv-file-in-python/)
with open('slack_synthesis_report.csv', 'w', newline='') as slack_file:
    writer = csv.writer(slack_file)
    field = ["Frequency", "Slack", "Combinational Area", "Buff/Inv Area", "Noncombinational Area", "Total MAC Engine Area", "Total Fusion Unit Area"]
    writer.writerow(field)

# Sweep through each frequency
for freq in freq_list:
    # Read Constraints File
    with open(constraints_path, 'r', encoding='utf-8') as cons_file: 
        constraints_data = cons_file.readlines()

    # Rewrite Constraints File / Clock Frequency
    constraints_data[1] = "set CLK_FREQUENCY           {}\n".format(freq)
    with open(constraints_path, 'w', encoding='utf-8') as cons_file: 
        cons_file.writelines(constraints_data)

    # Run Synopsys Design Compiler using the current frequency constraints
    return_code = subprocess.run("dc_shell -f compile.tcl -output_log_file logs/compile.log", shell=True)

    # Read Timing Reports
    with open(area_log_path, 'r', encoding='utf-8') as file: 
        area_data = file.readlines()
    with open(timing_log_path, 'r', encoding='utf-8') as timing_file: 
        timing_data = timing_file.readlines()

    # Parse Area Log Reports: Lines 22-24 (Combinational Area, Buff/Inv Area, Noncombinational Area)
    combi_area = float(area_data[21].split()[-1])
    buffinv_area = float(area_data[22].split()[-1])
    noncombi_data = float(area_data[23].split()[-1])
    print("Combinational Area:", combi_area, "Buff/Inv Area:", buffinv_area, "Noncombinational Area:", noncombi_data)

    # Line 39-40 - (MAC Engine Hierarchy, Fusion Unit Hierarchy)
    engine_area = float(area_data[38].split()[1])
    mac_area = float(area_data[39].split()[1])
    print("MAC Engine Area:", engine_area, "MAC Area:", mac_area)

    # Parse Timing Log Report
    for lines in timing_data:
        if "slack" in lines.split():
            slack = float(lines.split()[2])

    print("Current Frequency Constraints:", freq, "Slack:", slack)

    # Write/Append into CSV file
    with open('slack_synthesis_report.csv', 'a', newline='') as slack_file:
        writer = csv.writer(slack_file)
        writer.writerow([freq, slack, combi_area, buffinv_area, noncombi_data, engine_area, mac_area])

    # If negative slack, end sweep.
    if slack < 1:
        break