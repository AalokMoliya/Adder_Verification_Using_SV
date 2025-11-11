
module adder(input logic [3:0] ip1,ip2,input logic clk,output logic [4:0] op,
             output logic [4:0] iop1,iop2); 
  always @(posedge clk)begin
  	op<=ip1+ip2;
    iop1<=ip1;
    iop2<=ip2;
  end
endmodule 


interface add_if();
  logic clk;
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  logic [3:0] ip1,ip2,iop1,iop2;
  
  logic [4:0] op;
endinterface


module top();
  add_if inter();
  adder dut(.ip1(inter.ip1),.ip2(inter.ip2),.clk(inter.clk),.op(inter.op),.iop1(inter.iop1),.iop2(inter.iop2));
  pg p(inter);
endmodule
