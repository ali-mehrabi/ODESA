`timescale 1ns/1ns

module L2_tb();
parameter  p_lvl_1_dt = 15;
parameter  p_lvl_2_dt = 7;
parameter  p_width = 9;
parameter  p_clk_lvl_2 = 15625;         //32KHz clk
parameter  p_clk_lvl_1 = p_clk_lvl_2/2; //64KHZ clk
parameter  p_dt = 24*p_clk_lvl_1;      //16*p_clk_lvl_1;
parameter  p_wait = 900*p_clk_lvl_1;
parameter  p_spl = 2*p_clk_lvl_1;
parameter  p_dlt = p_dt-p_spl;
parameter  p_latency_l2 = 5*p_clk_lvl_2;
 
integer     j;
//genvar      n;
reg         r_rst_n;
reg         r_clk_lvl_1;
reg         r_clk_lvl_2;
reg  [2:1]  r_event;
reg  [4:1]  r_label;
reg         r_endof_epochs;
wire [4:1]  w_spike_out;
wire [17:0] w_tr;
wire        w_las_l2;
wire        w_gas;
L2 #(.p_width(p_width)) uut
(
.i_clk(r_clk_lvl_2),
.i_rst_n(r_rst_n),
.i_event(r_event),
.i_label(r_label),
.i_endof_epochs(r_endof_epochs),
.o_tr(w_tr),
.o_las(w_las_l2),
.o_gas(w_gas),
.o_spike_out(w_spike_out)
 );

always #p_clk_lvl_1  r_clk_lvl_1 <= ~r_clk_lvl_1;
always #p_clk_lvl_2  r_clk_lvl_2 <= ~r_clk_lvl_2;
///  input stimuli
initial
begin
		r_clk_lvl_1 = 0;
		r_clk_lvl_2 = 0;
		r_endof_epochs = 0;
		r_rst_n = 0;
		r_event = 2'b0;
#10     r_rst_n = 1; 
#p_dt   ;

for(j = 0; j<= 63; j = j+1)
  begin
	///  pattern /
	       
		   r_event = 2'b01;
	#p_spl r_event = 2'b00;
	#p_dt;
	#p_dlt r_event = 2'b01;
	       r_label = 4'b0001;
	#p_spl r_event = 2'b00;
	#p_dt;
	#p_dt;
	#p_dt;	
    #p_wait;
    r_label = 4'b0000;	
  end

#p_wait;	  
#p_wait;  
#p_wait;

for(j = 0; j<= 63; j = j+1)
  begin
	///  pattern /  
		   r_event = 2'b01;
	#p_spl r_event = 2'b00;
	#p_dt;
	#p_dlt r_event = 2'b10;
	       r_label = 4'b0010;
	#p_spl r_event = 2'b00;
	#p_dt;
	#p_dt;
	#p_dt;	
    #p_wait;
    r_label = 4'b0000;	
  end

#p_wait;	  
#p_wait;  
#p_wait;
for(j = 0; j<= 63; j = j+1)
  begin
	///  pattern /
	       
		   r_event = 2'b10;
	#p_spl r_event = 2'b00;
	#p_dt;
	#p_dlt r_event = 2'b01;
	       r_label = 4'b0100;
	#p_spl r_event = 2'b00;
	#p_dt;
	#p_dt;
	#p_dt;	
    #p_wait;
	r_label = 4'b0000;
  end

#p_wait;	  
#p_wait;  
#p_wait;

for(j = 0; j<= 63; j = j+1)
  begin
	///  pattern /
	       
		   r_event = 2'b10;
	#p_spl r_event = 2'b00;
	#p_dt;
	#p_dlt r_event = 2'b10;
	       r_label = 4'b1000;
	#p_spl r_event = 2'b00;
	#p_dt;
	#p_dt;
	#p_dt;	
    #p_wait;
    r_label = 4'b0000;	
  end

#p_wait;	  
#p_wait;  
#p_wait;
r_endof_epochs = 1;
end // end event stimuli


endmodule