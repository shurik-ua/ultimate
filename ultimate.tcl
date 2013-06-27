# Copyright (C) 1991-2011 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: ultimate.tcl
# Generated on: Sun May 05 17:23:50 2013

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "ultimate"]} {
		puts "Project ultimate is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists ultimate]} {
		project_open -revision uultimate ultimate
	} else {
		project_new -revision ultimate ultimate
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone III"
	set_global_assignment -name DEVICE EP3C10E144C8
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 11.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "12:16:01  MAY 04, 2013"
	set_global_assignment -name LAST_QUARTUS_VERSION 11.0
	set_global_assignment -name USE_GENERATED_PHYSICAL_CONSTRAINTS OFF -section_id eda_blast_fpga
	set_global_assignment -name SEARCH_PATH "c:/altera/81/quartus/libraries/vhdl/"
	set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE SPEED
	set_global_assignment -name DEVICE_FILTER_PACKAGE TQFP
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 144
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 8
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name USE_CONFIGURATION_DEVICE OFF
	set_global_assignment -name FORCE_CONFIGURATION_VCCIO ON
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_DATA1_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_FLASH_NCE_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name RESERVE_DCLK_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name LL_ROOT_REGION ON -section_id "Root Region"
	set_global_assignment -name LL_MEMBER_STATE LOCKED -section_id "Root Region"
	set_global_assignment -name USE_TIMEQUEST_TIMING_ANALYZER OFF
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name SMART_RECOMPILE ON
	set_global_assignment -name ENABLE_DRC_SETTINGS ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING ON
	set_global_assignment -name ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION ON
	set_global_assignment -name ROUTER_TIMING_OPTIMIZATION_LEVEL MAXIMUM
	set_global_assignment -name AUTO_PACKED_REGISTERS_STRATIXII NORMAL
	set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON
	set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
	set_global_assignment -name ROUTER_CLOCKING_TOPOLOGY_ANALYSIS ON
	set_global_assignment -name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 3
	set_global_assignment -name FITTER_EFFORT "STANDARD FIT"
	set_global_assignment -name SDC_FILE ultimate.sdc
	set_global_assignment -name VHDL_FILE src/uart/uart.vhd
	set_global_assignment -name VHDL_FILE src/video/txt.vhd
	set_global_assignment -name VHDL_FILE src/x80/x80.vhd
	set_global_assignment -name VHDL_FILE src/ultimate.vhd
	set_global_assignment -name QIP_FILE src/pll/altpll0.qip
	set_global_assignment -name QIP_FILE src/rom/altrom0.qip
	set_global_assignment -name QIP_FILE src/ram/altram0.qip
	set_global_assignment -name QIP_FILE src/rom/altrom1.qip
	set_location_assignment PIN_6 -to ASDO
	set_location_assignment PIN_90 -to CBUS4
	set_location_assignment PIN_22 -to CLK_50MHZ
	set_location_assignment PIN_13 -to DATA0
	set_location_assignment PIN_12 -to DCLK
	set_location_assignment PIN_44 -to DRAM_A[12]
	set_location_assignment PIN_46 -to DRAM_A[11]
	set_location_assignment PIN_71 -to DRAM_A[10]
	set_location_assignment PIN_49 -to DRAM_A[9]
	set_location_assignment PIN_50 -to DRAM_A[8]
	set_location_assignment PIN_51 -to DRAM_A[7]
	set_location_assignment PIN_52 -to DRAM_A[6]
	set_location_assignment PIN_53 -to DRAM_A[5]
	set_location_assignment PIN_54 -to DRAM_A[4]
	set_location_assignment PIN_75 -to DRAM_A[3]
	set_location_assignment PIN_74 -to DRAM_A[2]
	set_location_assignment PIN_73 -to DRAM_A[1]
	set_location_assignment PIN_72 -to DRAM_A[0]
	set_location_assignment PIN_70 -to DRAM_BA[1]
	set_location_assignment PIN_69 -to DRAM_BA[0]
	set_location_assignment PIN_67 -to DRAM_CAS_n
	set_location_assignment PIN_43 -to DRAM_CLK
	set_location_assignment PIN_58 -to DRAM_D[7]
	set_location_assignment PIN_55 -to DRAM_D[6]
	set_location_assignment PIN_39 -to DRAM_D[5]
	set_location_assignment PIN_42 -to DRAM_D[4]
	set_location_assignment PIN_65 -to DRAM_D[3]
	set_location_assignment PIN_64 -to DRAM_D[2]
	set_location_assignment PIN_60 -to DRAM_D[1]
	set_location_assignment PIN_59 -to DRAM_D[0]
	set_location_assignment PIN_68 -to DRAM_RAS_n
	set_location_assignment PIN_66 -to DRAM_WE_n
	set_location_assignment PIN_89 -to GPI
	set_location_assignment PIN_80 -to GPIO
	set_location_assignment PIN_8 -to NCSO
	set_location_assignment PIN_106 -to PS2_KBCLK
	set_location_assignment PIN_105 -to PS2_KBDAT
	set_location_assignment PIN_79 -to PS2_MSCLK
	set_location_assignment PIN_76 -to PS2_MSDAT
	set_location_assignment PIN_88 -to RST_n
	set_location_assignment PIN_23 -to RTC_INT_n
	set_location_assignment PIN_10 -to RTC_SCL
	set_location_assignment PIN_11 -to RTC_SDA
	set_location_assignment PIN_77 -to RXD
	set_location_assignment PIN_33 -to SD_CLK
	set_location_assignment PIN_32 -to SD_CMD
	set_location_assignment PIN_34 -to SD_DAT0
	set_location_assignment PIN_38 -to SD_DAT1
	set_location_assignment PIN_30 -to SD_DAT2
	set_location_assignment PIN_31 -to SD_DAT3
	set_location_assignment PIN_25 -to SD_PROT
	set_location_assignment PIN_4 -to SRAM_A[19]
	set_location_assignment PIN_132 -to SRAM_A[18]
	set_location_assignment PIN_133 -to SRAM_A[17]
	set_location_assignment PIN_135 -to SRAM_A[16]
	set_location_assignment PIN_136 -to SRAM_A[15]
	set_location_assignment PIN_143 -to SRAM_A[14]
	set_location_assignment PIN_144 -to SRAM_A[13]
	set_location_assignment PIN_1 -to SRAM_A[12]
	set_location_assignment PIN_2 -to SRAM_A[11]
	set_location_assignment PIN_3 -to SRAM_A[10]
	set_location_assignment PIN_129 -to SRAM_A[9]
	set_location_assignment PIN_128 -to SRAM_A[8]
	set_location_assignment PIN_127 -to SRAM_A[7]
	set_location_assignment PIN_126 -to SRAM_A[6]
	set_location_assignment PIN_125 -to SRAM_A[5]
	set_location_assignment PIN_114 -to SRAM_A[4]
	set_location_assignment PIN_113 -to SRAM_A[3]
	set_location_assignment PIN_112 -to SRAM_A[2]
	set_location_assignment PIN_111 -to SRAM_A[1]
	set_location_assignment PIN_110 -to SRAM_A[0]
	set_location_assignment PIN_137 -to SRAM_D[7]
	set_location_assignment PIN_138 -to SRAM_D[6]
	set_location_assignment PIN_141 -to SRAM_D[5]
	set_location_assignment PIN_142 -to SRAM_D[4]
	set_location_assignment PIN_121 -to SRAM_D[3]
	set_location_assignment PIN_120 -to SRAM_D[2]
	set_location_assignment PIN_119 -to SRAM_D[1]
	set_location_assignment PIN_115 -to SRAM_D[0]
	set_location_assignment PIN_124 -to SRAM_WE_n
	set_location_assignment PIN_91 -to TXD
	set_location_assignment PIN_85 -to VGA_B[2]
	set_location_assignment PIN_86 -to VGA_B[1]
	set_location_assignment PIN_87 -to VGA_B[0]
	set_location_assignment PIN_98 -to VGA_G[2]
	set_location_assignment PIN_99 -to VGA_G[1]
	set_location_assignment PIN_100 -to VGA_G[0]
	set_location_assignment PIN_83 -to VGA_HSYNC
	set_location_assignment PIN_101 -to VGA_R[2]
	set_location_assignment PIN_103 -to VGA_R[1]
	set_location_assignment PIN_104 -to VGA_R[0]
	set_location_assignment PIN_84 -to VGA_VSYNC
	set_location_assignment PIN_24 -to VS_DREQ
	set_location_assignment PIN_7 -to VS_XCS
	set_location_assignment PIN_28 -to VS_XDCS
	set_instance_assignment -name IO_MAXIMUM_TOGGLE_RATE "0 MHz" -to DCLK
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
