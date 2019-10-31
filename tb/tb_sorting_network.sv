`timescale 1 ps / 1 ps
module tb_sorting_network;

parameter NUMBER_WIDTH   = 10;
parameter NUMBERS_AMOUNT = 10;
parameter CLK_T          = 10000;

bit                                                clk;
bit                                                rst;
bit [NUMBERS_AMOUNT - 1 : 0][NUMBER_WIDTH - 1 : 0] data_i;
bit                                                data_valid_i;
bit [NUMBERS_AMOUNT - 1 : 0][NUMBER_WIDTH - 1 : 0] data_o;
bit                                                data_valid_o;

task automatic clk_gen ();

  forever
    begin
      #( CLK_T / 2 );
      clk = !clk;
    end

endtask

task automatic apply_rst();

  @( posedge clk );
  rst <= 1'b1;
  @( posedge clk );
  rst <= 1'b0;

endtask

sorting_network #(
  .NUMBER_WIDTH   ( NUMBER_WIDTH   ),
  .NUMBERS_AMOUNT ( NUMBERS_AMOUNT )
) DUT (
  .clk_i          ( clk            ),
  .rst_i          ( rst            ),
  .data_i         ( data_i         ),
  .data_valid_i   ( data_valid_i   ),
  .data_o         ( data_o         ),
  .data_valid_o   ( data_valid_o   )
);

initial
  begin
    fork
      clk_gen();
      apply_rst();
    join_none
    for( int i = 0; i < NUMBERS_AMOUNT; i++ )
      data_i[i] = $urandom_range( 2 ** NUMBER_WIDTH - 1 );
    repeat( 100 )
      @( posedge clk );
    $stop();
  end

endmodule
