module ff ( input data, input c, input r, output q);
reg q;
always @(posedge c or negedge r) 
begin
 if(r==1'b0)
  q <= 1'b0; 
 else 
  q <= data; 
end 
endmodule

module statem(clk, reset, a, saida);

input clk, reset, a;
output [2:0] saida;
reg [2:0] state;
parameter zero=3'd0, tres=3'd1, dois=3'd2, quatro=3'd3, cinco =3'd4;

assign saida = (state == zero)? 3'd2:
           (state == dois)? 3'd5:
	   (state == tres)? 3'd6:
	   (state == quatro)? 3'd4:3'd3;

always @(posedge clk or negedge reset)
     begin
          if (reset==0)
               state = zero;
          else
               case (state)
                    zero: state = tres;
                    tres: if ( a == 1 ) state = cinco;
			  else state = dois;
                    quatro: if ( a == 1 ) state = tres;
			  else state = zero;
                    dois: state = quatro;
                    cinco: state = dois;
               endcase
     end
endmodule

module statePorta(input clk, input res, input a, output [2:0] s);
wire [2:0] e;
wire [2:0] p;
assign s = e;
assign p[0]  =  ~e[1]&~e[2] | a&(e[0]^e[2]);
assign p[1]  =  ~a&e[0] | a&e[2] | ~e[1]&~e[2];
assign p[2] =   e[1]&~e[0]   | a&e[1];
ff  e0(p[0],clk,res,e[0]);
ff  e1(p[1],clk,res,e[1]);
ff  e2(p[2],clk,res,e[2]);

endmodule 




module stateMem(input clk,input res, input a, output [2:0] saida);
reg [5:0] StateMachine [0:15];
initial
begin 
StateMachine[0] = 6'd24;  StateMachine[1] = 6'd24;
StateMachine[4] = 6'h22;  StateMachine[5] = 6'h22;
StateMachine[6] = 6'h13;  StateMachine[7] = 6'h2b;
StateMachine[8] = 6'h4;  StateMachine[9] = 6'h1c;
StateMachine[10] = 6'h15;  StateMachine[11] = 6'h15;
end
wire [3:0] address;
wire [5:0] dout;
assign address[0] = a;
assign dout = StateMachine[address];
assign saida = dout[2:0];
ff st0(dout[3],clk,res,address[1]);
ff st1(dout[4],clk,res,address[2]);
ff st2(dout[5],clk,res,address[3]);
endmodule

module main;
reg c,res,a;
wire [2:0] saida;
wire [2:0] saida1;

statem FSM(c,res,a,saida);
statePorta FSM1(c,res,a,saida1);


initial
    c = 1'b0;
  always
    c= #(1) ~c;


initial  begin
     $dumpfile ("out.vcd"); 
     $dumpvars; 
   end 

  initial 
    begin
     $monitor($time," c %b res %b a %b s %d smem %d",c,res,a,saida,saida1);
      #1 res=0; a=0;
      #1 res=1;
      #8 a=1;
      #16 a=0;
      #12 a=1;
      #4;
      $finish ;
    end
endmodule