//this a generic module that represents a register that is followed by a mux to indicate wether the output will be pipelined or not 
module reg_mux #(parameter SEL = 1 , WIDTH = 18 , RSTTYPE = "SYNC")( //the default input/output width is 18
    input [WIDTH-1:0] in ,
    input clk , clk_enable , rst ,
    output reg [WIDTH-1:0] out 
);
reg [WIDTH-1:0] in_reg ; //internal signal to be pipelined
reg [WIDTH-1:0] out_reg ; //internal signal represents output in always block to be pipelined 
generate  //generate block required to determine wether the reset is synchronous or asynchronous
    if(RSTTYPE == "SYNC") begin
        always @(posedge clk) begin
            if(rst)
                out_reg <= 0;
            else if (clk_enable)
                in_reg <= in;
        end
    end
    else begin
        always @(posedge clk , posedge rst) begin
            if(rst)
                out_reg <= 0;
            else if (clk_enable)
                in_reg <= in;
        end
    end
endgenerate
//output
//assign out = (rst) ? out_reg : (SEL) ? in_reg : in ; //if reset we will choose the out_reg which is zero and else if SEL = 1 we choose in_reg (pipelined) and else we choose in(not pipelined)
always @(*) begin
    if(rst)
        out = out_reg;
    else if (SEL) begin
        //this condition is to handle the case when we release the reset and then the in_reg has not yet come due to the +vel edge then in this time the signal is unknown so we will make it zero
        if(in_reg === 1'bx || in_reg === 8'hxx || in_reg === 18'hxxxx || in_reg === 36'hxxxxxxxxx || in_reg === 48'hxxxxxxxxxxxx)  
            out = out_reg;
        else
            out = in_reg;
    end
    else 
        out = in;
end 
endmodule