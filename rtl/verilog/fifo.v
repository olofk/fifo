/******************************************************************************
 This Source Code Form is subject to the terms of the
 Open Hardware Description License, v. 1.0. If a copy
 of the OHDL was not distributed with this file, You
 can obtain one at http://juliusbaxter.net/ohdl/ohdl.txt

 Description: Store buffer
 Currently a simple single clock FIFO, but with the ambition to
 have combining and reordering capabilities in the future.

 Copyright (C) 2013 Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>

 ******************************************************************************/

module fifo
  #(
    parameter DEPTH_WIDTH = 0,
    parameter DATA_WIDTH = 0
    )
   (
    input 		    clk,
    input 		    rst,

    input [DATA_WIDTH-1:0]  wr_data_i,
    input 		    wr_en_i,

    output [DATA_WIDTH-1:0] rd_data_o,
    input 		    rd_en_i,

    output 		    full_o,
    output 		    empty_o
    );

   //synthesis translate_off
   initial begin
      if(DEPTH_WIDTH < 1) $error("%m : Error: DEPTH_WIDTH must be > 0");
      if(DATA_WIDTH < 1) $error("%m : Error: DATA_WIDTH must be > 0");
   end
   
   //synthesis translate_on
   wire [DATA_WIDTH-1:0] 		fifo_dout;
   reg [DATA_WIDTH-1:0] 		fifo_dout_r;

   reg [DEPTH_WIDTH-1:0] 		write_pointer;
   reg [DEPTH_WIDTH-1:0] 		read_pointer;
   wire [DEPTH_WIDTH-1:0] 		prev_read_pointer;

   reg 					read_r;

   assign rd_data_o = read_r ? fifo_dout : fifo_dout_r;

   assign prev_read_pointer = read_pointer - 1;

   assign full_o = write_pointer == prev_read_pointer;
   assign empty_o = write_pointer == read_pointer;

   // TODO: add read enable to RAM?
   always @(posedge clk) begin
      read_r <= rd_en_i;

      if (read_r)
	fifo_dout_r <= fifo_dout;

      if (wr_en_i)
	write_pointer <= write_pointer + 1;

      if (rd_en_i)
	read_pointer <= read_pointer + 1;

      if (rst) begin
	 read_pointer <= 0;
	 write_pointer <= 0;
      end
   end

   simple_dpram_sclk
     #(
       .ADDR_WIDTH(DEPTH_WIDTH),
       .DATA_WIDTH(DATA_WIDTH),
       .ENABLE_BYPASS("FALSE")
       )
   fifo_ram
     (
      .clk			(clk),
      .dout			(fifo_dout),
      .raddr			(read_pointer),
      .waddr			(write_pointer),
      .we			(wr_en_i),
      .din			(wr_data_i)
      );

endmodule
