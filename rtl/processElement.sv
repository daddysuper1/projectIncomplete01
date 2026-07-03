`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2026 23:10:04
// Design Name: 
// Module Name: processElement
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


module processElement #(
    parameter ACT_WIDTH = 8,
    parameter PSUM_WIDTH = 32
    
)(
    input logic clock,
    input logic reset,
    input logic lock_in,
    input logic flush_in, 
    input logic signed [ACT_WIDTH-1:0] act_in,
    input logic signed [PSUM_WIDTH-1:0] p_sum_in,
    
    output logic signed [ACT_WIDTH-1:0] act_out,
    output logic signed [PSUM_WIDTH-1:0] p_sum_out,
    output logic lock_out,
    output logic flush_out

);
    
    logic signed [ACT_WIDTH-1:0] act_reg, next_act;
    logic act_zero_reg;
    logic flush_reg;
    logic lock_reg;
    
    logic signed [ACT_WIDTH-1:0] weight_reg, next_weight;
    logic weight_zero_reg;    
    logic signed [PSUM_WIDTH-1:0] psum_reg;
    
    
    logic pe_skip;
    logic signed [ACT_WIDTH-1:0] gated_act;
    logic signed [ACT_WIDTH-1:0] gated_weight;
    logic signed [2*ACT_WIDTH-1:0] multiply_out;
    logic signed [PSUM_WIDTH-1:0] psum_mux;
    logic signed [PSUM_WIDTH-1:0] next_psum;
    
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            act_reg <= '0;
            act_zero_reg <= 1'b1;
            lock_reg <= 0;
            flush_reg <= 0;
            
            psum_reg <= 0;
            weight_reg <= 0;
            weight_zero_reg <= 1'b1;
            
        end else begin
            act_reg <= act_in;
            act_zero_reg <= (act_in == 0);
            flush_reg <= flush_in;
            lock_reg <= lock_in; 
            
            if (lock_in) begin
                weight_reg <= act_in;
                weight_zero_reg <= (act_in == 0);
                psum_reg <= psum_reg;
            end else begin
                weight_reg <= weight_reg;
                weight_zero_reg <= weight_zero_reg;
                psum_reg <= next_psum;
            end
       
        end            
    end
    
    always_comb begin
    
        pe_skip = act_zero_reg | weight_zero_reg | lock_reg;
        
        gated_act = act_reg & {ACT_WIDTH{~pe_skip}};
        gated_weight = weight_reg & {ACT_WIDTH{~pe_skip}};
        
        multiply_out = gated_weight * gated_act;
        
        psum_mux = flush_reg ? '0 : p_sum_in;
        next_psum = psum_mux + multiply_out;
        

    end
    
    assign act_out = act_reg;
    assign p_sum_out = psum_reg;
    assign lock_out = lock_reg;
    assign flush_out = flush_reg;
    
endmodule
