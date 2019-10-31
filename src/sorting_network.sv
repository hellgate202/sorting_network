module sorting_network #(
  parameter int NUMBER_WIDTH   = 10,
  parameter int NUMBERS_AMOUNT = 10
)(
  input                                                 clk_i,
  input                                                 rst_i,
  input  [NUMBERS_AMOUNT - 1 : 0][NUMBER_WIDTH - 1 : 0] data_i,
  input                                                 data_valid_i,
  output [NUMBERS_AMOUNT - 1 : 0][NUMBER_WIDTH - 1 : 0] data_o,
  output                                                data_valid_o
);

localparam int LAYERS_AMOUNT = NUMBERS_AMOUNT;

function logic [1 : 0][NUMBER_WIDTH - 1 : 0] comp_and_swap
(
  input logic [1 : 0][NUMBER_WIDTH - 1 : 0] unsorted_data
);

  logic [1 : 0][NUMBER_WIDTH - 1 : 0] sorted_data;

  if( unsorted_data[0] > unsorted_data[1] )
    begin
      sorted_data[0] = unsorted_data[1];
      sorted_data[1] = unsorted_data[0];
    end
  else
    begin
      sorted_data[0] = unsorted_data[0];
      sorted_data[1] = unsorted_data[1];
    end

  return sorted_data;

endfunction

logic [LAYERS_AMOUNT - 1 : 0][NUMBERS_AMOUNT - 1 : 0][NUMBER_WIDTH - 1 : 0] network;
logic [LAYERS_AMOUNT - 1 : 0]                                               data_valid_d;

assign network[0] = data_i;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    network[LAYERS_AMOUNT - 1 : 1] <= '0;
  else
    for( int layer = 1; layer < LAYERS_AMOUNT; layer++ )
      if( layer % 2 )
        if( NUMBERS_AMOUNT % 2 )
          begin
            for( int pair = 0; pair < NUMBERS_AMOUNT - 1; pair += 2 )
              network[layer][pair + 1 : pair] <= comp_and_swap( network[layer - 1][pair + 1 : pair] );
            network[layer][NUMBERS_AMOUNT - 1] <= network[layer - 1][NUMBERS_AMOUNT - 1];
          end
        else
          for( int pair = 0; pair < NUMBERS_AMOUNT; pair += 2 )
            network[layer][pair + 1 : pair] <= comp_and_swap( network[layer - 1][pair + 1 : pair] );
      else
        if( NUMBERS_AMOUNT % 2 )
          begin
            network[layer][0] <= network[layer - 1][0];
            for( int pair = 0; pair < NUMBERS_AMOUNT; pair += 2 ) 
              network[layer][pair + 1 : pair] <= comp_and_swap( network[layer - 1][pair + 1 : pair] );
          end
        else
          begin
            network[layer][0]                  <= network[layer - 1][0];
            for( int pair = 0; pair < NUMBERS_AMOUNT - 1; pair += 2 ) 
              network[layer][pair + 1 : pair] <= comp_and_swap( network[layer - 1][pair + 1 : pair] );
            network[layer][NUMBERS_AMOUNT - 1] <= network[layer - 1][NUMBERS_AMOUNT - 1];
          end

assign data_valid_d[0] = data_valid_i;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    data_valid_d[LAYERS_AMOUNT - 1 : 1] <= '0;
  else
    for( int i = 1; i < LAYERS_AMOUNT; i++ )
      data_valid_d[i] <= data_valid_d[i - 1];
 
assign data_o       = network[LAYERS_AMOUNT - 1];
assign data_valid_o = data_valid_d[LAYERS_AMOUNT - 1];

endmodule
