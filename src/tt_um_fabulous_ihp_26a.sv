// SPDX-FileCopyrightText: © 2026 Leo Moser <leo.moser@pm.me>
// SPDX-License-Identifier: Apache-2.0

module tt_um_fabulous_ihp_26a (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    parameter FABRIC_NUM_COLUMNS = 5;
    parameter FABRIC_NUM_ROWS = 5;
    
    parameter FRAME_BITS_PER_ROW = 32;
    parameter MAX_FRAMES_PER_COL = 20;

    wire [(FRAME_BITS_PER_ROW*FABRIC_NUM_ROWS)-1:0]    frame_data;
    wire [(MAX_FRAMES_PER_COL*FABRIC_NUM_COLUMNS)-1:0] frame_strobe;
    
    wire [31:0] bitstream_data;
    wire        bitstream_valid;

    fabric_bitbang fabric_bitbang (
        .clk_i   (clk),
        .rst_ni  (!rst_n), // inverted polarity: config is active when the design is not

        .sample_i (ui_in[0]),
        .data_i   (ui_in[1]),

        // Bitstream data
        .bitstream_data_o   (bitstream_data),
        .bitstream_valid_o  (bitstream_valid)
    );

    wire fabric_sys_reset;

    fabric_config #(
        .FABRIC_NUM_COLUMNS (FABRIC_NUM_COLUMNS),
        .FABRIC_NUM_ROWS    (FABRIC_NUM_ROWS)
    ) fabric_config (
        .clk_i   (clk),
        .rst_ni  (!rst_n), // inverted polarity: config is active when the design is not
        
        // Bitstream data
        .bitstream_data_i   (bitstream_data),
        .bitstream_valid_i  (bitstream_valid),
        
        // Configuration in progress
        .busy_o         (fabric_sys_reset),
        
        // Fabric is configured
        .configured_o   (),
        
        // To the fabric
        .frame_data_o   (frame_data),
        .frame_strobe_o (frame_strobe)
    );

    wire       fabric_clk;
    wire       fabric_rst_n;
    wire [7:0] fabric_ui_in;
    wire [7:0] fabric_uo_out;
    wire [7:0] fabric_uio_in;
    wire [7:0] fabric_uio_out;
    wire [7:0] fabric_uio_oe;

    assign fabric_clk = clk;
    assign fabric_rst_n = rst_n;
    assign fabric_ui_in = ui_in;
    assign fabric_uio_in = uio_in;
    
    assign uo_out = fabric_uo_out;
    assign uio_out = fabric_uio_out;
    assign uio_oe = fabric_uio_oe;

    tiny_fabric_5x5 tiny_fabric_5x5 (
        // IN/OUT is from the PoV of the fabric

        // clk
        .Tile_X0Y2_A_EN_top   (),
        .Tile_X0Y2_A_IN_top   (),
        .Tile_X0Y2_A_OUT_top  (fabric_clk),
    
        // rst_n
        .Tile_X0Y2_B_EN_top   (),
        .Tile_X0Y2_B_IN_top   (),
        .Tile_X0Y2_B_OUT_top  (fabric_rst_n),

        // ui
        .Tile_X0Y3_A_EN_top   (),
        .Tile_X0Y3_A_IN_top   (),
        .Tile_X0Y3_A_OUT_top  (fabric_ui_in[0]),
        .Tile_X0Y3_B_EN_top   (),
        .Tile_X0Y3_B_IN_top   (),
        .Tile_X0Y3_B_OUT_top  (fabric_ui_in[1]),
        .Tile_X0Y3_C_EN_top   (),
        .Tile_X0Y3_C_IN_top   (),
        .Tile_X0Y3_C_OUT_top  (fabric_ui_in[2]),
        .Tile_X0Y3_D_EN_top   (),
        .Tile_X0Y3_D_IN_top   (),
        .Tile_X0Y3_D_OUT_top  (fabric_ui_in[3]),
        .Tile_X0Y1_A_EN_top   (),
        .Tile_X0Y1_A_IN_top   (),
        .Tile_X0Y1_A_OUT_top  (fabric_ui_in[4]),
        .Tile_X0Y1_B_EN_top   (),
        .Tile_X0Y1_B_IN_top   (),
        .Tile_X0Y1_B_OUT_top  (fabric_ui_in[5]),
        .Tile_X0Y1_C_EN_top   (),
        .Tile_X0Y1_C_IN_top   (),
        .Tile_X0Y1_C_OUT_top  (fabric_ui_in[6]),
        .Tile_X0Y1_D_EN_top   (),
        .Tile_X0Y1_D_IN_top   (),
        .Tile_X0Y1_D_OUT_top  (fabric_ui_in[7]),

        // uo
        .Tile_X4Y3_A_EN_top   (),
        .Tile_X4Y3_A_IN_top   (fabric_uo_out[0]),
        .Tile_X4Y3_A_OUT_top  (1'b0),
        .Tile_X4Y3_B_EN_top   (),
        .Tile_X4Y3_B_IN_top   (fabric_uo_out[1]),
        .Tile_X4Y3_B_OUT_top  (1'b0),
        .Tile_X4Y3_C_EN_top   (),
        .Tile_X4Y3_C_IN_top   (fabric_uo_out[2]),
        .Tile_X4Y3_C_OUT_top  (1'b0),
        .Tile_X4Y3_D_EN_top   (),
        .Tile_X4Y3_D_IN_top   (fabric_uo_out[3]),
        .Tile_X4Y3_D_OUT_top  (1'b0),
        .Tile_X4Y1_A_EN_top   (),
        .Tile_X4Y1_A_IN_top   (fabric_uo_out[4]),
        .Tile_X4Y1_A_OUT_top  (1'b0),
        .Tile_X4Y1_B_EN_top   (),
        .Tile_X4Y1_B_IN_top   (fabric_uo_out[5]),
        .Tile_X4Y1_B_OUT_top  (1'b0),
        .Tile_X4Y1_C_EN_top   (),
        .Tile_X4Y1_C_IN_top   (fabric_uo_out[6]),
        .Tile_X4Y1_C_OUT_top  (1'b0),
        .Tile_X4Y1_D_EN_top   (),
        .Tile_X4Y1_D_IN_top   (fabric_uo_out[7]),
        .Tile_X4Y1_D_OUT_top  (1'b0),

        // uio
        .Tile_X1Y4_A_EN_top   (fabric_uio_oe[0]),
        .Tile_X1Y4_A_IN_top   (fabric_uio_out[0]),
        .Tile_X1Y4_A_OUT_top  (fabric_uio_in[0]),
        .Tile_X1Y4_B_EN_top   (fabric_uio_oe[1]),
        .Tile_X1Y4_B_IN_top   (fabric_uio_out[1]),
        .Tile_X1Y4_B_OUT_top  (fabric_uio_in[1]),
        .Tile_X1Y4_C_EN_top   (fabric_uio_oe[2]),
        .Tile_X1Y4_C_IN_top   (fabric_uio_out[2]),
        .Tile_X1Y4_C_OUT_top  (fabric_uio_in[2]),
        .Tile_X1Y4_D_EN_top   (fabric_uio_oe[3]),
        .Tile_X1Y4_D_IN_top   (fabric_uio_out[3]),
        .Tile_X1Y4_D_OUT_top  (fabric_uio_in[3]),
        .Tile_X3Y4_A_EN_top   (fabric_uio_oe[4]),
        .Tile_X3Y4_A_IN_top   (fabric_uio_out[4]),
        .Tile_X3Y4_A_OUT_top  (fabric_uio_in[4]),
        .Tile_X3Y4_B_EN_top   (fabric_uio_oe[5]),
        .Tile_X3Y4_B_IN_top   (fabric_uio_out[5]),
        .Tile_X3Y4_B_OUT_top  (fabric_uio_in[5]),
        .Tile_X3Y4_C_EN_top   (fabric_uio_oe[6]),
        .Tile_X3Y4_C_IN_top   (fabric_uio_out[6]),
        .Tile_X3Y4_C_OUT_top  (fabric_uio_in[6]),
        .Tile_X3Y4_D_EN_top   (fabric_uio_oe[7]),
        .Tile_X3Y4_D_IN_top   (fabric_uio_out[7]),
        .Tile_X3Y4_D_OUT_top  (fabric_uio_in[7]),

        // SYS_RESET
        .Tile_X0Y4_SYS_RESET_RESET_top (fabric_sys_reset),

        .FrameData            (frame_data),
        .FrameStrobe          (frame_strobe)
    );

endmodule
