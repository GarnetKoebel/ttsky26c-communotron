`timescale 1ns / 100ps

// generic mod N counter yoinked from ChipVerify with some modifications
module mod_n_counter
  # (parameter N = 9,
     parameter WIDTH = 4)

  ( input                 clk,
    input                 rstn,
    output out);

   reg [WIDTH-1:0] count;

   assign out = (count == (N-1)) ? 1 : 0;


  always @ (posedge clk) begin
    if (!rstn) begin
      count <= 0;
    end else begin
      if (count == N-1)
        count <= 0;
      else
        count <= count + 1;
    end
  end
endmodule
