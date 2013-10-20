module SerialSDCard_top(osc_in,nreset,usb_rx,usb_tx,audio_r,audio_l,led1,led2,led3,led4,sd_clk,sd_cmd,sd_data);

input osc_in;
input nreset;
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

reg [7:0] led;
reg [7:0] led_latch;
reg reset;
reg [2:0] reset_cpt;
reg [34:0] cpt;


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
    .cfg_dat_o(cfg_dat)
    );

//assign dat_done = 1'b0;
assign cfg_done = 1'b1;

always @(posedge clk50M) begin
 // if (detach == 1'b1) cfg_done <= 1'b1;

  if (cfg_clk == 1'b0) begin
    led <={led[6:0],cfg_dat};
    cpt <= cpt + 1;
    if (cpt[2:0] == 3'b000) begin
      led_latch <= led;
	 end
    if (cpt== 19878974*8) begin
      dat_done <= 1'b1;
	 end	 
  end
  
  if (reset_cpt < 3'b111) begin
    reset_cpt <= reset_cpt +1;
    cpt <= 0;
  end
	 
  if (reset_cpt == 3'b111)
    reset <= 1'b1;




end


assign led1 = led[0];
assign led2 = led[1];
assign led3 = led[2];
assign led4 = led[3];

assign audio_r =  1'b0;
assign audio_l = 1'b0;

assign usb_rx = 1'b1;

initial begin
  reset <= 1'b0;
  reset_cpt <= 3'b000;
  dat_done <=1'b0;
end


endmodule
