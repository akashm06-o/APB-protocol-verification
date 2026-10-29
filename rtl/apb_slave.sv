```systemverilog
module apb_slave (
    input  logic        PCLK,
    input  logic        PRESETn,

    // APB control signals
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,

    // APB address and write data
    input  logic [7:0]  PADDR,
    input  logic [31:0] PWDATA,

    // APB response signals
    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR
);

    // Memory: 16 locations, each 32 bits wide
    logic [31:0] mem [0:15];

    // Simple slave: always ready, no errors
    assign PREADY  = 1'b1;
    assign PSLVERR = 1'b0;

    // Read operation
    always_comb begin
        PRDATA = 32'b0;

        if (PADDR[7:6] == 2'b00)
            PRDATA = mem[PADDR[5:2]];
    end

    // Write operation and asynchronous active-low reset
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            for (int i = 0; i < 16; i = i + 1)
                mem[i] <= 32'b0;
        end
        else if (PSEL && PENABLE && PREADY && PWRITE) begin
            if (PADDR[7:6] == 2'b00)
                mem[PADDR[5:2]] <= PWDATA;
        end
    end

endmodule
```
