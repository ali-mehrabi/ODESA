`timescale 1ns/1ns

module ODESA_COMPLETE__tb();

reg   r_clk;
reg   r_rst_n;

wire  [4:1] w_spike_out;
reg   [8:1] r_events_in;


ODESA_complete 
#(.p_width(9)) uut
(
.i_clk(r_clk),
.i_rst_n(r_rst_n),
.i_event(r_events_in),
.o_spike_out(w_spike_out)
);


always #10 r_clk <= ~r_clk; 

initial 
begin
     r_events_in = 0;
     r_clk = 0; 
     r_rst_n = 0; 
#100  r_rst_n = 1; 
end

endmodule
