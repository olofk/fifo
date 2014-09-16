module fifo_fwft
  #(parameter DATA_WIDTH = 0,
    parameter DEPTH_WIDTH = 0)
   (
    input 		    clk,
    input 		    rst,
    input [DATA_WIDTH-1:0]  din,
    input 		    wr_en,
    output 		    full,
    output reg [DATA_WIDTH-1:0] dout,
    input 		    rd_en,
    output 		    empty,
    output reg [DEPTH_WIDTH-1:0] cnt);

   reg                   fifo_valid, middle_valid, dout_valid;
   reg [DATA_WIDTH-1:0]     middle_dout;

   wire [DATA_WIDTH-1:0]    fifo_dout;
   wire                  fifo_empty, fifo_rd_en;
   wire                  will_update_middle, will_update_dout;

   reg 			 inc_cnt;
   reg 			 dec_cnt;
   
       
   // orig_fifo is just a normal (non-FWFT) synchronous or asynchronous FIFO
   fifo
     #(.DEPTH_WIDTH (DEPTH_WIDTH),
       .DATA_WIDTH  (DATA_WIDTH))
   fifo0
     (
       .clk       (clk),
       .rst       (rst),       
       .rd_en_i   (fifo_rd_en),
       .rd_data_o (fifo_dout),
       .empty_o   (fifo_empty),
       .wr_en_i   (wr_en),
       .wr_data_i (din),
       .full_o    (full));

   assign will_update_middle = fifo_valid && (middle_valid == will_update_dout);
   assign will_update_dout = (middle_valid || fifo_valid) && (rd_en || !dout_valid);
   assign fifo_rd_en = (!fifo_empty) && !(middle_valid && dout_valid && fifo_valid);
   assign empty = !dout_valid;

   always @(posedge clk)
      if (rst)
         begin
            fifo_valid <= 0;
            middle_valid <= 0;
            dout_valid <= 0;
            dout <= 0;
            middle_dout <= 0;
	    cnt <= 0;
         end
      else
        begin
	   inc_cnt = wr_en;
	   dec_cnt = fifo_rd_en & !fifo_empty;

	   if(inc_cnt & !dec_cnt)
	     cnt <= cnt + 1;
	   else if(dec_cnt & !inc_cnt)
	     cnt <= cnt - 1;
	   
            if (will_update_middle)
               middle_dout <= fifo_dout;
            
            if (will_update_dout)
               dout <= middle_valid ? middle_dout : fifo_dout;
            
            if (fifo_rd_en)
               fifo_valid <= 1;
            else if (will_update_middle || will_update_dout)
               fifo_valid <= 0;
            
            if (will_update_middle)
               middle_valid <= 1;
            else if (will_update_dout)
               middle_valid <= 0;
            
            if (will_update_dout)
               dout_valid <= 1;
            else if (rd_en)
               dout_valid <= 0;
         end 
endmodule
