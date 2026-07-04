`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 04:40:22
// Design Name: 
// Module Name: skewRegisterAct
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


module skewRegisterAct #(
    parameter ACT_WIDTH = 8
)(
    input logic signed [ACT_WIDTH-1:0] act_in,
    input logic clock, flush_in, lock_in, reset,
    output logic signed [ACT_WIDTH-1:0] act_out,
    output logic flush_out, lock_out
);
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            act_out <= 0;
            flush_out <= 0;
            lock_out <= 0;
        end else begin
            act_out <= act_in;
            flush_out <= flush_in;
            lock_out <= lock_in;
        end
    end
endmodule
