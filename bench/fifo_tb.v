module fifo_tb;
   localparam aw = 32;
   localparam dw = 16;
   localparam FIFO_MAX_BLOCK_SIZE = 128;
   
   vlog_tb_utils vlog_tb_utils0();
   
   
   reg clk = 1'b1;
   reg rst = 1'b1;
   
   always#10 clk <= ~clk;
   initial #100 rst <= 0;

   wire [dw-1:0] wr_data;
   wire 	 wr_en;
   wire [dw-1:0] rd_data;
   wire 	 rd_en;
   wire 	 full;
   wire 	 empty;
   
   fifo_fwft
     #(.DEPTH_WIDTH (4),
       .DATA_WIDTH  (dw))
   dut
     (.clk (clk),
      .rst (rst),

      .din    (wr_data),
      .wr_en   (wr_en),
      .full    (full),
      
      .dout (rd_data),
      .rd_en   (rd_en),
      .empty   (empty));

   fifo_writer
     #(.WIDTH (dw),
       .MAX_BLOCK_SIZE (FIFO_MAX_BLOCK_SIZE))
   fifo_writer0
     (.clk (clk),
      .dout (wr_data),
      .wren (wr_en),
      .full (full));

   fifo_fwft_reader
     #(.WIDTH (dw),
       .MAX_BLOCK_SIZE (FIFO_MAX_BLOCK_SIZE))
   fifo_reader0
     (.clk (clk),
      .din  (rd_data),
      .rden (rd_en),
      .empty (empty));
   
   integer 	     i;

   integer 	     tmp;
   integer 	     seed;

   reg [dw*FIFO_MAX_BLOCK_SIZE-1:0] wr_data_block;
   reg [dw*FIFO_MAX_BLOCK_SIZE-1:0] rd_data_block;
   integer 			    length;
   
   //Stimuli writer
   initial begin
      @(negedge rst);
      @(posedge clk);

      for(i=0 ; i<FIFO_MAX_BLOCK_SIZE ; i=i+1) begin
	 tmp = $random(seed);
	 wr_data_block[dw*i+:dw] = tmp[dw-1:0];
      end

      length = FIFO_MAX_BLOCK_SIZE;

      fifo_writer0.write_block(wr_data_block, length);
      $display("Done sending data");
   end
//FIXME : fork/join?
   //Stimuli reader
   initial begin
      @(negedge rst);
      @(posedge clk);

      length = FIFO_MAX_BLOCK_SIZE;
      fifo_reader0.read_block(rd_data_block, length);
      if(wr_data_block == rd_data_block)
	$display("Success");
      else
	$display("Error :(");
      $finish;
      
   end

endmodule
