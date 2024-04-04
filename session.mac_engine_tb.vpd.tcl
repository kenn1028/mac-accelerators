# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Sun Mar 17 19:13:35 2024
# Designs open: 1
#   V1: mac_engine_tb.vpd
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: mac_engine_tb
#   Wave.1: 30 signals
#   Group count = 12
#   Group Intermediate Signals signal count = 8
#   Group Inputs signal count = 5
#   Group Sum Apart (SA) signal count = 2
#   Group Sum Together (ST) signal count = 2
#   Group Output Buffer (OBUF) signal count = 1
# End_DVE_Session_Save_Info

# DVE version: T-2022.06-SP2_Full64
# DVE build date: Nov 29 2022 21:09:56


#<Session mode="Full" path="/home/kpelayo/Documents/Pelayo_196_199/fusion/sim/session.mac_engine_tb.vpd.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{8 53} {1227 772}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_hide_toolbar -toolbar {Simulator}
gui_hide_toolbar -toolbar {Interactive Rewind}
gui_hide_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 259]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 259
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 258} {height 451} {dock_state left} {dock_on_new_line true} {child_hier_colhier 196} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 503]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 503
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 476
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 502} {height 451} {dock_state left} {dock_on_new_line true} {child_data_colvariable 245} {child_data_colvalue 101} {child_data_coltype 132} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 170]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1220
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 170
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1219} {height 169} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{8 53} {1227 772}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_hide_toolbar -toolbar {Simulator}
gui_hide_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 308} {child_wave_right 906} {child_wave_colname 217} {child_wave_colvalue 87} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}
gui_update_statusbar_target_frame ${TopLevel.2}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { ![gui_is_db_opened -db {mac_engine_tb.vpd}] } {
	gui_open_db -design V1 -file mac_engine_tb.vpd -nosource
}
gui_set_precision 1fs
gui_set_time_units 1fs
#</Database>

# DVE Global setting session: 


# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {mac_engine_tb}


set _session_group_1 {Intermediate Signals}
gui_sg_create "$_session_group_1"
set {Intermediate Signals} "$_session_group_1"

gui_sg_addsignal -group "$_session_group_1" { mac_engine_tb.nrst mac_engine_tb.sx mac_engine_tb.sy mac_engine_tb.en mac_engine_tb.clk mac_engine_tb.mode mac_engine_tb.ready mac_engine_tb.valid }

set _session_group_2 Inputs
gui_sg_create "$_session_group_2"
set Inputs "$_session_group_2"

gui_sg_addsignal -group "$_session_group_2" { mac_engine_tb.curr_activation mac_engine_tb.curr_weight }

set _session_group_3 $_session_group_2|
append _session_group_3 {4bx4b Inputs}
gui_sg_create "$_session_group_3"
set {Inputs|4bx4b Inputs} "$_session_group_3"

gui_sg_addsignal -group "$_session_group_3" { mac_engine_tb.activation_4bx4b mac_engine_tb.weight_4bx4b }

gui_sg_move "$_session_group_3" -after "$_session_group_2" -pos 2 

set _session_group_4 $_session_group_2|
append _session_group_4 {8bx8b Inputs}
gui_sg_create "$_session_group_4"
set {Inputs|8bx8b Inputs} "$_session_group_4"

gui_sg_addsignal -group "$_session_group_4" { mac_engine_tb.activation_8bx8b mac_engine_tb.weight_8bx8b }
gui_set_radix -radix {decimal} -signals {V1:mac_engine_tb.activation_8bx8b}
gui_set_radix -radix {unsigned} -signals {V1:mac_engine_tb.activation_8bx8b}
gui_set_radix -radix {decimal} -signals {V1:mac_engine_tb.weight_8bx8b}
gui_set_radix -radix {signMagnitude} -signals {V1:mac_engine_tb.weight_8bx8b}

gui_sg_move "$_session_group_4" -after "$_session_group_2" -pos 4 

set _session_group_5 $_session_group_2|
append _session_group_5 {2bx2b Inputs}
gui_sg_create "$_session_group_5"
set {Inputs|2bx2b Inputs} "$_session_group_5"

gui_sg_addsignal -group "$_session_group_5" { mac_engine_tb.activation_2bx2b mac_engine_tb.weight_2bx2b }

gui_sg_move "$_session_group_5" -after "$_session_group_2" -pos 3 

set _session_group_6 {Sum Apart (SA)}
gui_sg_create "$_session_group_6"
set {Sum Apart (SA)} "$_session_group_6"

gui_sg_addsignal -group "$_session_group_6" { }

set _session_group_7 $_session_group_6|
append _session_group_7 Accumulator/Sum
gui_sg_create "$_session_group_7"
set {Sum Apart (SA)|Accumulator/Sum} "$_session_group_7"

