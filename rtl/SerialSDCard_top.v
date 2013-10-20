module SerialSDCard_top(osc_in,Wing2_CL00,usb_rx,usb_tx,audio_r,audio_l,led1,led2,led3,led4,sd_clk,sd_cmd,sd_data);

input osc_in;
output Wing2_CL00;
output usb_rx; // connected to fpga_uart_tx
input usb_tx; // connected to fpga_uart_rx
output audio_r;
output audio_l;
output led1;
output led2;
output led3;
output led4;
output sd_clk;
inout sd_cmd;
inout [3:0] sd_data;

wire clk50M;
wire detach;
reg dat_done;
wire cfg_done;

wire cfg_clk;
wire cfg_dat;

reg [15:0] data_2B;
wire [7:0] data_1B;
wire valid;
reg [7:0] led_latch;
reg reset;
reg [2:0] reset_cpt;
reg [40:0] cpt;
reg fifo_wr_en;

reg [10:0] tick_48k;
reg fifo_rd_en;

wire [15:0] fifo_out;
wire [15:0] pcm;

wire prog_full;

DCM0 clock (
    .CLKIN_IN(osc_in), 
    .CLKFX_OUT(clk50M), 
    .CLK0_OUT()
    );


chip SD0 (
    .clk_i(clk50M), 
    .reset_i(reset), 
//   .set_sel_n_i(4'b0000), 
    .set_sel_n_i(4'b1111),

    .spi_clk_o(sd_clk), 
    .spi_cs_n_o(sd_data[3]), 
    .spi_data_in_i(sd_data[0]), 
    .spi_data_out_o(sd_cmd), 
    .start_i(1'b1), 
 //   .mode_i(1'b1), 
    .config_n_o(), 
    .detached_o(detach), 
    .cfg_init_n_i(cfg_init_n_i), 
    .cfg_done_i(cfg_done), 
    .dat_done_i(dat_done), 
    .cfg_clk_o(cfg_clk), 
    .cfg_dat_o(data_1B),
    .cfg_hold_i(prog_full),
    .cfg_dat_val_o(valid)
    );

fifo fifo0 (
  .rst(~reset), // input rst
  .wr_clk(clk50M), // input wr_clk
  .rd_clk(clk50M), // input rd_clk
  .din(data_2B), // input [15 : 0] din
  .wr_en(fifo_wr_en), // input wr_en
  .rd_en(fifo_rd_en), // input rd_en
  .dout(fifo_out), // output [15 : 0] dout
  .full(), // output full
  .empty(empty), // output empty
  .prog_full(prog_full) // output prog_full
);


//assign dat_done = 1'b0;
assign cfg_done = 1'b1;

always @(posedge clk50M) begin
 // if (detach == 1'b1) cfg_done <= 1'b1;
  fifo_wr_en <= 1'b0;
  if (cfg_clk == 1'b0 && valid == 1'b1 && cpt[0] == 1'b0) begin
    data_2B[7:0] <= data_1B;
//    data_2B[15:0] <= data_1B;
    cpt <= cpt + 1;
  end
  else if (cfg_clk == 1'b0 && valid == 1'b1 && cpt[0] == 1'b1) begin
    data_2B[15:8] <= data_1B;
//	 data_2B[7:0] <= data_1B;
	 cpt <= cpt + 1;
	 fifo_wr_en <= 1'b1;
  end

//  if (cpt== 19878974) begin
  if (cpt == 30735046 ) begin
    dat_done <= 1'b1;
  end  
  
  if (reset_cpt < 3'b111) begin
    reset_cpt <= reset_cpt +1;
    cpt <= 0;
  end
	 
  if (reset_cpt == 3'b111)
    reset <= 1'b1;

end

always @(posedge clk50M) begin
  if (reset == 0) begin
    tick_48k <= 0;
	 fifo_rd_en <=1'b0;
  end
  else if (tick_48k == 2000)begin
    tick_48k <=0;
	 fifo_rd_en <=1'b1;
  end
  else begin
    tick_48k <= tick_48k+1;
	 fifo_rd_en <= 1'b0;
  end
end

assign Wing2_CL00 = fifo_rd_en;

assign pcm = (empty== 1'b1) ? 16'h8000 : fifo_out;

dac16 dac0 (
    .clk(clk50M), 
    .rst(~reset), 
    .data(pcm), 
    .dac_out(dac_out)
    );



assign led1 = dat_done;
assign led2 = 1'b0;
assign led3 = 1'b0;
assign led4 = 1'b0;

assign audio_r =  dac_out;
assign audio_l = dac_out;

assign usb_rx = 1'b1;

initial begin
  reset <= 1'b0;
  reset_cpt <= 3'b000;
  dat_done <=1'b0;
  fifo_wr_en <= 1'b0;
  data_2B <= 0;
end


endmodule
