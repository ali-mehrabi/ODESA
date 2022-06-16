

module delay_tb();

reg r_clk;
reg r_rst_n;
reg  [3:0] r_spike; 
reg  [1:0] r_spike_in; 
wire [1:0]  w_en_spike;

delay uut 
(
.i_clk(r_clk),
.i_rst_n(r_rst_n),
.i_spike_in(r_spike_in),
.i_spike(r_spike),
.o_spike(w_en_spike)
);

always #10 r_clk <= ~ r_clk;
initial 
begin
  r_rst_n = 0;
  r_clk = 0; 
  r_spike = 2'b00;
  r_spike_in = 0;

#15  r_rst_n = 1; 
#120 r_spike_in = 2'b01;
#5   r_spike_in = 2'b00;
#25  r_spike = 4'b0001;
#5   r_spike = 4'b0000;
#25  r_spike = 4'b0100;
#5   r_spike = 4'b0000;

#120 r_spike_in = 2'b01;
#5   r_spike_in = 2'b00;
#25  r_spike = 4'b0001;
#5   r_spike = 4'b0000;
#25  r_spike = 4'b0100;
#5   r_spike = 4'b0000;

#500 r_spike_in = 2'b10;
#5   r_spike_in = 2'b00;
#30  r_spike = 4'b0100;
#5   r_spike = 4'b0000;
#55  r_spike = 4'b0001;
#5   r_spike = 4'b0000;

#500 r_spike_in = 2'b10;
#5   r_spike_in = 2'b00;
#30  r_spike = 4'b0010;
#5   r_spike = 4'b0000;
#55  r_spike = 4'b1000;
#5   r_spike = 4'b0000;

#100;
#30  r_spike = 4'b0010;
#5   r_spike = 4'b0000;
#155 r_spike = 4'b1000;
#5   r_spike = 4'b0000;
end

endmodule