// SPDX-FileCopyrightText: © 2026 FABulous Contributors
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module top_counter (
    input  wire       clk,
    input  wire       rst_n,
    
    output wire [7:0] uo
);

    wire clk_buf;

    GBUF clock_buf (
      .IN   (clk),
      .OUT  (clk_buf)
    );

    reg [7:0] ctr1;
    
    wire rst;
    
    GBUF #(
      .INVERT (1'b1)
    ) rst_buf (
      .IN   (rst_n),
      .OUT  (rst)
    );

    // Reset before enable
    always @(posedge clk_buf) begin
        if (rst) begin
            ctr1 <= '0;
        end else begin
            ctr1 <= ctr1 + 1'b1;
        end
    end

    assign uo = ctr1;

endmodule
