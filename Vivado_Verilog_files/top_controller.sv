`timescale 1ns / 1ps

module top_controller(
    input   i_clk_100M,
            i_data_valid,
            i_uart_rx,
    output  o_uart_tx,
            uart_tx_ready
);

    localparam N_DATA_BITS = 7,
               OVERSAMPLE = 13;
                
    localparam integer UART_CLOCK_DIVIDER = 64;
    localparam integer MAJORITY_START_IDX = 4;
    localparam integer MAJORITY_END_IDX = 8;
    localparam integer UART_SUM_CLOCK_DIVIDER = UART_CLOCK_DIVIDER*OVERSAMPLE;
    localparam integer UART_SUM_CLOCK_WIDTH = $clog2(UART_SUM_CLOCK_DIVIDER);
    localparam integer UART_CLOCK_DIVIDER_WIDTH = $clog2(UART_CLOCK_DIVIDER);
    localparam integer SUM_BIT_WIDTH = 7;
    
    localparam integer ADDR_WIDTH = 15;
    localparam integer BRAM_WIDTH = 49;
    
    wire reset;
    
    reg uart_clk_rx;
    reg uart_en_rx;
    reg [UART_CLOCK_DIVIDER_WIDTH:0] uart_divider_counter;

    reg uart_clk_tx;
    reg uart_en_tx;
    reg [UART_CLOCK_DIVIDER_WIDTH:0] uart_divider_counter_tx;
    
    wire [N_DATA_BITS-1:0] uart_rx_data;
    wire uart_rx_data_valid;
    
    reg [N_DATA_BITS-1:0] uart_tx_data;
    reg uart_rx_data_valid_buf;
    
    // Variables for the seven segment display
    reg display_clk;
    reg display_data_update;
    reg [N_DATA_BITS-1:0] display_data;
    
    reg [BRAM_WIDTH-1:0] read_buf;
    reg [2:0] state1, state2;
    reg rd_mode, flag1, flag2, wea1, wea2, web1, web2;
    
    reg [BRAM_WIDTH-1:0] dina;
    reg [BRAM_WIDTH-1:0] doutb;
    reg [BRAM_WIDTH-1:0] doutb1;
    reg [BRAM_WIDTH-1:0] doutb2;
    reg [ADDR_WIDTH-1:0] addra;
    reg [ADDR_WIDTH-1:0] addrb;
    
//    vio_0 reset_source (
//      .clk(i_clk_100M),
//      .probe_out0(reset)  // output wire [0 : 0] probe_out0
//    );
    
    ila_0 ila_signal1 (
        .clk(uart_clk_tx), // input wire clk
        .probe0(i_data_valid), // input wire [0:0]  probe0  
        .probe1(uart_tx_data), // input wire [6:0]  probe1 
        .probe2(addrb), // input wire [14:0]  probe2
        .probe3(doutb), // input wire [48:0]  probe3 
        .probe4(state2) // input wire [2:0]  probe4
    );
    
//    ila_1 ila_signal2 (
//        .clk(uart_clk_tx), // input wire clk
//        .probe0(i_data_valid), // input wire [0:0]  probe0  
//        .probe1(uart_tx_data), // input wire [6:0]  probe1 
//        .probe2(addrb), // input wire [14:0]  probe2 
//        .probe3(doutb), // input wire [48:0]  probe3 
//        .probe4(state2) // input wire [2:0]  probe4
//    );
    
//    ila_1 ila_signal (
//	   .clk(uart_clk_rx), // input wire clk
//	   .probe0(i_data_valid), // input wire [0:0]  probe0  
//	   .probe1(i_uart_tx_data), // input wire [7:0]  probe1 
//	   .probe2(uart_tx_ready), // input wire [0:0]  probe2 
//	   .probe3(o_uart_tx), // input wire [0:0]  probe3
//	   .probe4(uart_en_tx) // input wire [0:0]  probe4
//    );

    uart_tx #(
        .N_DATA_BITS(N_DATA_BITS)) uart_transmistter (
        .i_uart_clk(uart_clk_tx),
        .i_uart_en(uart_en_tx),
        .i_uart_reset(reset),
        .i_uart_data_valid(i_data_valid),
        .i_uart_data(uart_tx_data),
        .o_uart_ready(uart_tx_ready),
        .o_uart_tx(o_uart_tx));
    
    uart_rx #(
        .OVERSAMPLE(OVERSAMPLE),
        .N_DATA_BITS(N_DATA_BITS),
        .MAJORITY_START_IDX(MAJORITY_START_IDX),
        .MAJORITY_END_IDX(MAJORITY_END_IDX)
    ) rx_data (
        .i_clk(uart_clk_rx),
        .i_en(uart_en_rx),
        .i_reset(reset),
        .i_data(i_uart_rx),
        
        .o_data(uart_rx_data),
        .o_data_valid(uart_rx_data_valid)
    );
    
//    seven_seg_drive #(
//        .INPUT_WIDTH(N_DATA_BITS),
//        .SEV_SEG_PRESCALAR(16)
//    ) display (
//        .i_clk(uart_clk_rx),
//        .number(display_data),
//        .decimal_points(4'h0),
//        .anodes(anodes),
//        .cathodes(cathodes)
//    );
    
    clk_wiz_0 instance_name(
        // Clock out ports
        .clk_out1(uart_clk_rx),     // output clk_out1
        .clk_out2(uart_clk_tx),     // output clk_out2
    // Clock in ports
        .clk_in1(i_clk_100M)
    );
    
//    blk_mem_gen_0 your_instance_name (
//      .clka(uart_clk_rx),    // input wire clka
//      .ena(1'b1),      // input wire ena
//      .wea(wea),      // input wire [0 : 0] wea
//      .addra(address),  // input wire [15 : 0] addra
//      .dina(dina),    // input wire [27 : 0] dina
//      .douta(douta)  // output wire [27 : 0] douta
//    );
    
    blk_mem_gen_0 blk_ram1 (
      .clka(uart_clk_rx),    // input wire clka
      .ena(1'b1),      // input wire ena
      .wea(wea1),      // input wire [0 : 0] wea
      .addra(addra),  // input wire [14 : 0] addra
      .dina(dina),    // input wire [48 : 0] dina
      .douta(douta1),  // output wire [48 : 0] douta
      .clkb(uart_clk_rx),    // input wire clkb
      .enb(1'b1),      // input wire enb
      .web(web1),      // input wire [0 : 0] web
      .addrb(addrb),  // input wire [14 : 0] addrb
      .dinb(dinb),    // input wire [48 : 0] dinb
      .doutb(doutb1)  // output wire [48 : 0] doutb
    );
    
    blk_mem_gen_1 blk_ram2 (
      .clka(uart_clk_rx),    // input wire clka
      .ena(1'b1),      // input wire ena
      .wea(wea2),      // input wire [0 : 0] wea
      .addra(addra),  // input wire [14 : 0] addra
      .dina(dina),    // input wire [48 : 0] dina
      .douta(douta2),  // output wire [48 : 0] douta
      .clkb(uart_clk_rx),    // input wire clkb
      .enb(1'b1),      // input wire enb
      .web(web2),      // input wire [0 : 0] web
      .addrb(addrb),  // input wire [14 : 0] addrb
      .dinb(dinb),    // input wire [48 : 0] dinb
      .doutb(doutb2)  // output wire [48 : 0] doutb
    );
    
    initial begin
        addra <= 'd0;
        addrb <= 'd0;
        state1 <= 'd0;
        state2 <= 'd0;
        flag1 <= 1'b0;
        flag2 <= 1'b0;
        wea1 <= 1'b1;
        wea2 <= 1'b0;
        web1 <= 1'b0;
        web2 <= 1'b1;
        rd_mode <= 1'b0;
        doutb <= doutb1;
    end
    
    always @(negedge uart_rx_data_valid) begin
            if(~rd_mode) begin
                case (state1)
                    3'b000: begin
                        dina[48:42] <= uart_rx_data;
                        state1 <= state1 + 3'b001;
                    end
                    
                    3'b001: begin
                        dina[41:35] <= uart_rx_data;
                        state1 <= state1 + 3'b001;
                    end
                    
                    3'b010: begin
                        dina[34:28] <= uart_rx_data;
                        state1 <= state1 + 3'b001;
                    end
                    
                    3'b011: begin
                        dina[27:21] <= uart_rx_data;
                        state1 <= state1 + 3'b001;
                    end
                    
                    3'b100: begin
                        dina[20:14] <= uart_rx_data;
                        state1 <= state1 + 3'b001;
                    end
                    
                    3'b101: begin
                        dina[13:7] <= uart_rx_data;
                        state1 <= state1 + 3'b001;
                    end
                    
                    3'b110: begin
                        dina[6:0] <= uart_rx_data;
                        state1 <= state1 + 3'b010;
                        if(addra=='d32767 && flag1==1'b0) begin
                            flag1 <= 1'b1;
                            wea1 <= 1'b0;
                            wea2 <= 1'b1;
                        end
                        if(addra=='d32767 && flag1==1'b1) begin
                            rd_mode <= 1'b1;
                            wea1 <= 1'b0;
                            wea2 <= 1'b0;
                        end
                        addra <= addra + 'd1;
                    end
                        
                    3'b111: begin
                        dina <= dina;
                    end
                    
                    default: begin
                        dina <= dina;
                    end
                endcase
            end 
    end
    
    always @(posedge uart_clk_rx) begin
        if(i_data_valid && rd_mode) begin
            case (state2)
                3'b000: begin
                    uart_tx_data <= doutb[48:42];
                    state2 <= state2 + 3'b001;
                end
                
                3'b001: begin
                    uart_tx_data <= doutb[41:35];
                    state2 <= state2 + 3'b001;
                end
                
                3'b010: begin
                    uart_tx_data <= doutb[34:28];
                    state2 <= state2 + 3'b001;
                end
                
                3'b011: begin
                    uart_tx_data <= doutb[27:21];
                    state2 <= state2 + 3'b001;
                end
                
                3'b100: begin
                    uart_tx_data <= doutb[20:14];
                    state2 <= state2 + 3'b001;
                end
                
                3'b101: begin
                    uart_tx_data <= doutb[13:7];
                    state2 <= state2 + 3'b001;
                end
                
                3'b110: begin
                    uart_tx_data <= doutb[6:0];
                    state2 <= state2 + 3'b010;
                    if(addrb=='d32767 && flag2==1'b0) begin
                        flag2 <= 1'b1;
                        doutb <= doutb2;
                        web1 <= 1'b1;
                        web2 <= 1'b0;
                    end
                    if(addrb=='d32767 && flag2==1'b1) begin
                        web1 <= 1'b1;
                        web2 <= 1'b1;
                    end
                    addrb <= addrb + 'd1;
                end
                    
                3'b111: begin
                    uart_tx_data <= uart_tx_data;
                end
                
                default: begin
                    uart_tx_data <= uart_tx_data;
                end
            endcase
        end
    end
    
    always @(posedge uart_clk_rx) begin
        if(uart_divider_counter < (UART_CLOCK_DIVIDER-1))
            uart_divider_counter <= uart_divider_counter + 1;
       else
            uart_divider_counter <= 'd0;
    end
    
//    always @(posedge uart_clk_rx) begin
//        if(uart_sum_divider < (UART_SUM_CLOCK_DIVIDER-1))
//            uart_sum_divider <= uart_sum_divider + 1;
//       else
//            uart_sum_divider <= 'd0;
//    end
    
    always @(posedge uart_clk_rx) begin
        uart_en_rx <= (uart_divider_counter == 'd10);
    end
    
//    always @(posedge uart_clk_rx) begin
//        uart_sum_clk <= (uart_sum_divider == 'd10);
//    end

    always @(posedge uart_clk_tx) begin
        if(uart_divider_counter_tx < (UART_CLOCK_DIVIDER-1))
            uart_divider_counter_tx <= uart_divider_counter_tx + 1;
       else
            uart_divider_counter_tx <= 'd0;
    end
    
    always @(posedge uart_clk_tx) begin
        uart_en_tx <= (uart_divider_counter_tx == 'd10);
    end
    
endmodule
