`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2026 11:53:11
// Design Name: 
// Module Name: array2D
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
/////////////////////////////////////////////////////////////////////////////////

module array2D #(
    parameter NUM_PE = 4,
    parameter NUM_ROWS = 4,
    parameter ACT_WIDTH = 8,
    parameter PSUM_WIDTH = 32
)(
    input logic signed [ACT_WIDTH-1:0] act_in [0:NUM_ROWS-1],
    input logic signed [PSUM_WIDTH-1:0] p_sum_in [0:NUM_PE-1],
    input logic flush_in, 
    input logic lock_in,
    input logic clock, reset,
    output logic signed [PSUM_WIDTH-1:0] p_sum_out [0:NUM_PE-1]
);
    logic signed [PSUM_WIDTH-1:0] internal_psum [0:NUM_ROWS][0:NUM_PE-1];
    
    assign internal_psum[0] = p_sum_in;
    
    genvar i, j;
    generate
        for(i = 0; i < NUM_ROWS; i = i + 1) begin
            
            logic signed [ACT_WIDTH-1:0] internal_act [0:i];
            logic internal_flush [0:i];
            logic internal_lock [0:i];
             
            assign internal_act[0] = act_in[i];
            assign internal_flush[0] = flush_in;
            assign internal_lock[0] = lock_in;
            
            for(j = 0; j < i; j = j + 1) begin
                
                skewRegisterAct #(
                    .ACT_WIDTH(ACT_WIDTH)
                ) delay_inst (
                    .act_in(internal_act[j]),
                    .clock(clock),
                    .reset(reset),
                    .flush_in(internal_flush[j]),
                    .lock_in(internal_lock[j]),
                    .act_out(internal_act[j+1]),
                    .flush_out(internal_flush[j+1]),
                    .lock_out(internal_lock[j+1])        
                );
                
                
            end
            
            systolicRow #(
                .NUM_PE(NUM_PE),
                .ACT_WIDTH(ACT_WIDTH),
                .PSUM_WIDTH(PSUM_WIDTH)
            ) row_inst (
                .clock(clock),
                .reset(reset),
                .act_in(internal_act[i]),
                .flush_in(internal_flush[i]),
                .lock_in(internal_lock[i]),
                .p_sum_in(internal_psum[i]),
                .p_sum_out(internal_psum[i+1])
            );
            
            
        end
        
        
    endgenerate
    
    
    
    genvar k,l;
    generate
        for(k = 0; k < NUM_PE; k = k + 1) begin
            
            localparam int DELAY_DEPTH = NUM_PE - 1 - k;
            
            if (DELAY_DEPTH == 0) begin
                assign p_sum_out[k] = internal_psum[NUM_ROWS][k];
            end else begin
                logic signed [PSUM_WIDTH-1:0] psum_buffer [0:DELAY_DEPTH];
                assign psum_buffer[0] = internal_psum[NUM_ROWS][k];
                
                for(l=0; l < DELAY_DEPTH; l = l + 1) begin
                    deSkewRegister #(
                        .PSUM_WIDTH(PSUM_WIDTH)
                    ) deSkewPsum_inst (
                        .clock(clock),
                        .reset(reset),
                        .lock_in(lock_in),
                        .psum_in(psum_buffer[l]),
                        .psum_out(psum_buffer[l+1])
                    );
                end
                
                assign p_sum_out[k] = psum_buffer[DELAY_DEPTH];
            end
            
        end
    endgenerate
endmodule
