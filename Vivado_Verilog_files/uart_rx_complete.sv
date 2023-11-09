`timescale 1ns / 1ps

module uart_rx #(
    OVERSAMPLE = 13,
    N_DATA_BITS = 7,
    MAJORITY_START_IDX = 4,
    MAJORITY_END_IDX = 8
) (
    input   i_en,
            i_clk,
            i_data,
            i_reset,
    
    output  [N_DATA_BITS-1:0]   o_data,
                                o_data_valid
);
    localparam BUF_IDX_WIDTH = $clog2(OVERSAMPLE);
    reg [OVERSAMPLE-1:0] input_buffer;
    reg [BUF_IDX_WIDTH:0] buf_idx;
    integer rst_idx;
    
    always @(posedge i_clk) begin
        if(i_en) begin
            if(i_reset)
                buf_idx <= 'd0;
            else
                buf_idx <= (buf_idx < OVERSAMPLE-1) ? buf_idx+1 : 'd0; 
        end
    end
    
    always @(posedge  i_clk) begin
        if(i_en) begin
            if(i_reset)
                for(rst_idx = 0; rst_idx <OVERSAMPLE; rst_idx++) begin
                    input_buffer[rst_idx] <= 1'b0;
                end
            else
                input_buffer[buf_idx] <= i_data;
        end
    end
    
    function automatic obtained_bit(input [OVERSAMPLE-1:0] oversampled_bits);
        integer idx, count;
        count = 0;
        
        for(idx = MAJORITY_START_IDX; idx <= MAJORITY_END_IDX; idx = idx + 1) begin
            count = count + oversampled_bits[idx];
        end
        
        obtained_bit = (count>(MAJORITY_END_IDX - MAJORITY_START_IDX)/2);
    endfunction
    
    localparam integer FRAME_IDX_WIDTH = $clog2(N_DATA_BITS);
    
    reg frame_start;
    reg [FRAME_IDX_WIDTH:0] frame_idx;
    wire oversampled_data_valid;
    wire frame_start_condn;
    
    assign oversampled_data_valid = (buf_idx == (OVERSAMPLE-1));
    assign frame_start_condn = !obtained_bit(input_buffer);
    
    always @(posedge i_clk) begin
        if(i_en) begin
            if(i_reset) begin
                frame_start <= 1'b0;
            end else begin
                if(oversampled_data_valid & frame_start_condn & (frame_idx<(N_DATA_BITS-1)))
                    frame_start <= 1'b1;
                else if(frame_start & oversampled_data_valid & (frame_idx==N_DATA_BITS))
                    frame_start <= 1'b0;
            end 
        end
    end
    
    integer frame_rst_idx;
    reg [N_DATA_BITS:0] frame_data;
    
    always @(posedge i_clk) begin
        if(i_en) begin
            if(i_reset)
                frame_idx <= 'd0;
            else begin
                if(frame_start & oversampled_data_valid)
                    frame_idx <= frame_idx + 'd1;
                else if(!frame_start)
                    frame_idx <= 'd0;
            end    
        end
    end
    
    always @(posedge i_clk) begin
        if(i_en) begin
            if(i_reset) begin
                for(frame_rst_idx = 0; frame_rst_idx <= N_DATA_BITS; frame_rst_idx++)
                    frame_data[frame_rst_idx] <= 1'b0;
            end
            else if(frame_start & oversampled_data_valid) begin
                frame_data[frame_idx] <= obtained_bit(input_buffer);
            end
        end
    end
    
    reg frame_data_valid;
    
    always @(posedge i_clk) begin
        if(i_en) begin
            if(i_reset) begin
                frame_data_valid <= 1'b0;
            end
            else begin
                if(oversampled_data_valid)
                    frame_data_valid <= (frame_idx == (N_DATA_BITS-1));
            end
        end
    end
    // Finally ignore the stop bit, and connect the internal logic to the output ports
    assign o_data = frame_data[N_DATA_BITS-1:0];
    assign o_data_valid = frame_data_valid;
endmodule
