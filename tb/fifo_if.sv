`timescale 1ns / 1ps

interface fifo_if #(parameter WIDTH = 16) (input logic clk);

  logic             reset;
  logic             w_enb, r_enb;
  logic [WIDTH-1:0] din;
  logic [WIDTH-1:0] dout;
  logic             full, empty;

  clocking cb @(posedge clk);
    output w_enb, r_enb;
    output din;
    input dout;
    input full, empty;
  endclocking : cb

  modport TB (clocking cb);

endinterface : fifo_if