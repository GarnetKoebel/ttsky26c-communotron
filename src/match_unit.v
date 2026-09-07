// address matching, spi chip select signal, and match 1 shot
module match_unit (
                   input       clk, rst, sda, scl, inhibit,
                   input [6:0] address_1, address_2, address_3, address_4,
                   output      match_1, match_2, match_3, match_4, match_shot
                   );

   // Address Detector Inhibit Logic. These signals are used to disable all but one address detector once
   // a match has occured
   wire inhibit_1, inhibit_2, inhibit_3, inhibit_4;
   assign inhibit_1 = (match_2 | match_3 | match_4 | inhibit);
   assign inhibit_2 = (match_1 | match_3 | match_4 | inhibit);
   assign inhibit_3 = (match_1 | match_2 | match_4 | inhibit);
   assign inhibit_4 = (match_1 | match_2 | match_3 | inhibit);

   // Address detectors. Pre-programmed to detect a specific address defined in the top level module
   // The detectors generate our spi chipselect signal
   i2c_address_detector address_1_detector(.clk(clk), .rst(rst), .sda(sda), .scl(scl), .inhibit(inhibit_1), .address(address_1) , .address_match(match_1));
   i2c_address_detector address_2_detector(.clk(clk), .rst(rst), .sda(sda), .scl(scl), .inhibit(inhibit_2), .address(address_2) , .address_match(match_2));
   i2c_address_detector address_3_detector(.clk(clk), .rst(rst), .sda(sda), .scl(scl), .inhibit(inhibit_3), .address(address_3) , .address_match(match_3));
   i2c_address_detector address_4_detector(.clk(clk), .rst(rst), .sda(sda), .scl(scl), .inhibit(inhibit_4), .address(address_4) , .address_match(match_4));

   // if any matches occur put that signal on the match wire
   wire match;
   assign match = (match_1 || match_2 || match_3 || match_4);


   // generate one shot signal on any match
   reg match_d;

   always @(posedge clk) begin
      if (!rst) begin
         match_d <= 1'b0;
      end else begin
         match_d <= match;
      end
   end

   assign match_shot = match & ~match_d;


endmodule // match_unit
