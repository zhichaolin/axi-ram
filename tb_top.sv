`timescale 1ns / 1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

`define WIDTH 32 
`define SIZE 3

`include "axi_slave_dut.sv"
`include "my_interface.sv"
`include "my_seq_item.sv"
`include "my_sqncr.sv"
`include "axi_m_seq.sv"
`include "axi_m_drv.sv"
//`include "axi_s_drv.sv"
`include "axi_m_mon.sv"
`include "axi_m_agent.sv"
//`include "axi_s_agent.sv"
`include "axi_sb.sv"
// `include "axi_subscriber.sv"
`include "axi_env.sv"
`include "axi_test.sv"
`include "axi_top.sv"





