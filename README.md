# mac-accelerators
GitHub Repository for a BS Computer Engineering Undergraduate Project:\
"_Comparative Analysis and Implementation of Energy-Quality Scalable Multiply-Accumulate Architectures for TinyML Applications_" 

Author: PELAYO, Kenn Danielle C.\
School: University of the Philippines - Diliman, BS Computer Engineering

# Benchmarking Workflow

The MAC unit architectures are benchmarked by performing **10,000 MAC operations per precision mode (2bx2b, 4bx4b, 8bx8b)** using Python Scripts to overwrite the _CLK_PERIOD_ in the SystemVerilog testbenches as well as the TCL scripts when calling Synopsys PrimeTime (PT) for static power analysis at different operating frequencies. The Python scripts would then create respective CSV files containing the Area/Slack reports and Energy per Operation/Throughput per Area reports across these varying frequencies. The general behavior of the Python scripts can be visualized as follows:

![Benchmarking Workflow](https://github.com/kenn1028/mac-accelerators/blob/main/.images/1_benchmarking_flow.png?raw=true)

To benchmark a specific design, we use the following steps:

1. Make sure to run ``source ../set_synopsys.sh`` if you're within the directory of the desired MAC unit architecture. This ensures that the console has access to Synopsys Design Tools such as DC for synthesis, VCS for simulation, and PT for power analysis.

2. In the ``slack_frequency_sweep.py`` of their respective directory, you can set the _FREQUENCY_ range that you want to sweep by editing the starting and ending frequency as well as the interval or increment between each step. This Python script outputs ``slack_synthesis_reports.csv`` that would resynthesize the design by editing the frequency constraints of the ``cons/timing.sdc`` file based on the set frequency range. This script reports the _Area_ of the MAC unit as well as the _Slack_ and looks for the optimal frequency constraint (resulting in a Slack almost equal to 0) to ensure that we have synthesized the most optimized version of our design.

3. Wait depending on the amount of frequencies that you set. The larger the amount, the longer it takes unless you start at a frequency where that slack is already low in the first place. Area/Slack results would be logged in ``slack_synthesis_reports.csv``.

4. Copy the _Total Fusion Unit Area_ (in um^2) reported by the ``slack_synthesis_reports.csv`` into the ``sim/pt_frequency_sweep.py`` script to ensure that it calculates the Throughput per Area (GOPs/mm^2) correctly.

5. Before running ``sim/pt_frequency_sweep.py`` ensure that the _end_freq_ or ending frequency of the Python script ends at the **same frequency** as the frequency constraints used when synthesizing the optimized design by looking at the ``slack_synthesis_reports.csv`` file. This ensures that when sweeping the frequency in the optimized design, it does not operate _faster_ than what it was synthesized for and that it properly works.

6. Wait again until all the precision modes have been benchmarked. Energy/Operation and Throughput/Area reports would be logged in ``slack_synthesis_reports.csv``.

# Test Case Generation and Testbench Runtime Output Validation
