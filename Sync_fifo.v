`timescale 1ns/1ps

module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = 4
)(
    input                       clk,
    input                       rst,

    input                       wr_en,
    input                       rd_en,

    input  [DATA_WIDTH-1:0]     din,

    output reg [DATA_WIDTH-1:0] dout,

    output                      full,
    output                      empty,
    output                      almost_full,
    output                      almost_empty,

    output reg                  overflow,
    output reg                  underflow,

    output [ADDR_WIDTH:0]       fifo_count
);

    //====================================
    // Memory Array
    //====================================
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    //====================================
    // Internal Registers
    //====================================
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
    reg [ADDR_WIDTH:0]   count;

    //====================================
    // Status Flags
    //====================================
    assign full          = (count == DEPTH);
    assign empty         = (count == 0);
    assign almost_full   = (count >= DEPTH-1);
    assign almost_empty  = (count <= 1);

    assign fifo_count = count;

    //====================================
    // FIFO Logic
    //====================================
    always @(posedge clk or posedge rst)
    begin

        if(rst)
        begin
            wr_ptr     <= 0;
            rd_ptr     <= 0;
            count      <= 0;

            dout       <= 0;

            overflow   <= 0;
            underflow  <= 0;
        end

        else
        begin

            overflow  <= 0;
            underflow <= 0;

            //-----------------------------
            // Write Only
            //-----------------------------
            if(wr_en && !rd_en)
            begin

                if(!full)
                begin
                    mem[wr_ptr] <= din;
                    wr_ptr <= wr_ptr + 1;
                    count <= count + 1;
                end

                else
                    overflow <= 1;

            end

            //-----------------------------
            // Read Only
            //-----------------------------
            else if(rd_en && !wr_en)
            begin

                if(!empty)
                begin
                    dout <= mem[rd_ptr];
                    rd_ptr <= rd_ptr + 1;
                    count <= count - 1;
                end

                else
                    underflow <= 1;

            end

            //-----------------------------
            // Simultaneous Read & Write
            //-----------------------------
            else if(wr_en && rd_en)
            begin

                if(!full && !empty)
                begin
                    mem[wr_ptr] <= din;
                    wr_ptr <= wr_ptr + 1;

                    dout <= mem[rd_ptr];
                    rd_ptr <= rd_ptr + 1;

                    // Count remains same
                end

                else if(empty)
                begin
                    mem[wr_ptr] <= din;
                    wr_ptr <= wr_ptr + 1;
                    count <= count + 1;
                end

                else if(full)
                begin
                    dout <= mem[rd_ptr];
                    rd_ptr <= rd_ptr + 1;
                    count <= count - 1;
                end

            end

        end

    end

endmodule
