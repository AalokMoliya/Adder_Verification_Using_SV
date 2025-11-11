class random;
  rand logic[3:0]ip1;
  rand logic[3:0]ip2;
  logic [3:0] iop1,iop2;
  logic [4:0]op;
endclass


class generator ;
  random rm;
  mailbox mx;
  
  function new(mailbox mx);
    this.mx = mx;
  endfunction

  task gen();
  	repeat (10) begin
    rm = new();
    rm.randomize();
    mx.put(rm);
  end
  endtask

endclass
    
class driver;
  mailbox mx;
  virtual add_if inter;
  random rm;
  
  function new(mailbox mx,virtual add_if inter);
  	this.mx=mx;
    this.inter=inter;
  endfunction
  
  task drive();
   forever begin
      mx.get(rm);
      @(posedge inter.clk);
      inter.ip1 = rm.ip1;
      inter.ip2 = rm.ip2;
   end
  endtask
  
endclass
    
class monitor;
  mailbox mx;
  random rm;
  virtual add_if inter;
  
  function new(mailbox mx,virtual add_if inter);
    this.mx=mx;
    this.inter=inter;
  endfunction
  
  task mon();
    forever begin
      @(posedge inter.clk)
      rm=new();
      rm.iop1 = inter.iop1;
      rm.iop2 = inter.iop2;
      rm.op=inter.op;
      mx.put(rm);
    end
  endtask;
	
endclass
    

class scoreboard;
  mailbox mx;
  random rm;
  covergroup cg;
    coverpoint rm.iop1 {
      bins low  = {[0:3]};
      bins mid  = {[4:11]};
      bins high = {[12:15]};
    }

    coverpoint rm.iop2 {
      bins low  = {[0:3]};
      bins mid  = {[4:11]};
      bins high = {[12:15]};
    }

    // Cover sum output
    coverpoint rm.op {
      bins small_sum = {[0:8]};
      bins med_sum   = {[9:20]};
      bins big_sum   = {[21:30]};
    }
  endgroup
  
  
  function new(mailbox mx);
    this.mx=mx;
    cg=new();
  endfunction
  
  task score();
    forever begin
      mx.get(rm);
      if(rm.op==rm.iop1+rm.iop2)
        $display("correct in1=%d, in2=%d, op=%d",rm.iop1,rm.iop2,rm.op);
      else
        $display("incorrect in1=%d, in2=%d, op=%d",rm.iop1,rm.iop2,rm.op);
    end
    cg.sample();
  endtask
  
endclass
    
    
    
    
program pg(add_if inter);
  random rm;
  driver dv;
  generator gn;
  monitor mn;
  mailbox gntodv,mntosb;
  scoreboard sb;
  
  
  initial begin
    gntodv = new();
	mntosb = new();
    rm=new();
    gn=new(gntodv);
    dv=new(gntodv,inter);
    mn=new(mntosb,inter);
    sb=new(mntosb);
  end
  
  initial begin
    fork
    gn.gen();
    dv.drive();
    mn.mon();
    sb.score();
  join_none

  #200
                    $finish;
  end
endprogram
