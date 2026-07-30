class fifo_mon_txn #(parameter WIDTH = 16);

  logic             reset;
  logic             w_enb, r_enb;
  logic [WIDTH-1:0] din;
  logic [WIDTH-1:0] dout;
  logic             full, empty;

endclass : fifo_mon_txn
