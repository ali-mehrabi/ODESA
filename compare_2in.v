
module comparator_2in
#(parameter  p_width = 21)
(
input  i_clk,
input  i_rst_n,
input  [p_width-1:0]  i_a,
input  [p_width-1:0]  i_b,
output [p_width-1:0]  o_result,
output [1:0]          o_index
);

// wire   w_t1, w_t2;
// assign w_t1 = (i_a >= i_b) ? 1:0; 
// assign w_t2 = ((i_a | i_b) == 0) ? 1:0;
// assign o_index = (w_t2)? 2'b00:(w_t1)? 2'b01:2'b10; 
// assign o_result = (w_t2)? 0:(w_t1)? i_a:i_b;

wire  w_z;
wire  [1:0] w_t1, w_t2; 
wire  [1:0]  w_index;
reg   [1:0]  r_index;
assign w_z = ((i_a | i_b) == 0)? 1:0;
assign w_t1 = (i_a>=i_b)? 2'b01:2'b10; 
assign w_index = w_z? 2'b00: w_t1;
assign o_result = (i_a>=i_b)? i_a:i_b;
assign o_index = r_index;

always @( posedge ~i_clk or negedge i_rst_n)
begin
if(!i_rst_n) 
  r_index <= 2'b0;
else 
  r_index <= w_index;
end

endmodule 