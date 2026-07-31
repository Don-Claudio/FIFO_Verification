module fifo_tb_top;

  import fifo_pkg::*;

  localparam WIDTH = 16;

  logic clk;

  initial begin 
    clk = 0;
    forever #5 clk = ~clk;
  end

  fifo_if #(WIDTH) vif_inst (.clk(clk));

  sync_fifo #(.Depth(8), .Width(WIDTH)) dut (
    .clk   (clk),
    .reset (vif_inst.reset),
    .w_enb (vif_inst.w_enb),
    .r_enb (vif_inst.r_enb),
    .din   (vif_inst.din),
    .dout  (vif_inst.dout),
    .full  (vif_inst.full),
    .empty (vif_inst.empty)
  );

  fifo_test#(WIDTH) test;

  initial begin
    test = new(vif_inst, 200);

    test.run();
  end

endmodule : fifo_tb_top