class fifo_generator #(parameter WIDTH = 16);

  mailbox #(fifo_transaction#(WIDTH)) gen2drv;  
  event drv_done;
  int   num_transactions;

  function new(mailbox #(fifo_transaction#(WIDTH)) mbx,
               event done,
               int count);
    this.gen2drv = mbx;
    this.drv_done = done;
    this.num_transactions = count;

  endfunction

  task run();
    fifo_transaction#(WIDTH) tr;

    repeat (num_transactions) begin
      tr = new();

    assert(tr.randomize()) else $fatal ("%s:%0d Randomization failed", `__FILE__, `__LINE__);

    gen2drv.put(tr);

    @drv_done; 

    end
  endtask

endclass : fifo_generator