/* 
if there is an event, wait until an spike appears at the level outputs
if there is no winner (spike) and GAS is active, punish all neurons of the level. else, reward the winner. 
wait more to see if LAS will asserted due to the winner spike, if LAS asserted, then reward all neurons with trace > 0.1 and punish neurons with trace <0.1. 
 */
module L1_train
#(parameter p_width = 9)
(
 input                         i_clk,
 input                         i_rst_n,
 input  [8:1]                  i_event,
 input  [2:1]                  i_l1_spikeout,
 input  [2*(8*p_width)-1:0]    i_ts,
 input  [2*p_width-1:0]        i_tr,
 input  [2*(2*p_width+3)-1:0]  i_lv,
 input                         i_las,
 input                         i_gas,
 output                        o_las,
 output [2*(8*p_width)-1:0]    o_weights,
 output [2*(2*p_width+3)-1:0]  o_thresholds,
 output                        o_endof_epochs
 );

parameter p_deltaT = 10'h3ff;
parameter p_default_thr = 21'h00_7f_ff;
parameter p_default_w = 9'h03f;//{p_width{1'b1}};
parameter p_trace_ll = 6;
parameter p_epochs = 20120;
parameter p_wait_clks = 10;
parameter p_pass_lvl_1 = 7;
parameter p_pass_lvl_2 = 9;
genvar    i;

wire                          w_input_event_on;
wire                          w_pass_l1;
wire                          w_pass_l2;
reg   [p_width-1:0]       	  r_w1[2:1];
reg   [p_width-1:0]       	  r_w2[2:1];
reg   [p_width-1:0]       	  r_w3[2:1];
reg   [p_width-1:0]       	  r_w4[2:1];
reg   [p_width-1:0]       	  r_w5[2:1];
reg   [p_width-1:0]       	  r_w6[2:1];
reg   [p_width-1:0]       	  r_w7[2:1];
reg   [p_width-1:0]       	  r_w8[2:1];
reg   [(2*p_width+3)-1:0] 	  r_threshold[2:1];
reg   [p_width-1:0]       	  r_ts[16:1];
reg   [p_width-1:0]       	  r_tr[2:1];
reg                       	  r_las;
reg                       	  r_gas;
reg                       	  r_training_active;
//reg   [1:0]               	  r_spike_out;
reg   [2:1]                	  r_winner;
reg   [2:0]                	  r_state;
reg                      	  r_stop_n;
reg   [$clog2(p_wait_clks):0] r_counter;
reg   [$clog2(p_epochs):0]    r_epochs;
reg                           r_endof_epochs;

