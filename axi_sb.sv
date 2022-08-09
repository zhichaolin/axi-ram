`timescale 1ns / 1ps

`ifndef SCOREBOARDS
`define SCOREBOARDS

import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_scoreboard #(
    int WIDTH = 32,
    SIZE = 3
) extends uvm_scoreboard;

  `uvm_component_param_utils(axi_scoreboard#(WIDTH, SIZE))

  uvm_analysis_export #(axi_m_Sequence_Item #(WIDTH, SIZE)) drv2sb_export_drv;  //expected
  uvm_analysis_export #(axi_m_Sequence_Item #(WIDTH, SIZE)) mon2sb_export_mon;  //actual

  uvm_tlm_analysis_fifo #(axi_m_Sequence_Item #(WIDTH, SIZE)) expfifo;
  uvm_tlm_analysis_fifo #(axi_m_Sequence_Item #(WIDTH, SIZE)) actualfifo;

  virtual axi_intf #(WIDTH, SIZE) intf;

  axi_m_Sequence_Item #(WIDTH, SIZE) mon_tx, drv_tx;


  function new(string name = "axi_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv2sb_export_drv = new("drv2sb_export_drv", this);
    mon2sb_export_mon = new("mon2sb_export_mon", this);
    expfifo = new("expfifo", this);
    actualfifo = new("actualfifo", this);
    mon_tx = new("mon_tx");
    drv_tx = new("drv_tx");
  endfunction

  function void connect_phase(uvm_phase phase);

    drv2sb_export_drv.connect(expfifo.analysis_export);
    mon2sb_export_mon.connect(actualfifo.analysis_export);
  endfunction

  virtual task run_phase(uvm_phase phase);
	fork
		compare();
	join
  endtask
  

  virtual task compare();
  forever begin
	expfifo.get(drv_tx);
	actualfifo.get(mon_tx);

	if (mon_tx.RDATA === drv_tx.WDATA) begin

      `uvm_info("test_finished", {"Test: OK!"}, UVM_LOW);
      $display("-------------------------------------------------");
      $display("------ INFO : TEST CASE DATA PASSED ------------------");
      $display("-------------------------------------------------");
    end else begin
		$display("mon_tx.RDATA: %d", mon_tx.RDATA);
	$display("drv_tx.WDATA: %d", drv_tx.WDATA);
      $display("---------------------------------------------------");
      $display("------ ERROR : TEST CASE DATA FAILED ------------------");
      $display("---------------------------------------------------");
		`uvm_fatal("test_failed", {"ERROR : TEST CASE DATA FAILED "});
    end
	end

  endtask

endclass

`endif
