class fifo_env #(parameter WIDTH = 16);

  virtual fifo_if#(WIDTH) vif;

  mailbox #(fifo_transaction#(WIDTH))  gen2drv;
  mailbox #(fifo_mon_txn#(WIDTH))      mon2scb;
  event                                drv_done;

  fifo_generator#(WIDTH)  gen;
  fifo_driver#(WIDTH)     drv;
  fifo_monitor#(WIDTH)    mon;
  fifo_scoreboard#(WIDTH) scb;

  function new(virtual fifo_if#(WIDTH) vif, int num_transactions);
    this.vif = vif;

    gen2drv = new();
    mon2scb = new();

    gen = new(gen2drv, drv_done, num_transactions);
    drv = new(vif,gen2drv, drv_done);
    mon = new(vif, mon2scb);
    scb = new(mon2scb);

    
  endfunction

  task run();
    drv.reset_dut();

    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_any
  endtask

endclass : fifo_env