assign w_input_event_on  = i_event[8] | i_event[7] | i_event[6] | i_event[5] | i_event[4] | i_event[3] | i_event[2] | i_event[1];
assign o_las = r_winner[2] | r_winner[1];
assign o_thresholds = {r_threshold[2], r_threshold[1]};
assign o_weights = {r_w8[2], r_w7[2], r_w6[2], r_w5[2], r_w4[2], r_w3[2], r_w2[2], r_w1[2], r_w8[1], r_w7[1], r_w6[1], r_w5[1], r_w4[1], r_w3[1], r_w2[1], r_w1[1]};
assign w_pass_l1 = (r_counter >= p_pass_lvl_1)? 1:0;
assign w_pass_l2 = (r_counter >= p_pass_lvl_2)? 1:0;
assign o_endof_epochs = r_endof_epochs;
///// latch time surface when there is a spike
generate
for(i=1;i<=2;i=i+1)
  begin: gen_ts_latch
    always @(posedge i_l1_spikeout[i] or negedge i_rst_n)
       begin	
         if(!i_rst_n)
		    begin
			  r_ts[8*(i-1)+1] <= {p_width{1'b0}};
			  r_ts[8*(i-1)+2] <= {p_width{1'b0}};
			  r_ts[8*(i-1)+3] <= {p_width{1'b0}};
			  r_ts[8*(i-1)+4] <= {p_width{1'b0}};
			  r_ts[8*(i-1)+5] <= {p_width{1'b0}};
			  r_ts[8*(i-1)+6] <= {p_width{1'b0}};
			  r_ts[8*(i-1)+7] <= {p_width{1'b0}};
			  r_ts[8*(i-1)+8] <= {p_width{1'b0}};		
			end
		  else
            begin
              r_ts[8*(i-1)+1] <= i_ts[p_width*8*(i-1)+p_width-1  :p_width*8*(i-1)];
		      r_ts[8*(i-1)+2] <= i_ts[p_width*8*(i-1)+2*p_width-1:p_width*8*(i-1)+1*p_width];
			  r_ts[8*(i-1)+3] <= i_ts[p_width*8*(i-1)+3*p_width-1:p_width*8*(i-1)+2*p_width];
			  r_ts[8*(i-1)+4] <= i_ts[p_width*8*(i-1)+4*p_width-1:p_width*8*(i-1)+3*p_width];
			  r_ts[8*(i-1)+5] <= i_ts[p_width*8*(i-1)+5*p_width-1:p_width*8*(i-1)+4*p_width];
			  r_ts[8*(i-1)+6] <= i_ts[p_width*8*(i-1)+6*p_width-1:p_width*8*(i-1)+5*p_width];
			  r_ts[8*(i-1)+7] <= i_ts[p_width*8*(i-1)+7*p_width-1:p_width*8*(i-1)+6*p_width];
			  r_ts[8*(i-1)+8] <= i_ts[p_width*8*(i-1)+8*p_width-1:p_width*8*(i-1)+7*p_width];	
            end
       end
  end
endgenerate	

//latch trace when next layer spikes
always @(posedge i_las or negedge i_rst_n)
begin	
  if(!i_rst_n)
	begin
	  r_tr[1] <= {p_width{1'b0}};
	  r_tr[2] <= {p_width{1'b0}};
	end
  else
	begin
	  r_tr[1] <= i_tr[p_width-1:0];
	  r_tr[2] <= i_tr[2*p_width-1:p_width];
	end
end

always @(posedge i_clk or negedge i_rst_n) 
begin
  if(!i_rst_n)
     r_stop_n <= 1'b0;
  else 
    if(r_counter >= p_wait_clks) 
      r_stop_n <= 1'b0;
    else
      r_stop_n <= 1'b1; 
end

always @(posedge w_input_event_on or negedge r_stop_n)
begin
  if(!r_stop_n)
    r_training_active <= 1'b0;
  else
    r_training_active <= 1'b1;
end

always @(posedge ~i_clk or negedge r_stop_n)
begin 
   if(!r_stop_n)
     r_counter <= 0;
   else if(r_training_active && !r_endof_epochs)
     r_counter <= r_counter +1; 
end	


//latch winner
generate
for(i=1;i<=2;i=i+1) 
  begin
	always @(posedge i_l1_spikeout[i] or negedge r_stop_n) 
	begin
	  if(!r_stop_n)
		  r_winner[i] <= 1'b0;
	  else 
		  r_winner[i] <= 1'b1; 
	end 
  end
endgenerate 

always @(posedge i_las or negedge r_stop_n)
begin
  if(!r_stop_n)
    r_las <= 1'b0;
  else
    r_las <= 1'b1;
end

always @(posedge w_input_event_on or negedge r_stop_n)
begin
  if(!r_stop_n)
    r_gas <= 1'b0;
  else if(i_gas)
    r_gas <= 1'b1;
end

//main state machine
always@(posedge i_clk or negedge i_rst_n)
begin 
  if(!i_rst_n)
    begin
	  r_w1[1] <= p_default_w;
	  r_w2[1] <= p_default_w;
	  r_w3[1] <= p_default_w;
	  r_w4[1] <= p_default_w;
	  r_w5[1] <= p_default_w;
	  r_w6[1] <= p_default_w;
	  r_w7[1] <= p_default_w;
	  r_w8[1] <= p_default_w;
	  r_w1[2] <= p_default_w;
	  r_w2[2] <= p_default_w;
	  r_w3[2] <= p_default_w;
	  r_w4[2] <= p_default_w;
	  r_w5[2] <= p_default_w;
	  r_w6[2] <= p_default_w;
	  r_w7[2] <= p_default_w;
	  r_w8[2] <= p_default_w;
	  r_threshold[1] <= p_default_thr;
	  r_threshold[2] <= p_default_thr; 
	  r_state <= 0;
	end  
  else
     case(r_state)
	  0:begin
	      if(w_pass_l1) //r_training_active && 
		    r_state<= 1;
	    end	 
	  1:begin
	      if(r_gas)
		    begin // award the winner
			  if(r_winner[1])
			    begin
				  r_w1[1] <= r_w1[1] - r_w1[1][p_width-1:3] + r_ts[1][p_width-1:3]; // eta = 1/8
				  r_w2[1] <= r_w2[1] - r_w2[1][p_width-1:3] + r_ts[2][p_width-1:3];
				  r_w3[1] <= r_w3[1] - r_w3[1][p_width-1:3] + r_ts[3][p_width-1:3];
				  r_w4[1] <= r_w4[1] - r_w4[1][p_width-1:3] + r_ts[4][p_width-1:3];
				  r_w5[1] <= r_w5[1] - r_w5[1][p_width-1:3] + r_ts[5][p_width-1:3];
				  r_w6[1] <= r_w6[1] - r_w6[1][p_width-1:3] + r_ts[6][p_width-1:3];
				  r_w7[1] <= r_w7[1] - r_w7[1][p_width-1:3] + r_ts[7][p_width-1:3];
				  r_w8[1] <= r_w8[1] - r_w8[1][p_width-1:3] + r_ts[8][p_width-1:3];  
				  r_threshold[1] <= r_threshold[1] - r_threshold[1][(2*p_width+3)-1:3] + i_lv[(2*p_width+3)-1:3];
				end
			  else if(r_winner[2])
			    begin
				  r_w1[2] <= r_w1[2] - r_w1[2][p_width-1:3] + r_ts[9][p_width-1:3];
				  r_w2[2] <= r_w2[2] - r_w2[2][p_width-1:3] + r_ts[10][p_width-1:3];
				  r_w3[2] <= r_w3[2] - r_w3[2][p_width-1:3] + r_ts[11][p_width-1:3];
				  r_w4[2] <= r_w4[2] - r_w4[2][p_width-1:3] + r_ts[12][p_width-1:3];
				  r_w5[2] <= r_w5[2] - r_w5[2][p_width-1:3] + r_ts[13][p_width-1:3];
				  r_w6[2] <= r_w6[2] - r_w6[2][p_width-1:3] + r_ts[14][p_width-1:3];
				  r_w7[2] <= r_w7[2] - r_w7[2][p_width-1:3] + r_ts[15][p_width-1:3];
				  r_w8[2] <= r_w8[2] - r_w8[2][p_width-1:3] + r_ts[16][p_width-1:3]; 
				  r_threshold[2] <= r_threshold[2] - r_threshold[2][(2*p_width+3)-1:3] + i_lv[2*(2*p_width+3)-1:(2*p_width+3)+3];				
				end
			 else
			   begin
			     r_threshold[1] <= r_threshold[1] - p_deltaT;
				 r_threshold[2] <= r_threshold[2] - p_deltaT;
			   end
			end	
		  r_state <= 2;			
	    end
	  2:begin
	      if(w_pass_l2)
		    r_state <= 3;
	    end
	  3:begin
	      // if(r_las) // if LAS =1
		    // begin
			  // if(r_tr[1] > p_trace_ll)
			    // begin
				  // r_w1[1] <= r_w1[1] - r_w1[1][p_width-1:3] + r_ts[1][p_width-1:3];
				  // r_w2[1] <= r_w2[1] - r_w2[1][p_width-1:3] + r_ts[2][p_width-1:3];
				  // r_w3[1] <= r_w3[1] - r_w3[1][p_width-1:3] + r_ts[3][p_width-1:3];
				  // r_w4[1] <= r_w4[1] - r_w4[1][p_width-1:3] + r_ts[4][p_width-1:3];
				  // r_w5[1] <= r_w5[1] - r_w5[1][p_width-1:3] + r_ts[5][p_width-1:3];
				  // r_w6[1] <= r_w6[1] - r_w6[1][p_width-1:3] + r_ts[6][p_width-1:3];
				  // r_w7[1] <= r_w7[1] - r_w7[1][p_width-1:3] + r_ts[7][p_width-1:3];
				  // r_w8[1] <= r_w8[1] - r_w8[1][p_width-1:3] + r_ts[8][p_width-1:3];  
                  // r_threshold[1] <= r_threshold[1] - r_threshold[1][(2*p_width+3)-1:3] + i_lv[(2*p_width+3)-1:3];			  
				// end
			  // else
			    // r_threshold[1] <= r_threshold[1] - p_deltaT;			
				
			  // if(r_tr[2] > p_trace_ll)
			    // begin
				  // r_w1[2] <= r_w1[2] - r_w1[2][p_width-1:3] + r_ts[9][p_width-1:3];
				  // r_w2[2] <= r_w2[2] - r_w2[2][p_width-1:3] + r_ts[10][p_width-1:3];
				  // r_w3[2] <= r_w3[2] - r_w3[2][p_width-1:3] + r_ts[11][p_width-1:3];
				  // r_w4[2] <= r_w4[2] - r_w4[2][p_width-1:3] + r_ts[12][p_width-1:3];
				  // r_w5[2] <= r_w5[2] - r_w5[2][p_width-1:3] + r_ts[13][p_width-1:3];
				  // r_w6[2] <= r_w6[2] - r_w6[2][p_width-1:3] + r_ts[14][p_width-1:3];
				  // r_w7[2] <= r_w7[2] - r_w7[2][p_width-1:3] + r_ts[15][p_width-1:3];
				  // r_w8[2] <= r_w8[2] - r_w8[2][p_width-1:3] + r_ts[16][p_width-1:3]; 
				  // r_threshold[2] <= r_threshold[2] - r_threshold[2][(2*p_width+3)-1:3] + i_lv[2*(2*p_width+3)-1:(2*p_width+3)+3];					
				// end 
			  // else
			    // r_threshold[2] <= r_threshold[2] - p_deltaT;					  
			// end
		  r_state<= 4;		
	    end				
	  4:begin
	      if(!r_stop_n) 
		    r_state <= 0;
	    end
      endcase
end	
  

always @(posedge ~r_stop_n or negedge i_rst_n)
begin
  if(!i_rst_n)
    begin
	  r_epochs <= 1;
	  r_endof_epochs <= 0;	
	end
  else
    begin
      if(r_epochs < p_epochs) 
       r_epochs <= r_epochs +1;
	  else
       r_endof_epochs <=1;	  
	end
end


endmodule