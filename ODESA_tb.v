

module ODESA_tb();
parameter  p_lvl_1_dt = 15;
parameter  p_lvl_2_dt = 7;
parameter  p_width = 9;
parameter  p_clk_lvl_2 = 20000;//5625;         //32KHz clk
parameter  p_clk_lvl_1 = 15625/2; //64KHZ clk
parameter  p_dt = 16*p_clk_lvl_1;      //16*p_clk_lvl_1;
parameter  p_wait = 900*p_clk_lvl_1;
parameter  p_spl = 2*p_clk_lvl_1;
parameter  p_dlt = p_dt-p_spl;
parameter  p_latency_l2 = 5*p_clk_lvl_2;
parameter  p_delay = 132*p_clk_lvl_1;

integer     i,j;
genvar      n;
reg         r_rst_n;
reg         r_clk_lvl_1;
reg         r_clk_lvl_2;
reg  [8:1]  r_event;
reg  [4:1]  r_label;
wire [4:1]  w_spikeout_l2;
wire        w_endof_epochs;


always #p_clk_lvl_1  r_clk_lvl_1 <= ~r_clk_lvl_1;
always #p_clk_lvl_2  r_clk_lvl_2 <= ~r_clk_lvl_2;
///  input stimuli
initial
begin
		r_clk_lvl_1 = 0;
		r_clk_lvl_2 = 0;
		r_rst_n = 0;
		r_event = 8'h0;
		r_label = 4'b0000;
#10     r_rst_n = 1; 
#p_delay;
#p_delay;

for(j = 0; j<= 511; j = j+1)
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
	#p_dlt r_event = 8'h40;
	#p_spl r_event = 8'h00;    
	#p_dlt r_event = 8'h80;
		 //  r_label = 4'b0001;
	#p_spl r_event = 8'h00;
	//#p_spl r_label = 4'b0000;
	
	#p_delay;

	#(10*p_clk_lvl_1);
	#p_dlt r_event = 8'h01;
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
	#p_dlt r_event = 8'h40;
	#p_spl r_event = 8'h00;    
	#p_dlt r_event = 8'h80;
		   r_label = 4'b0001;
	#p_spl r_event = 8'h00;
	#p_spl r_label = 4'b0000;		
    
	#p_wait;

//for(j = 0; j<= 127; j = j+1)
//  begin
	/*  pattern \\  */
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
	#p_dlt r_event = 8'h01;
	    //   r_label = 4'b0010;
	#p_spl r_event = 8'h00;
	//#p_spl r_label = 4'b0000;
	
    #p_delay;
	
	#(10*p_clk_lvl_1);
	#p_dlt r_event = 8'h80;
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
	#p_dlt r_event = 8'h01;
	       r_label = 4'b0010;
	#p_spl r_event = 8'h00;
	#p_spl r_label = 4'b0000;
	
    #p_wait;

// for(j = 0; j<= 63; j = j+1)
//  begin
	/*  pattern /\  */
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
	#p_dlt r_event = 8'h40;
	#p_spl r_event = 8'h00;    
	#p_dlt r_event = 8'h80;
		//   r_label = 4'b0100;
	#p_spl r_event = 8'h00;
	//#p_spl r_label = 4'b0000;

    #p_delay;

	#(10*p_clk_lvl_1);
	#p_dlt r_event = 8'h80;
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
	#p_dlt r_event = 8'h01;
		   r_label = 4'b0100;
	#p_spl r_event = 8'h00;
	#p_spl r_label = 4'b0000;
    
	#p_wait;

// for(j = 0; j<= 127; j = j+1)
//  begin
	/*  pattern \\  */
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
	#p_dlt r_event = 8'h01;
	  //     r_label = 4'b1000;
	#p_spl r_event = 8'h00;
	  //#p_spl r_label = 4'b0000;

    #p_delay;

	#(10*p_clk_lvl_1);
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
	#p_dlt r_event = 8'h40;
	#p_spl r_event = 8'h00;    
	#p_dlt r_event = 8'h80;
		   r_label = 4'b1000;
	#p_spl r_event = 8'h00;
	#p_spl r_label = 4'b0000;
    #p_wait;
    #p_wait;
end  
end // end event stimuli

ODESA
#(.p_width(9)) uut
(
.i_clk_l1(r_clk_lvl_1),
.i_clk_l2(r_clk_lvl_2),
.i_rst_n(r_rst_n),
.i_event(r_event),
.i_label(r_label),
.o_endof_epochs(w_endof_epochs),
.o_spike_out(w_spikeout_l2)
);

endmodule