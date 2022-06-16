
module ODESA
#(parameter p_width = 9)
(
input                  i_clk_l1,
input                  i_clk_l2,
input                  i_rst_n,
input  [8:1]           i_event,
input  [4:1]           i_label,
output                 o_endof_epochs,
output [4:1]           o_spike_out
);


wire [2:1]           w_spikeout_l1;
wire                 w_endof_epochs;
wire [2*p_width-1:0] w_tr_l2;
assign     o_endof_epochs = w_endof_epochs;
L2
#(.p_width(p_width)) u_l2
(
.i_clk(i_clk_l2),
.i_rst_n(i_rst_n),
.i_event(w_spikeout_l1),
.i_label(i_label),
.i_endof_epochs(w_endof_epochs),
.o_tr(w_tr_l2),
.o_las(w_las_l2),
.o_gas(w_gas),
.o_spike_out(o_spike_out)
);

L1
#(.p_width(p_width)) u_l1
(
.i_clk(i_clk_l1),
.i_rst_n(i_rst_n),
.i_event(i_event),
.i_tr(w_tr_l2),
.i_las(w_las_l2),
.i_gas(w_gas),
.o_las(),
.o_endof_epochs(w_endof_epochs),
.o_spike_out(w_spikeout_l1)
);

endmodule