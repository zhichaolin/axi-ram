`timescale 1ns / 1ps

`ifndef SEQUENCE
`define SEQUENCE

import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_single_wr_Sequence #(
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_m_Sequence_Item#(WIDTH, SIZE));

  `uvm_object_param_utils(axi_single_wr_Sequence#(WIDTH, SIZE))

  function new(string name = "axi_single_wr_Sequence");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_create(req)

    //req.AWVALID = 1'b1;
    req.AWBURST.rand_mode(1);  // = 2'b11;
    req.AWSIZE.rand_mode(1);  // = 3'b100;
    req.AWLEN.rand_mode(1);  // = 4'b0101;
    req.AWADDR.rand_mode(1);
    req.AWID.rand_mode(1);  // = 4'b1001;
    req.WSTRB.rand_mode(1);
    req.WDATA.rand_mode(1);

	req.AWVALID = 1'b1;
	req.WVALID = 1'b0;
	`uvm_rand_send_with(req, {req.RW==0; req.AWBURST == 2'b00;req.AWLEN ==0;})
	req.WLAST =1;
	req.AWVALID = 1'b0;
	req.WVALID = 1'b1;
	`uvm_rand_send_with(req, {req.RW==0; req.AWBURST == 2'b00;req.AWLEN ==0;})  //Read sequence

  endtask

endclass


class axi_burst_Sequence #(
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_m_Sequence_Item#(WIDTH, SIZE));

  `uvm_object_param_utils(axi_burst_Sequence#(WIDTH, SIZE))

  function new(string name = "axi_burst_Sequence");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_create(req)
	set_response_queue_depth(512);

    req.AWBURST.rand_mode(1);  // = 2'b11;
    req.AWSIZE.rand_mode(1);  // = 3'b100;
    req.AWLEN.rand_mode(1);  // = 4'b0101;
    req.AWADDR.rand_mode(1);
    req.AWID.rand_mode(1);  // = 4'b1001;
    req.WSTRB.rand_mode(1);
    req.WDATA.rand_mode(1);

	for(bit [(WIDTH/8)-1:0] i = 1; i != 0 ; i++)begin
		req.AWVALID = 1'b1;
		req.WLAST =0;
		req.WVALID = 1'b0;
		`uvm_rand_send_with(req, {req.RW==0; req.AWBURST == 2'b01;req.AWLEN == i;})
		req.AWVALID = 1'b0;
		req.WVALID = 1'b1;
		repeat(i)begin
			req.WLAST =0;
			`uvm_rand_send_with(req, {req.RW==0; req.AWBURST == 2'b01;req.AWLEN ==i;})  //Read sequence
		end
		req.WLAST =1;
		`uvm_rand_send_with(req, {req.RW==0; req.AWBURST == 2'b01;req.AWLEN ==i;})  //Read sequence
	end

  endtask

endclass


class axi_random_address_Sequence #(
    int WIDTH = 32,
    SIZE = 3
) extends uvm_sequence#(axi_m_Sequence_Item#(WIDTH, SIZE));

  `uvm_object_param_utils(axi_random_address_Sequence#(WIDTH, SIZE))

  function new(string name = "axi_random_address_Sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_create(req)
    req.AWBURST.rand_mode(1);  // = 2'b11;
    req.AWSIZE.rand_mode(1);  // = 3'b100;
    req.AWLEN.rand_mode(1);  // = 4'b0101;
    req.AWADDR.rand_mode(1);
    req.AWID.rand_mode(1);  // = 4'b1001;
    req.WSTRB.rand_mode(1);
    req.WDATA.rand_mode(1);
	
	set_response_queue_depth(512);

	repeat(100)begin
		req.AWVALID = 1'b1;
		req.WVALID = 1'b0;
		`uvm_rand_send_with(req, {req.RW==0; req.AWBURST == 2'b00;req.AWLEN == 0;req.AWADDR >1;req.AWADDR <100;})
		req.AWVALID = 1'b0;
		req.WVALID = 1'b1;
		req.WLAST =1;
		`uvm_rand_send_with(req, {req.RW==0; req.AWBURST == 2'b00;req.AWLEN == 0;req.AWADDR >1;req.AWADDR <100;})  //Read sequence
	end
  endtask

endclass

`endif




