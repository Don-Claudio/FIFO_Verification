class fifo_scoreboard #(parameter WIDTH = 16);

  mailbox #(fifo_mon_txn#(WIDTH)) mon2scb;
  logic [WIDTH-1:0]               expected_q[$];

  function new(mailbox #(fifo_mon_txn#(WIDTH)) mbx);
    this.mon2scb = mbx;
  endfunction

  task run();
    fifo_mon_txn#(WIDTH) mon_txn;
    logic [WIDTH-1:0]    expected_data;

    forever begin
      mon2scb.get(mon_txn);

      if (mon_txn.reset) begin
        expected_q.delete();
      end 
      else begin
        if (mon_txn.w_enb && !mon_txn.full) begin
            expected_q.push_back(mon_txn.din);
        end
        if (mon_txn.r_enb && !mon_txn.empty) begin
            expected_data = expected_q.pop_front();
            assert (expected_data === mon_txn.dout) else
            $error ("Mismatch: expected %0h, got %0h", expected_data, mon_txn.dout);
        end
      end
    end
  endtask

endclass : fifo_scoreboard