gui_sg_addsignal -group "$_session_group_7" { mac_engine_tb.sum_8bx8b mac_engine_tb.sum_4bx4b mac_engine_tb.sum_2bx2b }

gui_sg_move "$_session_group_7" -after "$_session_group_6" -pos 1 

set _session_group_8 $_session_group_6|
append _session_group_8 {Current Product}
gui_sg_create "$_session_group_8"
set {Sum Apart (SA)|Current Product} "$_session_group_8"

gui_sg_addsignal -group "$_session_group_8" { mac_engine_tb.product mac_engine_tb.product_8bx8b mac_engine_tb.product_4bx4b mac_engine_tb.product_2bx2b }
gui_set_radix -radix {decimal} -signals {V1:mac_engine_tb.product_8bx8b}
gui_set_radix -radix {signMagnitude} -signals {V1:mac_engine_tb.product_8bx8b}

set _session_group_9 {Sum Together (ST)}
gui_sg_create "$_session_group_9"
set {Sum Together (ST)} "$_session_group_9"

gui_sg_addsignal -group "$_session_group_9" { }

set _session_group_10 $_session_group_9|
append _session_group_10 Accumulator/Sum
gui_sg_create "$_session_group_10"
set {Sum Together (ST)|Accumulator/Sum} "$_session_group_10"

gui_sg_addsignal -group "$_session_group_10" { mac_engine_tb.sum_8bx8b mac_engine_tb.sum_4bx4b_ST mac_engine_tb.sum_2bx2b_ST }

gui_sg_move "$_session_group_10" -after "$_session_group_9" -pos 1 

set _session_group_11 $_session_group_9|
append _session_group_11 {Current Product}
gui_sg_create "$_session_group_11"
set {Sum Together (ST)|Current Product} "$_session_group_11"

gui_sg_addsignal -group "$_session_group_11" { mac_engine_tb.product_8bx8b mac_engine_tb.product_4bx4b_ST mac_engine_tb.product_2bx2b_ST }
gui_set_radix -radix {decimal} -signals {V1:mac_engine_tb.product_8bx8b}
gui_set_radix -radix {signMagnitude} -signals {V1:mac_engine_tb.product_8bx8b}

set _session_group_12 {Output Buffer (OBUF)}
gui_sg_create "$_session_group_12"
set {Output Buffer (OBUF)} "$_session_group_12"

gui_sg_addsignal -group "$_session_group_12" { mac_engine_tb.OBUF }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 575620767



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design V1
catch {gui_list_select -id ${Hier.1} {mac_engine_tb}}
gui_view_scroll -id ${Hier.1} -vertical -set 16654
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {mac_engine_tb}
gui_show_window -window ${Data.1}
catch { gui_list_select -id ${Data.1} {mac_engine_tb.product_4bx4b_ST mac_engine_tb.sum_4bx4b_ST mac_engine_tb.product_2bx2b_ST mac_engine_tb.sum_2bx2b_ST mac_engine_tb.sum_8bx8b mac_engine_tb.product_8bx8b }}
gui_view_scroll -id ${Data.1} -vertical -set 429
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 16654
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active mac_engine_tb mac_engine_tb.v
gui_view_scroll -id ${Source.1} -vertical -set 315
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 0 7500000000
gui_list_add_group -id ${Wave.1} -after {New Group} {{Intermediate Signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {Inputs}
gui_list_add_group -id ${Wave.1} -after {{mac_engine_tb.curr_weight[7:0]}} {{Inputs|4bx4b Inputs}}
gui_list_add_group -id ${Wave.1} -after {{Inputs|4bx4b Inputs}} {{Inputs|2bx2b Inputs}}
gui_list_add_group -id ${Wave.1} -after {{Inputs|2bx2b Inputs}} {{Inputs|8bx8b Inputs}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{Sum Apart (SA)}}
gui_list_add_group -id ${Wave.1}  -after {Sum Apart (SA)} {{Sum Apart (SA)|Current Product}}
gui_list_add_group -id ${Wave.1} -after {{Sum Apart (SA)|Current Product}} {{Sum Apart (SA)|Accumulator/Sum}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{Sum Together (ST)}}
gui_list_add_group -id ${Wave.1}  -after {Sum Together (ST)} {{Sum Together (ST)|Current Product}}
gui_list_add_group -id ${Wave.1} -after {{Sum Together (ST)|Current Product}} {{Sum Together (ST)|Accumulator/Sum}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{Output Buffer (OBUF)}}
gui_list_collapse -id ${Wave.1} Inputs
gui_list_collapse -id ${Wave.1} {Sum Apart (SA)}
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group {Intermediate Signals}  -item mac_engine_tb.clk -position below

gui_marker_move -id ${Wave.1} {C1} 575620767
gui_view_scroll -id ${Wave.1} -vertical -set 64
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${DLPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

