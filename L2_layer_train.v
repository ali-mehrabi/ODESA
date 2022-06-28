
module L2_train
#(parameter p_width = 9)
(
 input                        i_clk,
 input                        i_rst_n,
 input  [2:1]                 i_event,
 input  [4:1]                 i_label,
 input  [4:1]                 i_l2_spikeout,
 input  [(2*p_width)-1:0]     i_ts,
 input  [4*(2*p_width+1)-1:0] i_lv,
 input                        i_endof_epochs,
 output                       o_las,
 output                       o_gas,
 output [4*(2*p_width)-1:0]   o_weights,
 output [4*(2*p_width+1)-1:0] o_thresholds
 );

parameter p_deltaT = 10'h1f;
parameter p_default_thr = 19'h0_1f_ff;
parameter p_default_w = 9'h03f;//{p_width{1'b1}};
parameter p_epochs = 5000;
parameter p_wait_clks = 10;
parameter p_pass_lvl_2 = 7;


wire                         w_input_event_on;
wire                         w_is_label;
wire                         w_is_winner;
reg                          r_stop_n;
reg  [1:0]                   r_state;
reg  [4:1]                   r_winner;
reg  [4:1]                   r_label;
reg                          r_is_winner;
reg                          r_is_label;
reg  [$clog2(p_wait_clks):0] r_counter;
reg  [p_width-1:0]           r_w1[4:1];
reg  [p_width-1:0]           r_w2[4:1];
reg  [p_width-1:0]           r_ts[2:1];
reg  [(2*p_width+1)-1:0]     r_threshold[4:1];

reg                          r_training_active;
genvar i;



assign w_input_event_on  = i_event[2] | i_event[1] ;
//assign w_count_reset_n = ~w_input_event_on & r_start;
assign w_is_winner = i_l2_spikeout[4] ^ i_l2_spikeout[3] ^ i_l2_spikeout[2] ^ i_l2_spikeout[1];
assign w_is_label = i_label[4] ^ i_label[3] ^ i_label[2] ^ i_label[1];
assign o_las = w_is_winner; //i_l2_spikeout[4] | i_l2_spikeout[3] | i_l2_spikeout[2] | i_l2_spikeout[1];
assign o_gas = w_is_label; //i_label[4] | i_label[3] | i_label[2] | i_label[1];
assign o_thresholds = {r_threshold[4],r_threshold[3],r_threshold[2],r_threshold[1]};
assign o_weights = {r_w2[4],r_w1[4],r_w2[3],r_w1[3],r_w2[2],r_w1[2],r_w2[1],r_w1[1]};
//assign w_pass_l1 = (r_counter >= p_pass_lvl_1)? 1:0;
assign w_pass_l2 = (r_counter >= p_pass_lvl_2)? 1:0;


