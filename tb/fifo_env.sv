class fifo_env #(parameter WIDTH = 16, parameter DEPTH = 8);

  virtual fifo_if#(WIDTH) vif;

  mailbox #(fifo_transaction#(WIDTH))  gen2drv;
  mailbox #(fifo_mon_txn#(WIDTH))      mon2scb;
  event                                drv_done;

  fifo_generator#(WIDTH)  gen;
  fifo_driver#(WIDTH)     drv;
  fifo_monitor#(WIDTH, DEPTH)    mon;
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

    drv.run_write_streak_test();   // sequential — drv is not yet in the forever loop
    drv.run_read_streak_test();
    drv.run_mid_cycle_reset_test();
    drv.run_mid_transfer_reset_test();

    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_any
  endtask

endclass : fifo_env