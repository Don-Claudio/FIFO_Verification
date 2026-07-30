class fifo_monitor #(parameter WIDTH = 16);

  virtual fifo_if#(WIDTH)               vif;
  mailbox #(fifo_mon_txn#(WIDTH))       mon2scb;

  function new(virtual fifo_if#(WIDTH)       vif,
               mailbox #(fifo_mon_txn#(WIDTH)) mbx);
    this.vif = vif;
    this.mon2scb = mbx;
  endfunction

  task run();
    fifo_mon_txn#(WIDTH) mon_txn;

    forever begin
        @(vif.cb);

        mon_txn = new();

        mon_txn.reset = vif.reset;
        mon_txn.w_enb = vif.cb.w_enb;
        mon_txn.r_enb = vif.cb.r_enb;
        mon_txn.din = vif.cb.din;
        mon_txn.dout = vif.cb.dout;
        mon_txn.full =  vif.cb.full;
        mon_txn.empty = vif.cb.empty;

        mon2scb.put(mon_txn);
    end
  endtask

endclass : fifo_monitor
