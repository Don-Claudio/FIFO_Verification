class fifo_driver #(parameter WIDTH = 16);

  virtual fifo_if#(WIDTH)              vif;
  mailbox #(fifo_transaction#(WIDTH))  gen2drv;
  event                                drv_done;

  function new(virtual fifo_if#(WIDTH)             vif,
               mailbox #(fifo_transaction#(WIDTH))  mbx,
               event                                done);
    this.vif = vif;
    this.gen2drv = mbx;
    this.drv_done = done;

  endfunction

  task reset_dut();
    vif.reset = 1;
    repeat (2) @(vif.cb);
    vif.reset = 0;
    @(vif.cb);  
    
  endtask

  task run();
    fifo_transaction#(WIDTH) tr;

    forever begin
    gen2drv.get(tr);
    
    vif.cb.w_enb <= tr.w_enb;
    vif.cb.r_enb <= tr.r_enb;
    vif.cb.din <= tr.din;

    @(vif.cb);
    -> drv_done;

    end
  endtask

endclass : fifo_driver