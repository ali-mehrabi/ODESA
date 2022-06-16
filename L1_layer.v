module L1_layer
#(parameter p_width = 9)
(
input                          i_clk,
input                          i_rst_n,
input   [8:1]                  i_event,
input   [2*(8*p_width)-1:0]    i_weight,
input   [2*(2*p_width+3)-1:0]  i_threshold,
output  [2*(8*p_width)-1:0]    o_tr,
output  [2*(2*p_width+3)-1:0]  o_lv,
output  [2:1]                  o_spike_out
);

genvar i;
genvar j;
parameter p_n = 8; //num of synapse in each neuron
wire [p_width-1:0]       w_weight[2:1][8:1];
wire [p_width-1:0]       w_tr[2:1][8:1];
wire [(2*p_width+3)-1:0] w_threshold[2:1];
wire [(2*p_width+3)-1:0] w_lv[2:1];
wire [(2*p_width+3)-1:0] w_neuron_out[2:1];
wire [2:1]               w_spike_out;
wire [2:1]               w_index;

assign o_spike_out = w_spike_out;

generate
for(i=1;i<= 2;i=i+1)
begin: gen_i
  for(j=1;j<= p_n;j=j+1)
    begin: gen_w_tr_j
      assign  w_weight[i][j] = i_weight[(i-1)*(p_n*p_width)+j*p_width-1: (i-1)*(p_n*p_width)+(j-1)*p_width];
      assign  o_tr[(i-1)*(p_n*(p_width))+j*(p_width)-1:(i-1)*(p_n*(p_width))+(j-1)*(p_width)] = w_tr[i][j];
	 end	
end


for(i=1;i<=2;i=i+1)
begin :gen_th_lv
  assign  w_threshold[i] = i_threshold[i*(2*p_width+3)-1:(i-1)*(2*p_width+3)];
  assign  o_lv[i*(2*p_width+3)-1:(i-1)*(2*p_width+3)] = w_lv[i];
end

for(i=1;i<=2; i=i+1)
  begin: u_neuron_8in_l1 
	neuron
	#(
	.p_input_width(p_width),
    .p_weight_width(p_width)) u_neuron8in
	(
	.i_clk(i_clk),
	.i_spike(w_spike_out[i]),
	.i_rst_n(i_rst_n),
	.i_event(i_event),
	.i_weight_1(w_weight[i][1]),
	.i_weight_2(w_weight[i][2]),
	.i_weight_3(w_weight[i][3]),
	.i_weight_4(w_weight[i][4]),
	.i_weight_5(w_weight[i][5]),
	.i_weight_6(w_weight[i][6]),
	.i_weight_7(w_weight[i][7]),
	.i_weight_8(w_weight[i][8]),
	.i_threshold(w_threshold[i]),
	.o_tr_1(w_tr[i][1]),
	.o_tr_2(w_tr[i][2]),
	.o_tr_3(w_tr[i][3]),
	.o_tr_4(w_tr[i][4]),
	.o_tr_5(w_tr[i][5]),
	.o_tr_6(w_tr[i][6]),
	.o_tr_7(w_tr[i][7]),
	.o_tr_8(w_tr[i][8]),
	.o_lv(w_lv[i]),
	.o_neuron_out(w_neuron_out[i])
	);
  end
  
for(i=1;i<=2;i=i+1)
begin: gen_sp_out
	spike_generator u_spike_out_x (
	.i_event(w_index[i]),
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.o_spike(w_spike_out[i])
	);
end  
endgenerate

comparator_2in 
#(.p_width((2*p_width+3))) u_comp
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_a(w_neuron_out[1]),
.i_b(w_neuron_out[2]),
.o_result(),
.o_index(w_index)
);

endmodule 