always @(posedge w_is_winner or negedge i_rst_n)
   begin	
	 if(!i_rst_n)
		begin
		  r_ts[1] <= {p_width{1'b0}};
		  r_ts[2] <= {p_width{1'b0}};		
		end
	  else
		begin
		  r_ts[1] <= i_ts[p_width-1:0];
		  r_ts[2] <= i_ts[2*p_width-1:p_width];	
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
   else if(r_training_active && !i_endof_epochs)
     r_counter <= r_counter +1; 
end	

//latch winner
generate
for(i=1;i<=4;i=i+1) 
  begin
	always @(posedge i_l2_spikeout[i] or negedge r_stop_n) 
	begin
	  if(!r_stop_n)
		  r_winner[i] <= 1'b0;
	  else 
		  r_winner[i] <= 1'b1; 
	end 
  end
endgenerate 


always @(posedge w_is_label or negedge r_stop_n)
begin
  if(!r_stop_n)
    r_is_label <= 1'b0;
  else
    r_is_label <= 1'b1;
end

always @(posedge w_is_label or negedge r_stop_n)
begin
  if(!r_stop_n)
    r_label <= 4'b0;
  else
    r_label <= i_label;
end

always @(posedge w_is_winner or negedge r_stop_n)
begin
  if(!r_stop_n)
    r_is_winner <= 1'b0;
  else
    r_is_winner <= 1'b1;
end


//main state machine
always@(posedge i_clk or negedge i_rst_n)
begin 
  if(!i_rst_n)
    begin
	  r_w1[1] <= p_default_w;
	  r_w2[1] <= p_default_w;
	  r_w1[2] <= p_default_w;
	  r_w2[2] <= p_default_w;
	  r_w1[3] <= p_default_w;
	  r_w2[3] <= p_default_w;
	  r_w1[4] <= p_default_w;
	  r_w2[4] <= p_default_w;	  
	  r_threshold[1] <= p_default_thr;
	  r_threshold[2] <= p_default_thr; 
	  r_threshold[3] <= p_default_thr;
	  r_threshold[4] <= p_default_thr;	  
	  r_state <= 0;
	end  
  else
     case(r_state)
	  0:begin
	      if(w_pass_l2) 
		    r_state<= 1;
	    end	 
	  1:begin
	      if(r_is_winner & r_is_label)
		    begin
			  if(r_label == r_winner) 
			    begin
                  if(r_winner[1])
                    begin
				      r_threshold[1] <= r_threshold[1] - {3'b000,r_threshold[1][2*p_width:3]} + {3'b0, i_lv[1*(2*p_width+1)-1:3]}; 
				      r_w1[1] <= r_w1[1] - {3'b000,r_w1[1][p_width-1:3]} + {3'b000,r_ts[1][p_width-1:3]};
				      r_w2[1] <= r_w2[1] - {3'b000,r_w2[1][p_width-1:3]} + {3'b000,r_ts[2][p_width-1:3]};		               
                    end	
			      if(r_winner[2]) 
			        begin
			          r_threshold[2] <= r_threshold[2] - {3'b000,r_threshold[2][2*p_width:3]} + {3'b0, i_lv[2*(2*p_width+1)-1:(2*p_width+1)+3]}; 
			          r_w1[2] <= r_w1[2] -{3'b000,r_w1[2][p_width-1:3]} +{3'b000,r_ts[1][p_width-1:3]};
			          r_w2[2] <= r_w2[2] -{3'b000,r_w2[2][p_width-1:3]} +{3'b000,r_ts[2][p_width-1:3]};
			        end
                  if(r_winner[3])
			        begin
			          r_threshold[3] <= r_threshold[3] - {3'b000,r_threshold[3][2*p_width:3]} + {3'b0, i_lv[3*(2*p_width+1)-1:2*(2*p_width+1)+3]}; 
			          r_w1[3] <= r_w1[3] -{3'b000,r_w1[3][p_width-1:3]} +{3'b000,r_ts[1][p_width-1:3]};
			          r_w2[3] <= r_w2[3] -{3'b000,r_w2[3][p_width-1:3]} +{3'b000,r_ts[2][p_width-1:3]};
			        end
                  if(r_winner[4])				
		    	    begin
			          r_threshold[4] <= r_threshold[4] - {3'b000,r_threshold[4][2*p_width:3]} + {3'b0, i_lv[4*(2*p_width+1)-1:3*(2*p_width+1)+3]}; 
			          r_w1[4] <= r_w1[4] -{3'b000,r_w1[4][p_width-1:3]} +{3'b000,r_ts[1][p_width-1:3]};
			          r_w2[4] <= r_w2[4] -{3'b000,r_w2[4][p_width-1:3]} +{3'b000,r_ts[2][p_width-1:3]};
			        end						
				end
			  else
                begin
				  if(r_label[1]) r_threshold[1] <= r_threshold[1] - p_deltaT;
				  if(r_label[2]) r_threshold[2] <= r_threshold[2] - p_deltaT;
				  if(r_label[3]) r_threshold[3] <= r_threshold[3] - p_deltaT;
				  if(r_label[4]) r_threshold[4] <= r_threshold[4] - p_deltaT;	                 
                end							
			end
		  else if(!r_is_winner & r_is_label)
		     begin
			   if(r_label[1]) r_threshold[1] <= r_threshold[1] - p_deltaT;
			   if(r_label[2]) r_threshold[2] <= r_threshold[2] - p_deltaT;
               if(r_label[3]) r_threshold[3] <= r_threshold[3] - p_deltaT;
               if(r_label[4]) r_threshold[4] <= r_threshold[4] - p_deltaT;			   
			 end
	    //end
	  
	    // end
	      // if(r_is_label)
		    // begin           
              // if(r_winner[1] & r_label[1])
                // begin
				   // r_threshold[1] <= r_threshold[1] - {3'b000,r_threshold[1][2*p_width:3]} + {3'b0, i_lv[1*(2*p_width+1)-1:3]}; 
				   // r_w1[1] <= r_w1[1] - {3'b000,r_w1[1][p_width-1:3]} + {3'b000,r_ts[1][p_width-1:3]};
				   // r_w2[1] <= r_w2[1] - {3'b000,r_w2[1][p_width-1:3]} + {3'b000,r_ts[2][p_width-1:3]};		               
                // end	
              // else if(r_winner[1]^r_label[1]) r_threshold[1] <= r_threshold[1] - p_deltaT;
			  
			  // if(r_winner[2] & r_label[2]) 
			    // begin
			      // r_threshold[2] <= r_threshold[2] - {3'b000,r_threshold[2][2*p_width:3]} + {3'b0, i_lv[2*(2*p_width+1)-1:(2*p_width+1)+3]}; 
			      // r_w1[2] <= r_w1[2] -{3'b000,r_w1[2][p_width-1:3]} +{3'b000,r_ts[1][p_width-1:3]};
			      // r_w2[2] <= r_w2[2] -{3'b000,r_w2[2][p_width-1:3]} +{3'b000,r_ts[2][p_width-1:3]};
			    // end
			  // else if(r_winner[2]^r_label[2]) r_threshold[2] <= r_threshold[2] - p_deltaT;
			  
		      // if(r_winner[3] & r_label[3])
			    // begin
			      // r_threshold[3] <= r_threshold[3] - {3'b000,r_threshold[3][2*p_width:3]} + {3'b0, i_lv[3*(2*p_width+1)-1:2*(2*p_width+1)+3]}; 
			      // r_w1[3] <= r_w1[3] -{3'b000,r_w1[3][p_width-1:3]} +{3'b000,r_ts[1][p_width-1:3]};
			      // r_w2[3] <= r_w2[3] -{3'b000,r_w2[3][p_width-1:3]} +{3'b000,r_ts[2][p_width-1:3]};
			    // end
			  // else if(r_winner[3]^r_label[3]) r_threshold[3] <= r_threshold[3] - p_deltaT;
			  
              // if(r_winner[4] & r_label[4])				
		    	// begin
			      // r_threshold[4] <= r_threshold[4] - {3'b000,r_threshold[4][2*p_width:3]} + {3'b0, i_lv[4*(2*p_width+1)-1:3*(2*p_width+1)+3]}; 
			      // r_w1[4] <= r_w1[4] -{3'b000,r_w1[4][p_width-1:3]} +{3'b000,r_ts[1][p_width-1:3]};
			      // r_w2[4] <= r_w2[4] -{3'b000,r_w2[4][p_width-1:3]} +{3'b000,r_ts[2][p_width-1:3]};
			    // end	
              // else if(r_winner[4]^r_label[4]) r_threshold[4] <= r_threshold[4] - p_deltaT;			   
		    // end
		  r_state <= 2;			  
	    end
	  2:begin
	      if(!r_stop_n) 
		    r_state <= 0;
	    end
      endcase
end	


endmodule