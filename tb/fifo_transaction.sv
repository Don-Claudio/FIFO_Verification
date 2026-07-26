class fifo_transaction #(parameter WIDTH = 16);
  rand logic             w_enb, r_enb;
  rand logic [WIDTH-1:0] din;

  constraint w_and_read {
    w_enb dist {0:=40, 1:=60};
    r_enb dist {0:=40, 1:=60};
  }

  constraint d_in{
    din dist {{WIDTH{1'b0}}:=40, [{WIDTH{1'b0}}+1:{WIDTH{1'b1}}-1]:/ 20, {WIDTH{1'b1}}:=40};
  }

endclass : fifo_transaction