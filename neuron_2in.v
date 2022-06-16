module neuron_2in
#(
parameter p_input_width  = 9,
parameter p_weight_width = 9
)
(
input                                     i_clk,
input                                     i_spike,
input                                     i_rst_n,
input   [2:1]                             i_event,
input   [p_weight_width-1:0]              i_weight_1,
input   [p_weight_width-1:0]              i_weight_2,
input   [p_input_width+p_weight_width:0]  i_threshold,
output  [p_input_width-1:0]               o_tr_1,
output  [p_input_width-1:0]               o_tr_2,
output  [p_input_width+p_weight_width:0]  o_lv,
output  [p_input_width+p_weight_width:0]  o_neuron_out
);

wire [p_input_width+p_weight_width-1:0]  w_synapse_out[2:1];
wire [p_input_width+p_weight_width:0]    w_add_value;

assign  o_neuron_out = (w_add_value > i_threshold)? w_add_value: {(p_input_width+p_weight_width+1){1'b0}};
assign  w_add_value = {1'b0,w_synapse_out[2]} + {1'b0,w_synapse_out[1]};

lv_reg
#(.p_width(p_input_width+p_weight_width+1)) u_lv_l2
(
.i_spike(i_spike),
.i_rst_n(i_rst_n),
.i_addvalue(w_add_value),
.o_lv(o_lv)
);

synapse
#(
.p_width(p_input_width),
.p_weight_width(p_weight_width)) u_synps_1 
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_event(i_event[1]),
.i_weight(i_weight_1),
.o_tr(o_tr_1),
.o_cell_out(w_synapse_out[1])
);

synapse
#(
.p_width(p_input_width),
.p_weight_width(p_weight_width)) u_synps_2 
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_event(i_event[2]),
.i_weight(i_weight_2),
.o_tr(o_tr_2),
.o_cell_out(w_synapse_out[2])
);

endmodule

