`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.06.2026 02:11:16
// Design Name: 
// Module Name: systolic_row
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module systolicRow #(
    parameter NUM_PE = 4,
    parameter ACT_WIDTH = 8,
    parameter PSUM_WIDTH = 32

) (
    input logic clock, reset,
    input logic [ACT_WIDTH-1:0] act_in,
    input logic flush_in, lock_in,
    input logic signed [PSUM_WIDTH-1:0] p_sum_in [0:NUM_PE-1],
    output logic signed [PSUM_WIDTH-1:0] p_sum_out [0:NUM_PE-1]

);
    logic signed [ACT_WIDTH-1:0] internal_act [0:NUM_PE];
    logic internal_lock [0:NUM_PE];
    logic internal_flush [0:NUM_PE];
    assign internal_act[0] = act_in;
    assign internal_lock[0] = lock_in;
    assign internal_flush[0] = flush_in;
    genvar i;
    generate
            
        for (i = 0; i < NUM_PE; i = i+1) begin : genProcessElements
            
            processElement #(
                .ACT_WIDTH(ACT_WIDTH),
                .PSUM_WIDTH(PSUM_WIDTH)
            ) row1 (
            
                .clock(clock),
                .reset(reset),
                .lock_in(internal_lock[i]),
                .flush_in(internal_flush[i]),
                .act_in(internal_act[i]),
                .p_sum_in(p_sum_in[i]),
                .act_out(internal_act[i+1]),
                .p_sum_out(p_sum_out[i]),
                .lock_out(internal_lock[i+1]),
                .flush_out(internal_flush[i+1])
                
            );
        end        
    endgenerate
endmodule
