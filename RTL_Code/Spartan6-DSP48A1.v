//this is the main design module for Spartan-DSP48A1 Project
module DSP48A1 #(parameter A0REG = 0 , A1REG = 1 , B0REG = 0 , B1REG = 1 ,
CREG = 1 , DREG = 1 , MREG = 1 , PREG = 1 , CARRYINREG = 1 , CARRYOUTREG = 1 ,
OPMODEREG = 1 , CARRYINSEL = "OPMODE5" , B_INPUT = "DIRECT" , RSTTYPE = "ASYNC")( //these parameters are the selectors for the "gray" muxes
    input [17:0] A ,
    input [17:0] B ,
    input [17:0] BCIN ,
    input [47:0] C , 
    input [17:0] D ,
    input CARRYIN ,
    input [47:0] PCIN ,
    output [17:0] BCOUT ,
    output [35:0] M ,   //output from the multiplier
    output [47:0] P , PCOUT , 
    output CARRYOUT ,
    output CARRYOUTF , //same carryout signal but for the FPGA
    input clk ,
    input [7:0] OPMODE ,
    input CEA , CEB , CEC , CECARRYIN , CED , CEM , CEOPMODE , CEP , //clock enables
        RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP //active high resets for every register
);
//firstly implementing the first section which has the inputs and theit registers and muxed
wire [17:0] A_OUT , B_in , B_OUT , D_OUT;
wire [47:0] C_OUT ;
wire [17:0] pre_out ;//output of the pre-adder/subtracor
wire [17:0] mux_opmode4_out ;  //the output of the first and only white mux inthe schematic
wire [7:0] OPMODE_OUT ;  
wire [17:0] ACOUT ;  //output of the second register (A1 REG) of input A 
wire [35:0] multiplier_out ; //output of the multiplier
reg [47:0] X_OUT , Z_OUT ; //output of the X and Z muxes
wire carry_in_cascade_out ; //output of the carry_in cascade mux
wire [47:0] post_out ; //output of the post-adder/subtracor 
wire CIN ; 
wire carry_out_post ; //the carryout that comes from the post-adder/subtracor
assign B_in = (B_INPUT=="DIRECT") ? B : BCIN ; //specify the B input
//instantiating models (ordered as the same as the schematic)
reg_mux #(.SEL(DREG) , .RSTTYPE(RSTTYPE)) D0 (
    D , clk , CED , RSTD , D_OUT
);

reg_mux #(.SEL(B0REG) , .RSTTYPE(RSTTYPE)) B0 (
    B_in , clk , CEB , RSTB , B_OUT
);

reg_mux #(.SEL(A0REG) , .RSTTYPE(RSTTYPE)) A0 (
    A , clk , CEA , RSTA , A_OUT
);

reg_mux #(.SEL(CREG), .WIDTH(48) , .RSTTYPE(RSTTYPE)) C0 (    //changed the width to be 48 bits as the default is 18 bits
    C , clk , CEC , RSTC , C_OUT
);

reg_mux #(.SEL(OPMODEREG), .WIDTH(8) , .RSTTYPE(RSTTYPE)) opmode (    //changed the width to be 8 bits as the default is 18 bits
    OPMODE , clk , CEOPMODE , RSTOPMODE , OPMODE_OUT
);

//pre_adder/subtractor implementation
assign pre_out = (OPMODE_OUT[6]) ? D_OUT-B_OUT : D_OUT+B_OUT ; 
assign mux_opmode4_out = (OPMODE_OUT[4]) ? pre_out : B_OUT ;

//implementing the multiplier and it's inputs
reg_mux #(.SEL(B1REG) , .RSTTYPE(RSTTYPE)) B1 (
    mux_opmode4_out , clk , CEB , RSTB , BCOUT
);
reg_mux #(.SEL(A1REG) , .RSTTYPE(RSTTYPE)) A1 (
    A_OUT , clk , CEA , RSTA , ACOUT
);
assign multiplier_out = BCOUT*ACOUT ;
reg_mux #(.SEL(MREG) , .WIDTH(36) , .RSTTYPE(RSTTYPE)) Multi (  //changed the width to be 36 bits as the default is 18 bits
    multiplier_out , clk , CEM , RSTM ,  M
);
//implementing X mux
always @(*)begin
    case(OPMODE_OUT[1:0])
        0 : X_OUT = 0;
        1 : X_OUT = {12'h000,M};  //concatenation used for zero extension
        2 : X_OUT = P ;
        3 : X_OUT = {D[11:0],ACOUT[17:0],BCOUT[17:0]};
    endcase
end
//implementing Z mux
always @(*)begin
    case(OPMODE_OUT[3:2])
        0 : Z_OUT = 0;
        1 : Z_OUT = PCIN;  //concatenation used for zero extension
        2 : Z_OUT = P;
        3 : Z_OUT = C_OUT;
    endcase
end
//CIN stage
assign carry_in_cascade_out = (CARRYINSEL == "OPMODE5") ? OPMODE_OUT[5] : CARRYIN ;
reg_mux #(.SEL(CARRYINREG) , .WIDTH(1) , .RSTTYPE(RSTTYPE)) carry_in (  //changed the width to be 1 bits as the default is 18 bits
    carry_in_cascade_out , clk , CECARRYIN , RSTCARRYIN ,  CIN
); 
//post-adder/subtracter implementation
assign {carry_out_post,post_out} = (OPMODE_OUT[7]) ? Z_OUT - (X_OUT +  CIN) : Z_OUT + (X_OUT + CIN) ;
//COUT stage
reg_mux #(.SEL(CARRYOUTREG) , .WIDTH(1) , .RSTTYPE(RSTTYPE)) carry_out (  //changed the width to be 1 bits as the default is 18 bits
    carry_out_post , clk , CECARRYIN , RSTCARRYIN ,  CARRYOUT
); 
assign CARRYOUTF = CARRYOUT; //as it's the same signal except that CARRYOUTF can be used in FPGA logic

//output stage
reg_mux #(.SEL(PREG) , .WIDTH(48) , .RSTTYPE(RSTTYPE)) OUT (  //changed the width to be 48 bits as the default is 18 bits
    post_out , clk , CEP , RSTP ,  P
);
assign PCOUT = P ; //as it's the same signal except that PCOUT is used in another DSP block
endmodule