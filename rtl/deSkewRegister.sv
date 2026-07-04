`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 04:11:58
// Design Name: 
// Module Name: deSkewRegister
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


module deSkewRegister #(
    parameter  PSUM_WIDTH = 32
)(
    input logic signed [PSUM_WIDTH-1:0] psum_in,
    input logic clock,
    input logic reset,
    input logic lock_in,
    
    output logic signed [PSUM_WIDTH-1:0] psum_out
);
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            psum_out <= 0;
        end else if (!lock_in) begin
            psum_out <= psum_in;
        end
    end
endmodule

