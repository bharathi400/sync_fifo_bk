`timescale 1ns/1ps

module tb_sync_fifo;

//====================================================
// Parameters
//====================================================
parameter DATA_WIDTH = 8;
parameter DEPTH      = 16;
parameter ADDR_WIDTH = 4;

//====================================================
// Testbench Signals
//====================================================
reg clk;
reg rst;
reg wr_en;
reg rd_en;
reg [DATA_WIDTH-1:0] din;

wire [DATA_WIDTH-1:0] dout;
wire full;
wire empty;
wire almost_full;
wire almost_empty;
wire overflow;
wire underflow;
wire [ADDR_WIDTH:0] fifo_count;

//====================================================
// DUT Instantiation
//====================================================
sync_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
)
DUT
(
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty),
    .almost_full(almost_full),
    .almost_empty(almost_empty),
    .overflow(overflow),
    .underflow(underflow),
    .fifo_count(fifo_count)
);

//====================================================
// Clock Generation (10ns Period)
//====================================================
always #5 clk = ~clk;

//====================================================
// Test Sequence
//====================================================
integer i;

initial
begin

    clk   = 0;
    rst   = 1;
    wr_en = 0;
    rd_en = 0;
    din   = 0;

    //--------------------------------------
    // Reset
    //--------------------------------------
    #20;
    rst = 0;

    //--------------------------------------
    // Write 16 Data
    //--------------------------------------
    $display("\nWriting Data into FIFO");

    for(i=0;i<16;i=i+1)
    begin
        @(posedge clk);
        wr_en = 1;
        rd_en = 0;
        din = i+1;
    end

    @(posedge clk);
    wr_en = 0;

    //--------------------------------------
    // Overflow Test
    //--------------------------------------
    $display("\nOverflow Test");

    @(posedge clk);
    wr_en = 1;
    din = 8'hAA;

    @(posedge clk);
    wr_en = 0;

    //--------------------------------------
    // Read All Data
    //--------------------------------------
    $display("\nReading FIFO");

    for(i=0;i<16;i=i+1)
    begin
        @(posedge clk);
        rd_en = 1;
        wr_en = 0;
    end

    @(posedge clk);
    rd_en = 0;

    //--------------------------------------
    // Underflow Test
    //--------------------------------------
    $display("\nUnderflow Test");

    @(posedge clk);
    rd_en = 1;

    @(posedge clk);
    rd_en = 0;

    //--------------------------------------
    // Simultaneous Read & Write
    //--------------------------------------
    $display("\nSimultaneous Read/Write");

    @(posedge clk);
    wr_en = 1;
    rd_en = 1;
    din = 8'h55;

    @(posedge clk);
    wr_en = 0;
    rd_en = 0;

    //--------------------------------------
    // Finish
    //--------------------------------------
    #50;

    $display("\nSimulation Finished");

    $finish;

end

//====================================================
// Monitor
//====================================================
initial
begin

$monitor("Time=%0t | wr=%b rd=%b din=%d dout=%d count=%d full=%b empty=%b AF=%b AE=%b OF=%b UF=%b",
$time,
wr_en,
rd_en,
din,
dout,
fifo_count,
full,
empty,
almost_full,
almost_empty,
overflow,
underflow);

end

endmodule
