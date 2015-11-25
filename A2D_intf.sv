module A2D_intf(clk, rst_n, strt_cnv, MISO, chnnl, cnv_cmplt, a2d_SS_n, SCLK, MOSI, res);

input clk, rst_n, strt_cnv, MISO;
input [2:0] chnnl;
output reg cnv_cmplt, a2d_SS_n, SCLK, MOSI;
output reg [11:0] res;
logic wrt, done, set_conv;
logic [15:0] cmd, rd_data;

typedef enum reg[1:0] {IDLE, WAIT, WAIT_SOME_MORE, GRAB_DATA} state_t;
state_t st, nxt_st;

SPI_mstr_Eric i_mstr(.clk(clk), .rst_n(rst_n), .wrt(wrt), .cmd(cmd), .done(done), .rd_data(rd_data), .SCLK(SCLK), .SS_n(a2d_SS_n), .MOSI(MOSI), .MISO(MISO));

assign cmd = {2'b0, chnnl, 11'b0};
assign res = rd_data[11:4];

always@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        cnv_cmplt <= 1'b0;
    end else begin
        if(set_conv)
            cnv_cmplt <= 1'b1;
        else
            cnv_cmplt <= 1'b0;
        //if (strt_cnv) begin
        //    cnv_cmplt <= 1'b0;
        //end else if (set_conv) begin
        //    cnv_cmplt <= 1'b1;
        //end //else remember
    end
end

always@(posedge clk, negedge rst_n) begin
    if(!rst_n)
        st <= IDLE;
    else
        st <= nxt_st;
end

always_comb begin
wrt = 1'b0;
set_conv = 1'b0;
    case(st)
        IDLE:
            if(strt_cnv) begin
                wrt = 1'b1;
                nxt_st = WAIT;
            end else begin
                nxt_st = IDLE;
            end
        WAIT:
            if(!done) begin
                nxt_st = WAIT;
            end else begin
                nxt_st = WAIT_SOME_MORE;
            end
        WAIT_SOME_MORE: begin
                wrt = 1'b1;
                nxt_st = GRAB_DATA;
            end
        GRAB_DATA:
            if(!done) begin
                nxt_st = GRAB_DATA;
            end else begin
                set_conv = 1'b1;
                nxt_st = IDLE;
            end
        default:
            nxt_st = IDLE;
    endcase
end

endmodule
