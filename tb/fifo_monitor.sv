class fifo_monitor #(parameter WIDTH = 16, parameter DEPTH = 8);

  virtual fifo_if#(WIDTH)               vif;
  mailbox #(fifo_mon_txn#(WIDTH))       mon2scb;

  int occupancy    = 0;
  int total_writes = 0;
  int write_streak = 0;
  int read_streak  = 0;

  bit accepted_write, accepted_read;

  covergroup cg_activity;
    cp_w_enb : coverpoint vif.w_enb;
    cp_r_enb : coverpoint vif.r_enb;

    cp_din : coverpoint vif.din {
      bins zero     = {0};
      bins all_ones = {{WIDTH{1'b1}}};
      bins others   = default;
    }

    cp_occupancy : coverpoint occupancy {
      bins empty     = {0};
      bins one       = {1};
      bins mid       = {[2:DEPTH-2]};
      bins near_full = {DEPTH-1};
      bins full      = {DEPTH};
    }

    cx_ops : cross cp_w_enb, cp_r_enb;

    cx_write_at_extreme : cross cp_occupancy, cp_w_enb {
      option.auto_bin_max = 0;
      bins full_write  = binsof(cp_occupancy.full)  && binsof(cp_w_enb) intersect {1};
      bins one_write   = binsof(cp_occupancy.one)   && binsof(cp_w_enb) intersect {1};
    }

    cx_read_at_extreme : cross cp_occupancy, cp_r_enb {
      option.auto_bin_max = 0;
      bins empty_read     = binsof(cp_occupancy.empty)     && binsof(cp_r_enb) intersect {1};
      bins near_full_read = binsof(cp_occupancy.near_full) && binsof(cp_r_enb) intersect {1};
    }
  endgroup

  covergroup cg_flags;
    cp_full : coverpoint vif.cb.full {
      bins asserted   = (0 => 1);
      bins deasserted = (1 => 0);
    }
    cp_empty : coverpoint vif.cb.empty {
      bins asserted   = (0 => 1);
      bins deasserted = (1 => 0);
    }
  endgroup

  covergroup cg_wrap;
    cp_wrap : coverpoint (total_writes % DEPTH) {
      bins wrapped = {0};
    }
  endgroup

  covergroup cg_streaks;
    cp_write_streak : coverpoint write_streak {
      bins reaches_depth = {DEPTH};
    }
    cp_read_streak : coverpoint read_streak {
      bins reaches_depth = {DEPTH};
    }
  endgroup

  function new(virtual fifo_if#(WIDTH)       vif,
               mailbox #(fifo_mon_txn#(WIDTH)) mbx);
    this.vif = vif;
    this.mon2scb = mbx;
    cg_activity = new();
    cg_flags    = new();
    cg_wrap     = new();
    cg_streaks  = new();
  endfunction

  task run();
    fifo_mon_txn#(WIDTH) mon_txn;

    forever begin
        @(vif.cb);

        mon_txn = new();

        mon_txn.reset = vif.reset;
        mon_txn.w_enb = vif.w_enb;
        mon_txn.r_enb = vif.r_enb;
        mon_txn.din = vif.din;
        mon_txn.dout = vif.cb.dout;
        mon_txn.full =  vif.cb.full;
        mon_txn.empty = vif.cb.empty;

        mon2scb.put(mon_txn);

        accepted_write = mon_txn.w_enb && !mon_txn.full;
        accepted_read  = mon_txn.r_enb && !mon_txn.empty;

        if (mon_txn.reset) begin
          occupancy    = 0;
          total_writes = 0;
          write_streak = 0;
          read_streak  = 0;
        end else begin
          if (accepted_write && !accepted_read) occupancy++;
          else if (accepted_read && !accepted_write) occupancy--;

          if (accepted_write) total_writes++;

          write_streak = (accepted_write && !accepted_read) ? write_streak + 1 : 0;
          read_streak  = (accepted_read  && !accepted_write) ? read_streak  + 1 : 0;
        end

        cg_activity.sample();
        cg_flags.sample();
        if (accepted_write && total_writes > 0) cg_wrap.sample();
        cg_streaks.sample();

        mon2scb.put(mon_txn);
    end
  endtask

endclass : fifo_monitor
