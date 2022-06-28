
module auto_trainer(
input         i_clk,
input         i_rst_n,
output        o_end_of_epochs,
output [8:1]  o_test_vector,
output [4:1]  o_label
);

parameter  p_init_delay = 100;
parameter  p_spike_delay = 5;
parameter  p_event_delay = 60;
parameter  p_pattern_delay = 300;
parameter  p_epochs_delay = 500;
parameter  p_spike_num = 8;
parameter  p_event_num = 2;
parameter  p_epochs = 150;
parameter  p_pattern_num =4;

reg   [2:0]   r_state; 
reg   [5:0]   r_address; 
reg   [12:1]  r_data;
reg           r_end_of_epochs;
reg   [$clog2(p_spike_delay):0]   r_spike_counter;
reg   [$clog2(p_epochs_delay):0]  r_counter ;
reg   [$clog2(p_epochs):0]        r_epochs;
reg   [$clog2(p_spike_num)-1:0]   r_spike_num;
reg   [$clog2(p_event_num):0]     r_event_num;
reg   [$clog2(p_pattern_num):0]   r_pattern_num;

wire  [12:1]  r_ram[63:0];


assign o_test_vector = r_data[8:1];
assign o_label = r_data[12:9];
assign o_end_of_epochs = r_end_of_epochs;

always @(posedge ~i_clk or negedge i_rst_n) 
begin 
if(!i_rst_n) 
  begin
    r_state <= 0; 
	r_data  <= 0; 
	r_counter <= 0;
	r_address <= 0;
	r_event_num <= 1;
	r_epochs <= 1;
	r_pattern_num <= 1;
	r_spike_counter <= 0;
	r_spike_num <= 0;
	r_end_of_epochs <= 0;
  end
else 
   case(r_state) 
    0:begin 
	    if(r_counter < p_init_delay) 
		   r_counter <= r_counter+1;
		else 
		  begin
		    r_counter <= 0;
			r_state <= 1;
		  end
	  end
	1:begin
		r_data <= r_ram[r_address];
	    r_state <= 2;
	  end
	2:begin	
        r_data <= 0;    
        if(r_counter < p_spike_delay)
		  r_counter <= r_counter+1;
		else
		  begin
		    r_counter <= 0; 
			r_state <= 3;
		  end
	  end	  
	3:begin
		if(r_spike_num < p_spike_num-1)
	      begin
	        r_address <= r_address+1;
			r_spike_num <= r_spike_num +1;
	        r_state <= 1;
		  end
	    else 
		  begin
		    r_state <= 4;
		    r_spike_num <= 0;
		  end
	  end
	4:begin
	    if(r_counter < p_event_delay)
		  r_counter <= r_counter +1;
		else
          begin
            r_counter <= 0;		  
		    if(r_event_num < p_event_num)
		      begin
			    r_event_num <= r_event_num+1; 
				r_address <= r_address+1;
			    r_state <= 1;
			  end
		    else
		      begin
			    r_state <= 5;
			    r_event_num <= 1;
			  end
		 end
	  end
	5:begin
	    if(r_counter < p_pattern_delay)
	       r_counter <= r_counter + 1;
		else 
		begin 
		  r_counter <= 0;
		  if(r_pattern_num < p_pattern_num)
            begin		
		      r_pattern_num <= r_pattern_num +1;
		      r_address <= r_address+1;
			  r_state <= 1;
			end
		  else 
            begin   
	          r_state <= 6;
			  r_pattern_num <= 1;
		    end	
		  end
	    end
	6:begin
	    if(r_counter < p_epochs_delay)
	       r_counter <= r_counter + 1;
		else 
		  begin 
		    r_counter <= 0;	
	       if(r_epochs < p_epochs)
	         begin 
	           r_epochs <= r_epochs+1;
	           r_address <= 0;
	           r_state <= 1;
	         end
           else
	         begin
		       r_epochs <= 0;
               r_state<= 7;	
	         end
		  end	
	  end	
	7:begin
	    r_end_of_epochs <=1;
	  end		  
   endcase
end

assign r_ram[0]  = 12'h0_0_1;
assign r_ram[1]  = 12'h0_0_2;
assign r_ram[2]  = 12'h0_0_4;
assign r_ram[3]  = 12'h0_0_8;
assign r_ram[4]  = 12'h0_1_0;
assign r_ram[5]  = 12'h0_2_0;
assign r_ram[6]  = 12'h0_4_0;
assign r_ram[7]  = 12'h0_8_0;
assign r_ram[8]  = 12'h0_0_1;
assign r_ram[9]  = 12'h0_0_2;
assign r_ram[10] = 12'h0_0_4;
assign r_ram[11] = 12'h0_0_8;
assign r_ram[12] = 12'h0_1_0;
assign r_ram[13] = 12'h0_2_0;
assign r_ram[14] = 12'h0_4_0;
assign r_ram[15] = 12'h1_8_0;

assign r_ram[16] = 12'h0_8_0;
assign r_ram[17] = 12'h0_4_0;
assign r_ram[18] = 12'h0_2_0;
assign r_ram[19] = 12'h0_1_0;
assign r_ram[20] = 12'h0_0_8;
assign r_ram[21] = 12'h0_0_4;
assign r_ram[22] = 12'h0_0_2;
assign r_ram[23] = 12'h0_0_1;
assign r_ram[24] = 12'h0_8_0;
assign r_ram[25] = 12'h0_4_0;
assign r_ram[26] = 12'h0_2_0;
assign r_ram[27] = 12'h0_1_0;
assign r_ram[28] = 12'h0_0_8;
assign r_ram[29] = 12'h0_0_4;
assign r_ram[30] = 12'h0_0_2;
assign r_ram[31] = 12'h2_0_1;

assign r_ram[32] = 12'h0_0_1;
assign r_ram[33] = 12'h0_0_2;
assign r_ram[34] = 12'h0_0_4;
assign r_ram[35] = 12'h0_0_8;
assign r_ram[36] = 12'h0_1_0;
assign r_ram[37] = 12'h0_2_0;
assign r_ram[38] = 12'h0_4_0;
assign r_ram[39] = 12'h0_8_0;
assign r_ram[40] = 12'h0_8_0;
assign r_ram[41] = 12'h0_4_0;
assign r_ram[42] = 12'h0_2_0;
assign r_ram[43] = 12'h0_1_0;
assign r_ram[44] = 12'h0_0_8;
assign r_ram[45] = 12'h0_0_4;
assign r_ram[46] = 12'h0_0_2;
assign r_ram[47] = 12'h4_0_1;

assign r_ram[48] = 12'h0_8_0;
assign r_ram[49] = 12'h0_4_0;
assign r_ram[50] = 12'h0_2_0;
assign r_ram[51] = 12'h0_1_0;
assign r_ram[52] = 12'h0_0_8;
assign r_ram[53] = 12'h0_0_4;
assign r_ram[54] = 12'h0_0_2;
assign r_ram[55] = 12'h0_0_1;
assign r_ram[56] = 12'h0_0_1;
assign r_ram[57] = 12'h0_0_2;
assign r_ram[58] = 12'h0_0_4;
assign r_ram[59] = 12'h0_0_8;
assign r_ram[60] = 12'h0_1_0;
assign r_ram[61] = 12'h0_2_0;
assign r_ram[62] = 12'h0_4_0;
assign r_ram[63] = 12'h8_8_0;



endmodule