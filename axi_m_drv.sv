`timescale 1ns / 1ps

`ifndef DRIVER
`define DRIVER

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "axi_subscriber.sv"

class axi_m_driver #(
    int WIDTH = 32,
    SIZE = 3
) extends uvm_driver#(axi_m_Sequence_Item#(WIDTH, SIZE));

  `uvm_component_utils_begin(axi_m_driver#(WIDTH, SIZE))
  `uvm_component_utils_end
  
   AXI_Subscriber #(`WIDTH, `SIZE) sub;

  virtual interface axi_intf #(WIDTH, SIZE) intf;

  uvm_analysis_port #(axi_m_Sequence_Item #(WIDTH, SIZE)) drv2sb_port;

  // new
  int RW;
  //

  axi_m_Sequence_Item #(WIDTH, SIZE) tx;

  function new(string name = "axi_m_driver", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv2sb_port = new("drv2sb_port", this);
	sub = AXI_Subscriber#(`WIDTH, `SIZE)::type_id::create("sub", this);
  endfunction : build_phase


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual interface axi_intf #(WIDTH, SIZE))::get(this, "", "intf", intf))
      `uvm_error("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".intf"})
	sub.write(intf);
	
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
	super.run_phase(phase);
	// fork
		// reset_intf();
	// join_none
	fork
		sub.do_sample();
		my_send_drv_msg();
	join
  endtask : run_phase
  
  task reset_intf();
	  forever begin
		@(negedge intf.reset) 
		intf.AWVALID <= 1'b0;
		intf.WVALID <= 1'bz;
		intf.BREADY = 1'b0;
		intf.ARVALID <= 1'b0;
	end
  endtask
  
  task send_data();
	  if(req.WVALID == 1)begin
		  sent_data_write_trx();
		  if(req.WLAST == 1'b1)received_resp_write();
		  drv2sb_port.write(req);
		  sent_data_read_trx();
	  end
  endtask
  

  task my_send_drv_msg();
  forever begin

    seq_item_port.get_next_item(req);


    @(posedge intf.clk) 
	req.RDATA = req.WDATA;
    req.ARADDR = req.AWADDR;
    req.ARLEN = req.AWLEN;
    req.ARSIZE = req.AWSIZE;
    req.ARBURST = req.AWBURST;

    $display("drv seq print:");
    req.print();
	

	fork 
      sent_addr_write_trx();
      send_data();
	join

	seq_item_port.item_done();
   	seq_item_port.put(req);
  end
  endtask

  task sent_trx_to_seq();
    begin
      case (RW)
        0: drv2sb_port.write(req);
        1: `uvm_error("NOTYPE", {"type not support in sent_trx_to_seq Loop"})
      endcase
    end
  endtask
  
  task sent_addr_write_trx();
	if(req.AWVALID)begin
		@(posedge intf.clk) begin
		  begin
			intf.AWVALID <= req.AWVALID;
			intf.AWADDR <= req.AWADDR;
			intf.AWBURST <= req.AWBURST;
			intf.AWSIZE <= req.AWSIZE;
			intf.AWLEN <= req.AWLEN;
			intf.AWID <= req.AWID;
			 @(posedge intf.clk iff (intf.AWREADY))
			intf.AWVALID <= 1'b0;
			intf.AWBURST <= '0;
			intf.AWSIZE <= '0;
			intf.AWLEN <= '0;
			intf.AWID <= '0;
			// intf.AWADDR <= '0;
			sent_addr_read_trx();
			$display("sent addr done");
		  end
		end
	end
  endtask

  
  task sent_data_write_trx();
    @(posedge intf.clk) begin
      intf.WVALID <= req.WVALID;
      // intf.WSTRB <= req.WSTRB;//选中哪几个字写入
	  intf.WSTRB <= 4'b1111;
      intf.WDATA <= req.WDATA;
      intf.WLAST <= req.WLAST;
	 
	   @(posedge intf.clk iff (intf.WREADY))
      intf.WVALID <= 1'b0;
      intf.WSTRB <= 1'b0;
      intf.WDATA <= '0;
      intf.WLAST <= 1'b0;
	  $display("write data done");
	  end
  endtask
  

  task received_resp_write();
  
	  intf.BREADY <= 1'b1;
	  @(posedge intf.clk iff intf.BVALID) 
		intf.BREADY <= 1'b0;
		
	  $display("received write resp done");
  endtask

  task sent_addr_read_trx();
    //#55
    @(posedge intf.clk) begin
	  intf.ARVALID <= req.AWVALID;
      intf.ARADDR <= req.AWADDR;
      intf.ARLEN <= req.AWLEN;
	  intf.ARBURST <= req.AWBURST;
      intf.ARSIZE <= req.AWSIZE;
      intf.ARID <= req.AWID;
		
	  @(posedge intf.clk iff (intf.ARREADY))
	  intf.ARVALID <= 1'b0;
      // intf.ARADDR <= '0;
      intf.ARLEN <= 1'b0;
      intf.ARBURST <= 1'b0;
      intf.ARSIZE <= 1'b0;
      intf.ARID <= 1'b0;
    end
  endtask
  
  
  task sent_data_read_trx();
    @(posedge intf.clk) 
      intf.RREADY <= 1'b1;
	 
	@(posedge intf.clk iff (intf.RVALID))
      intf.RREADY <= 1'b0;
	  $display("read data done");
  endtask
  

endclass

`endif