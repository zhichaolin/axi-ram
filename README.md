# Project Title

Verifying a simple ram module using AXI Master/Slave UVM method. 

## Description

Project aims to test ram module using UVM method. The Ram module is used to perform simple write/read operations to specific addresses. We run it using the AXI protocol. We generate the input from the sequencer. Then we drive our memory module through the driver module. The monitoring block reads information about each transaction from the interface and sends them to the scoreboard module. The scoreboard module compares the results and shows us the final result of whether the operation was executed successfully or not.

## Acknowledgments

For my ram DUT we used, https://github.com/alexforencich/verilog-axi/blob/master/rtl/axi_ram.v