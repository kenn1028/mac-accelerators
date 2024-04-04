## Define clock constraints.
set CLK_FREQUENCY           500000000
set CLK_PERIOD              [expr {1000000000000 / ${CLK_FREQUENCY} / 1.0}]
set CLK_HIGH_TIME           [expr {${CLK_PERIOD} / 2.0}]
set CLK_UNCERTAINTY         [expr {${CLK_PERIOD} * 0.1}]

## Define boundary constraints.
set INPUT_DELAY_MAX         [expr {${CLK_PERIOD} * 0.3}]
set OUTPUT_DELAY_MAX        [expr {${CLK_PERIOD} * 0.5}]

## Define environmental constraints - Hypothetically used SC7P5T_BUFX24_CSC20L Pin Capacitance as Output Buffer
set_units -capacitance fF
set OUTPUT_LOAD             [expr {5.13806 * 10.0}] 

## Set clock constraints.
create_clock -period ${CLK_PERIOD} -waveform [list 0 ${CLK_HIGH_TIME}] -name clk [get_ports clk]
set_clock_uncertainty -setup ${CLK_UNCERTAINTY} [get_clocks clk]

## Set boundary constraints.
set_input_delay $INPUT_DELAY_MAX -max -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay $OUTPUT_DELAY_MAX -max -clock clk [all_outputs]

## Set environmental constraints.
set_load $OUTPUT_LOAD [all_outputs]