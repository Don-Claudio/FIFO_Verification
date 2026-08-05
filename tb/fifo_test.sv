class fifo_test #(parameter WIDTH = 16, parameter DEPTH = 8);

    int num_transactions;
    virtual fifo_if#(WIDTH) vif;
    fifo_env#(WIDTH,DEPTH) env;

    function new(virtual fifo_if#(WIDTH) vif, int num_transactions);
    this.vif = vif;
    this.num_transactions = num_transactions;

    endfunction

    task run();
        env = new(vif, num_transactions);
        env.run();

        repeat (10) @(vif.cb);

        $finish;

    endtask



endclass : fifo_test