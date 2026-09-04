module tb;
  reg 			clk, in, rstn;
  wire 			out;
  reg [1:0] l_dly;
  reg 			tb_in;
  integer 	loop = 1;

  always #10 clk = ~clk;

  det_1011 u0 ( .clk(clk), .rstn(rstn), .in(in), .out(out) );

  initial begin
  	clk <= 0;
    rstn <= 0;
    in <= 0;

    repeat (5) @ (posedge clk);
    rstn <= 1;

		// Generate a directed pattern
    @(posedge clk) in <= 1;
    @(posedge clk) in <= 0;
    @(posedge clk) in <= 1;
    @(posedge clk) in <= 1; 		// Pattern is completed
    @(posedge clk) in <= 0;
    @(posedge clk) in <= 0;
    @(posedge clk) in <= 1;
    @(posedge clk) in <= 1;
    @(posedge clk) in <= 0;
    @(posedge clk) in <= 1;
    @(posedge clk) in <= 1; 	 // Pattern completed again

    // Or random stimulus using a for loop that drives a random
    // value of input N times
    for (int i = 0 ; i < loop; i ++) begin
      l_dly = $random;
      repeat (l_dly) @ (posedge clk);
      tb_in = $random;
      in <= tb_in;
    end

    // Wait for sometime before quitting simulation
    #100 $finish;
  end
endmodule
