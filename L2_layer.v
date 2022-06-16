module L2_layer
#(parameter p_width = 9)
(
input                         i_clk,
input                         i_rst_n,
input   [2:1]                 i_event,
input   [4*(2*p_width)-1:0]   i_weight,
input   [4*(2*p_width+1)-1:0] i_threshold,
output  [(2*p_width)-1:0]     o_tr,
output  [4*(2*p_width+1)-1:0] o_lv,
output  [4:1]                 o_spike_out
);

genvar i;
wire [p_width-1:0]   w_weight_1[4:1];
wire [p_width-1:0]   w_weight_2[4:1];
wire [2*p_width:0]   w_threshold[4:1];
wire [p_width-1:0]   w_tr_1;
wire [p_width-1:0]   w_tr_2;
wire [2*p_width:0]   w_lv[4:1];
wire [2*p_width:0]   w_neuron_out[4:1];
wire [4:1]           w_spike_out;
wire [4:1]           w_index;
wire [2:1]           w_event[4:1];



assign o_tr = {w_tr_2,w_tr_1};
assign o_lv = {w_lv[4],w_lv[3],w_lv[2],w_lv[1]};
assign o_spike_out = w_spike_out;

generate
for(i=1;i<=4; i=i+1)
  begin : gen_wt
	assign w_weight_1[i] = i_weight[(2*i-1)*p_width-1:(2*i-2)*p_width];
	assign w_weight_2[i] = i_weight[2*i*p_width-1:(2*i-1)*p_width];
	assign w_threshold[i] = i_threshold[i*(2*p_width+1)-1:(i-1)*(2*p_width+1)];
  end
endgenerate

// for(i=1;i<=4; i=i+1)
  // begin : gen_event
	// assign w_event[i] = {i_event[2], i_event[1]};
  // end

neuron_2in
#(.p_input_width(p_width),
  .p_weight_width(p_width)) u_neuron_2in_1
(
.i_clk(i_clk),
.i_spike(w_spike_out[1]),
.i_rst_n(i_rst_n),
.i_event({i_event[2], i_event[1]}),
.i_weight_1(w_weight_1[1]),
.i_weight_2(w_weight_2[1]),
.i_threshold(w_threshold[1]),
.o_tr_1(w_tr_1),
.o_tr_2(w_tr_2),
.o_lv(w_lv[1]),
.o_neuron_out(w_neuron_out[1])
); 

neuron_2in
#(.p_input_width(p_width),
.p_weight_width(p_width)) u_neuron_2in_2
(
.i_clk(i_clk),
.i_spike(w_spike_out[2]),
.i_rst_n(i_rst_n),
.i_event({i_event[2], i_event[1]}),
.i_weight_1(w_weight_1[2]),
.i_weight_2(w_weight_2[2]),
.i_threshold(w_threshold[2]),
.o_tr_1(),
.o_tr_2(),
.o_lv(w_lv[2]),
.o_neuron_out(w_neuron_out[2])
);

neuron_2in
#(.p_input_width(p_width),
.p_weight_width(p_width)) u_neuron_2in_3
(
.i_clk(i_clk),
.i_spike(w_spike_out[3]),
.i_rst_n(i_rst_n),
.i_event({i_event[2], i_event[1]}),
.i_weight_1(w_weight_1[3]),
.i_weight_2(w_weight_2[3]),
.i_threshold(w_threshold[3]),
.o_tr_1(),
.o_tr_2(),
.o_lv(w_lv[3]),
.o_neuron_out(w_neuron_out[3])
);

neuron_2in
#(.p_input_width(p_width),
.p_weight_width(p_width)) u_neuron_2in_4
(
.i_clk(i_clk),
.i_spike(w_spike_out[4]),
.i_rst_n(i_rst_n),
.i_event({i_event[2], i_event[1]}),
.i_weight_1(w_weight_1[4]),
.i_weight_2(w_weight_2[4]),
.i_threshold(w_threshold[4]),
.o_tr_1(),
.o_tr_2(),
.o_lv(w_lv[4]),
.o_neuron_out(w_neuron_out[4])
);

// for(i=1;i<=4; i=i+1)
  // begin: u_neuron_2in_ 
	// neuron_2in
	// #(.p_input_width(p_width),
    //  .p_weight_width(p_width)) u_neuron_2in
	// (
	// .i_clk(i_clk),
	// .i_spike(w_spike_out[i]),
	// .i_rst_n(i_rst_n),
	// .i_event(w_event[i]),
	// .i_weight_1(w_weight_1[i]),
	// .i_weight_2(w_weight_2[i]),
	// .i_threshold(w_threshold[i]),
	// .o_tr_1(w_tr_1[i]),
	// .o_tr_2(w_tr_2[i]),
	// .o_lv(w_lv[i]),
	// .o_neuron_out(w_neuron_out[i])
	// );
  // end
// endgenerate

comparator_4in 
#(.p_width(2*p_width+1)) u_comp4
(   .i_clk(i_clk),
    .i_rst_n(i_rst_n),
	.i_a(w_neuron_out[1]),
	.i_b(w_neuron_out[2]),
	.i_c(w_neuron_out[3]),
	.i_d(w_neuron_out[4]),
	.o_result(),
	.o_index(w_index)
);

// generate
// for(i=1;i<=4;i=i+1)
// begin: gen_sp
  // spike_generator u_spike_out_4 (
	// .i_event(w_index[i]),
	// .i_clk(i_clk),
	// .i_rst_n(i_rst_n),
	// .o_spike(w_spike_out[i])
	// );
// end
// endgenerate

spikeout_gen u_spg(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_spike_in(i_event),
.i_spike(w_index),
.o_spike(w_spike_out)
);



endmodule 