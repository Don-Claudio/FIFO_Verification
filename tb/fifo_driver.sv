class fifo_driver #(parameter WIDTH = 16, parameter DEPTH = 8);

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

  task run_write_streak_test();
    fifo_transaction#(WIDTH) tr;

    repeat (DEPTH) begin
      tr = new();
      tr.w_enb = 1;
      tr.r_enb = 0;
      tr.din = 16'h3900;

      vif.cb.w_enb <= tr.w_enb;
      vif.cb.r_enb <= tr.r_enb;
      vif.cb.din   <= tr.din;
      @(vif.cb);
    end

    vif.cb.w_enb <= 0;
    vif.cb.r_enb <= 0;
    
    @(vif.cb);
  endtask

  task run_read_streak_test();
    fifo_transaction#(WIDTH) tr;

    repeat (DEPTH) begin
      tr = new();
      tr.w_enb = 0;
      tr.r_enb = 1;

      vif.cb.w_enb <= tr.w_enb;
      vif.cb.r_enb <= tr.r_enb;
      @(vif.cb);
    end

    vif.cb.w_enb <= 0;
    vif.cb.r_enb <= 0;

    @(vif.cb);

  endtask

  task run_mid_cycle_reset_test();
    @(vif.cb);
    
    #3 vif.reset = 1;
    #4 vif.reset = 0;
    @(vif.cb);
    
  endtask

  task run_mid_transfer_reset_test();
    fifo_transaction#(WIDTH) tr;

    repeat (DEPTH-2) begin
      tr = new();
      tr.w_enb = 1;
      tr.r_enb = 0;
      tr.din = 16'h3900;

      vif.cb.w_enb <= tr.w_enb;
      vif.cb.r_enb <= tr.r_enb;
      vif.cb.din   <= tr.din;

      @(vif.cb);
    end 

    reset_dut();

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