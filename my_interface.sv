`timescale 1ns / 1ps
`ifndef AXI_INTERFACE
`define AXI_INTERFACE
import uvm_pkg::*;
`include "uvm_macros.svh"


interface axi_intf #(
    int WIDTH = 32,
    SIZE = 3
) (
    input bit clk,
    reset
);

  logic AWREADY;
  logic AWVALID;
  logic [SIZE-2:0] AWBURST;
  logic [SIZE-1:0] AWSIZE;
  logic [(WIDTH/8)-1:0] AWLEN;
  logic [WIDTH-1:0] AWADDR;
  logic [(WIDTH/8)-1:0] AWID;

  int que_WLEN[$];

  // DATA WRITE CHANNEL
  logic WREADY;
  logic WVALID;
  logic WLAST;
  logic [(WIDTH/8)-1:0] WSTRB;
  logic [WIDTH-1:0] WDATA;
  //logic	[(WIDTH/8)-1:0]	WID;

  // WRITE RESPONSE CHANNEL
  logic [(WIDTH/8)-1:0] BID;
  logic [SIZE-2:0] BRESP;
  logic BVALID;
  logic BREADY;

  // READ ADDRESS CHANNEL
  logic ARVALID;
  logic ARREADY;
  logic [(WIDTH/8)-1:0] ARID;
  logic [WIDTH-1:0] ARADDR;
  logic [(WIDTH/8)-1:0] ARLEN;
  logic [SIZE-1:0] ARSIZE;
  logic [SIZE-2:0] ARBURST;

  // READ DATA CHANNEL
  logic [(WIDTH/8)-1:0] RID;
  logic [WIDTH-1:0] RDATA;
  logic [SIZE-2:0] RRESP;
  logic RLAST;
  logic RVALID;
  logic RREADY;
  
  bit                has_checks = 1;
  
	
	// PROPERY ASSERTION
  property AWREADY_rose_next_cycle_fall;
    @(posedge clk) AWREADY && AWVALID |=> $fell(AWREADY) && $fell(AWVALID);
  endproperty: AWREADY_rose_next_cycle_fall
  assert property(AWREADY_rose_next_cycle_fall) else `uvm_error("ASSERT", "AWREADY or AWVALID is high after 1 cycle AWREADY rose")
  
  property AWADDR_stable_during_AWVALID;
	  logic [WIDTH-1:0] addr1;
    @(posedge clk) ($rose(AWVALID),addr1 = AWADDR)  |-> AWADDR == addr1 throughout AWVALID;
  endproperty: AWADDR_stable_during_AWVALID
  assert property(AWADDR_stable_during_AWVALID) else `uvm_error("ASSERT", "AWADDR not stable during AWVALID")
  
  
    property send_WDATA_after_AWREADY_fell;
    @(posedge clk) $fell(AWREADY) |=> ##[0:$] ($rose(WLAST) && WVALID);
  endproperty: send_WDATA_after_AWREADY_fell
  assert property(send_WDATA_after_AWREADY_fell) else `uvm_error("ASSERT", "must send wdata after AWREADY fell")
  
    property WDATA_stable_during_WVALID;
	  logic [WIDTH-1:0] d1;
    @(posedge clk) ($rose(WVALID),d1 = WDATA)  |-> WDATA == d1 throughout WVALID;
  endproperty: WDATA_stable_during_WVALID
  assert property(WDATA_stable_during_WVALID) else `uvm_error("ASSERT", "WDATA not stable during WVALID")
  

  
   property BVALID_rose_after_WLAST_fall;
    @(posedge clk) $fell(WLAST)  |=> ##[0:$] $rose(BVALID);
  endproperty: BVALID_rose_after_WLAST_fall
  assert property(BVALID_rose_after_WLAST_fall) else `uvm_error("ASSERT", "BVALID is low after WLAST fall")
  
    property BVALID_rose_next_cycle_fall;
    @(posedge clk) BVALID && BREADY |=> $fell(BVALID) && $fell(BREADY);
  endproperty: BVALID_rose_next_cycle_fall
  assert property(BVALID_rose_next_cycle_fall) else `uvm_error("ASSERT", "BVALID or BREADY is high after 1 cycle BVALID rose")
  
  
  
  
  
  
    property ARREADY_rose_next_cycle_fall;
    @(posedge clk) ARVALID && ARREADY |=> $fell(ARREADY) && $fell(ARVALID);
  endproperty: ARREADY_rose_next_cycle_fall
  assert property(ARREADY_rose_next_cycle_fall) else `uvm_error("ASSERT", "ARVALID or ARREADY is high after 1 cycle ARREADY rose")
  
    property ARADDR_stable_during_ARVALID;
	  logic [WIDTH-1:0] addr1;
    @(posedge clk) ($rose(ARVALID),addr1 = ARADDR)  |-> ARADDR == addr1 throughout ARVALID;
  endproperty: ARADDR_stable_during_ARVALID
  assert property(ARADDR_stable_during_ARVALID) else `uvm_error("ASSERT", "ARADDR not stable during ARVALID")
  
    property read_RDATA_after_AWREADY_fell;
    @(posedge clk) $fell(ARREADY) |=> ##[0:$] ($rose(RLAST) && RVALID);
  endproperty: read_RDATA_after_AWREADY_fell
  assert property(read_RDATA_after_AWREADY_fell) else `uvm_error("ASSERT", "must read data after ARREADY fell")
  
    property RDATA_stable_during_RVALID;
	  logic [WIDTH-1:0] d1;
    @(posedge clk) ($rose(RVALID),d1 = RDATA)  |-> RDATA == d1 throughout RVALID;
  endproperty: RDATA_stable_during_RVALID
  assert property(RDATA_stable_during_RVALID) else `uvm_error("ASSERT", "RDATA not stable during RVALID")
 
 

  initial begin: assertion_control
    fork
      forever begin
        wait(reset);
        $assertoff();
        @(negedge reset);
        if(has_checks)
		$asserton();
      end
    join_none
  end
  
endinterface

`endif
