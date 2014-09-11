module fifo_fwft_reader
  #(
    parameter WIDTH = 0,
    parameter MAX_BLOCK_SIZE = 1024)
   (
    input 	      clk,
    input [WIDTH-1:0] din,
    output reg	      rden = 1'b0,
    input 	      empty);

   real 	       rate = 0.5;
   integer 	       seed = 0;

   task read_word;
      output [WIDTH-1:0] data_o;

      reg 		 rd;
      real 		 randval;
      
      begin
	 rden = 1'b0;
	 rd = 1'b0;
	 while(empty | !rden) begin
	    randval = $dist_uniform(seed, 0, 1000) / 1000.0;
	    rd = (randval <= rate);

	    rden <= rd;

	    @(posedge clk);
	    data_o = din;
	 end
	 rden <= 1'b0;
      end
   endtask
   
   task read_block;
      output reg [WIDTH*MAX_BLOCK_SIZE-1:0] data_o;
      input integer 			    length_i;
      
      integer 			    index;
      reg [WIDTH-1:0] 		    word;
      
      begin
	 //Cap rate to [0.0-1.0]
	 if(rate > 1.0) rate = 1.0;
	 if(rate < 0.0) rate = 0.0;

	 index = 0;
	 while(index < length_i) begin
	    read_word(word);
	    //$display("%0d : Read word 0x%8x", $time, word);
	    data_o[index*WIDTH+:WIDTH] = word;
	    index = index + 1;
	 end // while (index < length_i)
      end
   endtask
   
endmodule
