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

    parameter FABRIC_NUM_COLUMNS = 4;
    parameter FABRIC_NUM_ROWS = 5;

    wire [159:0] frame_data;
    wire [ 79:0] frame_strobe;

    wire [9:0] GPIO_OUT;
    wire [9:0] GPIO_IN;
    wire [9:0] GPIO_EN;
    
    wire [31:0] bitstream_data;
    wire        bitstream_valid;

    fabric_spi_receiver fabric_spi_receiver (
        .clk_i   (clk),
        .rst_ni  (rst_n),
        
        // Bitstream data
        .bitstream_data_o   (bitstream_data),
        .bitstream_valid_o  (bitstream_valid),
        
        // Enable the SPI receiver
        .enable_i (1'b1),
        
        // SPI
        .sclk_i (ui_in[0]),
        .cs_ni  (ui_in[1]),
        .mosi_i (ui_in[2]),
        .miso_o (uo_out[0])
    );

    fabric_config #(
        .FABRIC_NUM_COLUMNS (FABRIC_NUM_COLUMNS),
        .FABRIC_NUM_ROWS    (FABRIC_NUM_ROWS)
    ) fabric_config (
        .clk_i   (clk),
        .rst_ni  (rst_n),
        
        // Bitstream data
        .bitstream_data_i   (bitstream_data),
        .bitstream_valid_i  (bitstream_valid),
        
        // Configuration in progress
        .busy_o         (),
        
        // Fabric is configured
        .configured_o   (),
        
        // To the fabric
        .frame_data_o   (frame_data),
        .frame_strobe_o (frame_strobe)
    );

    (* keep *) eFPGA eFPGA (
        .Tile_X0Y1_A_EN_top   (GPIO_EN[0]),
        .Tile_X0Y1_A_IN_top   (GPIO_IN[0]),
        .Tile_X0Y1_A_OUT_top  (GPIO_OUT[0]),
        .Tile_X0Y2_A_EN_top   (GPIO_EN[1]),
        .Tile_X0Y2_A_IN_top   (GPIO_IN[1]),
        .Tile_X0Y2_A_OUT_top  (GPIO_OUT[1]),
        .Tile_X1Y0_A_EN_top   (GPIO_EN[2]),
        .Tile_X1Y0_A_IN_top   (GPIO_IN[2]),
        .Tile_X1Y0_A_OUT_top  (GPIO_OUT[2]),
        .Tile_X1Y3_A_EN_top   (GPIO_EN[3]),
        .Tile_X1Y3_A_IN_top   (GPIO_IN[3]),
        .Tile_X1Y3_A_OUT_top  (GPIO_OUT[3]),
        .Tile_X2Y0_A_EN_top   (GPIO_EN[4]),
        .Tile_X2Y0_A_IN_top   (GPIO_IN[4]),
        .Tile_X2Y0_A_OUT_top  (GPIO_OUT[4]),
        .Tile_X2Y3_A_EN_top   (GPIO_EN[5]),
        .Tile_X2Y3_A_IN_top   (GPIO_IN[5]),
        .Tile_X2Y3_A_OUT_top  (GPIO_OUT[5]),
        .Tile_X3Y0_A_EN_top   (GPIO_EN[6]),
        .Tile_X3Y0_A_IN_top   (GPIO_IN[6]),
        .Tile_X3Y0_A_OUT_top  (GPIO_OUT[6]),
        .Tile_X3Y3_A_EN_top   (GPIO_EN[7]),
        .Tile_X3Y3_A_IN_top   (GPIO_IN[7]),
        .Tile_X3Y3_A_OUT_top  (GPIO_OUT[7]),
        .Tile_X4Y1_A_EN_top   (GPIO_EN[8]),
        .Tile_X4Y1_A_IN_top   (GPIO_IN[8]),
        .Tile_X4Y1_A_OUT_top  (GPIO_OUT[8]),
        .Tile_X4Y2_A_EN_top   (GPIO_EN[9]),
        .Tile_X4Y2_A_IN_top   (GPIO_IN[9]),
        .Tile_X4Y2_A_OUT_top  (GPIO_OUT[9]),

        .FrameData            (frame_data),
        .FrameStrobe          (frame_strobe)
    );

    assign GPIO_OUT = {2'b0, uio_in};
    assign uio_oe = GPIO_EN[7:0];
    assign uio_out = GPIO_IN[7:0];
    
    assign uo_out[7:1] = '0;

endmodule
