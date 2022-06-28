`timescale 1ns/1ns

module auto_trainer_tb();


reg   r_clk;
reg   r_rst_n;

wire  w_label;
wire  w_test_vector;
wire  w_epochs;

auto_trainer uut(
.i_clk(r_clk),
.i_rst_n(r_rst_n),
.o_end_of_epochs(w_epochs),
.o_test_vector(w_test_vector),
.o_label(w_label)
);

always #10 r_clk <= ~r_clk; 

initial 
begin
     r_clk = 0; 
     r_rst_n = 0; 
#10  r_rst_n = 1; 
end

endmodule
