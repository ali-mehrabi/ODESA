`timescale 1ns/1ns

module L1_tb();
parameter  p_lvl_1_dt = 15;
parameter  p_lvl_2_dt = 7;
parameter  p_width = 6;
parameter  p_clk_lvl_2 = 15625;         //32KHz clk
parameter  p_clk_lvl_1 = p_clk_lvl_2/2; //64KHZ clk
parameter  p_dt = 24*p_clk_lvl_1;      //16*p_clk_lvl_1;
parameter  p_wait = 900*p_clk_lvl_1;
parameter  p_spl = 2*p_clk_lvl_1;
parameter  p_dlt = p_dt-p_spl;
parameter  p_latency_l2 = 5*p_clk_lvl_2;
 
integer     i,j;
genvar      n;
reg         r_rst_n;
reg  [2:1]  r_spike_out_l2 = 0;
reg         r_clk_lvl_1;
reg         r_clk_lvl_2;
reg  [8:1]  r_event;
reg         r_gas;
reg         r_las;
reg  [8:0]  r_tr[2:1];
reg  [8:0]  r_counter;
reg  [2:1]  r_tr_en=0;
wire        w_las_l1_out;
wire [2:1]  w_spike_out;
wire [8:0]  w_tr[2:1];
wire        w_las_l2;
L1 #(.p_width(9)) uut
(
.i_clk(r_clk_lvl_1),
.i_rst_n(r_rst_n),
.i_event(r_event),
.i_tr({w_tr[2],w_tr[1]}),
.i_las(w_las_l2),
.i_gas(r_gas),
.o_las(w_las_l1_out),
.o_spike_out(w_spike_out)
 );


always #p_clk_lvl_1  r_clk_lvl_1 <= ~r_clk_lvl_1;
always #p_clk_lvl_2  r_clk_lvl_2 <= ~r_clk_lvl_2;
///  input stimuli
initial
begin
		r_clk_lvl_1 = 0;
		r_clk_lvl_2 = 0;
		r_rst_n = 0;
		r_event = 8'h0;
		r_gas = 0;
#10     r_rst_n = 1; 
#p_dt;

for(j = 0; j<= 127; j = j+1)
  begin
	///  pattern /
		   r_event = 8'h01;
	#p_spl r_event = 8'h00;
	#p_dlt r_event = 8'h02;
	#p_spl r_event = 8'h00;
	#p_dlt r_event = 8'h04;
	#p_spl r_event = 8'h00;
	#p_dlt r_event = 8'h08;
	#p_spl r_event = 8'h00;
	#p_dlt r_event = 8'h10;
	#p_spl r_event = 8'h00;	       
	#p_dlt r_event = 8'h20;
	#p_spl r_event = 8'h00;
	       r_gas = 1;
	#p_dlt r_event = 8'h40;
	#p_spl r_event = 8'h00;    
	#p_dlt r_event = 8'h80;
	       //r_gas = 1;
	#p_spl r_event = 8'h00;
	#p_dt  r_gas = 0;
	#p_dt;
	#p_dt;
	//#p_dt;	
    #p_wait;	
  end

#p_wait;	  
#p_wait;  
#p_wait;
 
for(j = 0; j<= 127; j = j+1)
  begin
	//  pattern \
		   r_event = 8'h80;
	#p_spl r_event = 8'h00;
	#p_dlt r_event = 8'h40;
	#p_spl r_event = 8'h00;
	#p_dlt r_event = 8'h20;
	#p_spl r_event = 8'h00;
	#p_dlt r_event = 8'h10;
	#p_spl r_event = 8'h00;
	#p_dlt r_event = 8'h08;
	#p_spl r_event = 8'h00;
	#p_dlt r_event = 8'h04;
	#p_spl r_event = 8'h00;
	#p_dlt r_event = 8'h02;
	#p_spl r_event = 8'h00;
		   r_gas = 1;
	#p_dlt r_event = 8'h01;
	#p_spl r_event = 8'h00;
	#p_dt  r_gas = 0;
	#p_dt;
	#p_dt;
	//#p_dt;
    #p_wait;	
  end
end // end event stimuli

//latch w_spike_out
generate 
for(n=1;n<=2;n=n+1)
  begin:gen_spikeout_reg
    always @(posedge w_spike_out[n]) 
	  begin 
	    #(p_latency_l2) ;
		@(posedge r_clk_lvl_2) r_spike_out_l2[n] <= 1;
		#(p_clk_lvl_2) r_spike_out_l2[n] <= 0;
      end
  end
endgenerate 



always @* 
begin 
  if(w_spike_out == 2'b01) 
     r_tr_en[1] <= 1;
  else if (r_spike_out_l2 == 2'b10) 
     r_tr_en[2] <= 1; 
  else 
     r_tr_en <= 2'b00;    
end

// las activation 
assign w_las_l2 = r_spike_out_l2[2] | r_spike_out_l2[1]; 

reg r_en1=0;
reg r_en2=0;
wire w_reset;
assign w_reset =(r_counter == 1)? 0:1;
always @(posedge r_tr_en[1] or negedge w_reset)
begin
  if(!w_reset)
    r_en1 <=0;
  else
  r_en1 <= 1;
end
always @(posedge r_tr_en[2] or negedge w_reset)
begin
  if(!w_reset)
    r_en2 <=0;
  else
  r_en2 <= 1;
end

always @(posedge r_clk_lvl_2 or negedge r_rst_n)
begin
if(!r_rst_n)
    r_counter <= 9'h3f;
else 
  begin
    if(r_en1 | r_en2 )
      r_counter <= r_counter-1;
    else 
      r_counter <= 9'h3f;
  end	
end	
	

assign w_tr[1] = (r_en1)? r_counter: 0;
assign w_tr[2] = (r_en2)? r_counter: 0;


endmodule