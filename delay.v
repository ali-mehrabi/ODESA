module delay(
input i_clk,
input i_rst_n,
input [1:0]  i_spike_in,
input [3:0]  i_spike,
output [3:0] o_spike
);
parameter p_delay = 5;

reg [$clog2(p_delay):0] r_counter;
reg       r_event_on;
wire      w_event_on;
wire      w_reset_n;
wire      w_en_spike;
assign w_event_on = i_spike_in[0] | i_spike_in[1];
assign w_en_spike = (r_counter >=3)? 1'b1:1'b0;
assign w_reset_n = (r_counter == p_delay || !i_rst_n)? 1'b0:1'b1;

always @(posedge w_event_on or negedge w_reset_n) 
begin 
  if(!w_reset_n) 
    r_event_on <= 1'b0;
  else 
    r_event_on <= 1'b1;
end

always @(posedge i_clk or negedge i_rst_n)
begin
  if(!i_rst_n)
     r_counter <= 0; 
  else if(r_counter < p_delay  && r_event_on) 
     r_counter <= r_counter+1; 
  else 
     r_counter <= 0;
end


spike_generator u1(
.i_event(i_spike[0]),
.i_clk(i_clk),
.i_rst_n(w_en_spike),
.o_spike(o_spike[0])
);

spike_generator u2(
.i_event(i_spike[1]),
.i_clk(i_clk),
.i_rst_n(w_en_spike),
.o_spike(o_spike[1])
);

spike_generator u3(
.i_event(i_spike[2]),
.i_clk(i_clk),
.i_rst_n(w_en_spike),
.o_spike(o_spike[2])
);

spike_generator u4(
.i_event(i_spike[3]),
.i_clk(i_clk),
.i_rst_n(w_en_spike),
.o_spike(o_spike[3])
);
endmodule