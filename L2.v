
module L2
#(parameter p_width = 9)
(
input                  i_clk,
input                  i_rst_n,
input  [2:1]           i_event,
input  [4:1]           i_label,
input                  i_endof_epochs,
output [2*p_width-1:0] o_tr,
output                 o_las,
output                 o_gas,
output  [4:1]          o_spike_out
);

wire  [4:1]                   w_spike_out;
wire  [4*(2*p_width)-1:0]     w_weight;

wire  [4*(2*p_width+1)-1:0]   w_lv;
wire  [4*(2*p_width+1)-1:0]   w_threshold;

assign  o_spike_out = w_spike_out;


L2_layer 
#(.p_width(p_width)) u_L2
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_event(i_event),
.i_weight(w_weight),
.i_threshold(w_threshold),
.o_tr(o_tr),
.o_lv(w_lv),
.o_spike_out(w_spike_out)
);


L2_train 
#(.p_width(p_width)) u_L2_train
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_event(i_event),
.i_label(i_label),
.i_l2_spikeout(w_spike_out),
.i_ts(o_tr),
.i_lv(w_lv),
.i_endof_epochs(i_endof_epochs),
.o_las(o_las),
.o_gas(o_gas),
.o_weights(w_weight),
.o_thresholds(w_threshold)
 );

endmodule

