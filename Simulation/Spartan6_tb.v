module DSP48A1_tb();
parameter A0REG = 1 , A1REG = 0 , B0REG = 1 , B1REG = 0; //here I changed the value of A0REG and B0REG to 1 , A1REG and B1REG to 0 for more simplification 
parameter CREG = 1 , DREG = 1 , MREG = 1 , PREG = 1 , CARRYINREG = 1 , CARRYOUTREG = 1 , OPMODEREG = 1 ;
parameter CARRYINSEL = "OPMODE5" , B_INPUT = "DIRECT" , RSTTYPE = "ASYNC" ;
reg [17:0] A , B , BCIN , D ;
reg [47:0] C ,PCIN;
reg [7:0] OPMODE;
reg CARRYIN , clk, CEA , CEB , CEC , CECARRYIN , CED , CEM , CEOPMODE , CEP , RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP ;
wire [17:0] BCOUT ;
wire [35:0] M ;
wire [47:0]  P , PCOUT ;
//instantiation
DSP48A1 #(A0REG , A1REG , B0REG , B1REG , CREG , DREG , MREG , PREG , CARRYINREG , CARRYOUTREG , OPMODEREG , CARRYINSEL , B_INPUT , RSTTYPE ) dut (
    A , B , BCIN , C , D , CARRYIN , PCIN , BCOUT , M , P , PCOUT , CARRYOUT , CARRYOUTF , clk , OPMODE , CEA , CEB , CEC , CECARRYIN , CED , CEM , CEOPMODE , CEP , RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP 
);
initial begin
    clk=0;
    forever #10 clk = ~clk;
end
initial begin
    //initial values(activating all resets)
    RSTA=1;
    RSTB=1;
    RSTC=1;
    RSTCARRYIN=1;
    RSTD=1;
    RSTM=1;
    RSTOPMODE=1;
    RSTP=1;
    //setting data to zero
    PCIN = 0;
    OPMODE=0;
    CARRYIN=0;
    A = 0;
    B = 0;
    BCIN = 0;
    D = 0;
    C = 0;
    //enable all clocks
    CEA = 1;
    CEB = 1;
    CEC = 1;
    CECARRYIN =1;
    CED = 1;
    CEM = 1;
    CEOPMODE = 1;
    CEP = 1;
    #20; //releasing resets
    RSTA=0;
    RSTB=0;
    RSTC=0;
    RSTCARRYIN=0;
    RSTD=0;
    RSTM=0;
    RSTOPMODE=0;
    RSTP=0;

    //the testbench will go through 7 different cases on the following method :
    //first is to freeze the opmode of the z mux to zero while checking on all other opmode values in x mux as to check on every signal of x mux alone
    //second is  to freeze the opmode of the x mux to zero while checking on all other opmode values in z mux as to check on every signal of z mux alone
    //by this mechanism we will assure that the signals are correct so we can try every combination we want on the opmode for both muxes

    //freezing the opmode for z mux to zero and change the rest of x mux opmode to test every signal alone
    //**************case 1 (opmode[1:0] = 0 , opmode[3:2] = 0)**************\\
    repeat(3) begin
        OPMODE[1:0] = 0 ;
        OPMODE[3:2] = 0 ;
        OPMODE[4] = 0; //in this case I'm expecting the first input to the multiplier to be B
        OPMODE[5] = $random;  //randomizing the rest of opmode signals
        OPMODE[6] = $random;
        OPMODE[7] = $random;
        D = $urandom_range(0,31); //data randomization
        B = $urandom_range(0,15); //put less range for b so as if it's a subtract operation it be easier detecting
        A = $urandom_range(0,31);
        BCIN = $urandom_range(0,15);
        D = $urandom_range(0,31);
        C = $urandom_range(0,31);
        CARRYIN = $random;
        PCIN = $urandom_range(0,31);
        #20;
    end

    //**************case 2 (opmode[1:0] = 1 , opmode[3:2] = 0)**************\\
    repeat(3) begin
        OPMODE[1:0] = 1 ;
        OPMODE[3:2] = 0 ;
        OPMODE[4] = 1;  //in this case I'm expecting the first input to the multiplier to be the output of the pre-adder/subtractor
        OPMODE[5] = 0;  //making the carry in to be zero in this case
        OPMODE[6] = $random;   //randomizing the rest of opmode signals
        OPMODE[7] = $random;
        D = $urandom_range(0,31); //data randomization
        B = $urandom_range(0,15); //put less range for b so as if it's a subtract operation it be easier detecting
        A = $urandom_range(0,31);
        BCIN = $urandom_range(0,15);
        D = $urandom_range(0,31);
        CARRYIN = $random;
        PCIN = $urandom_range(0,31);
        #20;
    end


    //**************case 3 (opmode[1:0] = 2 , opmode[3:2] = 0)**************\\
    repeat(3) begin
        OPMODE[1:0] = 2 ;
        OPMODE[3:2] = 0 ;
        OPMODE[4] = 1;  //in this case I'm expecting the first input to the multiplier to be the output of the pre-adder/subtractor
        OPMODE[5] = 1;  //making the carry in to be one in this case
        OPMODE[6] = 1;   //pre-adder/subtracter is on subtraction operation
        OPMODE[7] = 1;   //post-adder/subtracter is on subtraction operation
        D = $urandom_range(0,31); //data randomization
        B = $urandom_range(0,15); //put less range for b so as if it's a subtract operation it be easier detecting
        A = $urandom_range(0,31);
        BCIN = $urandom_range(0,15);
        D = $urandom_range(0,31);
        CARRYIN = $random;
        PCIN = $urandom_range(0,31);
        #20;
    end


    //**************case 4 (opmode[1:0] = 3 , opmode[3:2] = 0)**************\\
    repeat(3) begin
        OPMODE[1:0] = 3 ;
        OPMODE[3:2] = 0 ;
        OPMODE[4] = 1;  //in this case I'm expecting the first input to the multiplier to be the output of the pre-adder/subtractor
        OPMODE[5] = 1;  //making the carry in to be one in this case
        OPMODE[6] = 0;   //pre-adder/subtracter is on addition operation
        OPMODE[7] = 0;   //post-adder/subtracter is on addition operation
        D = $urandom_range(0,31); //data randomization
        B = $urandom_range(0,15); //put less range for b so as if it's a subtract operation it be easier detecting
        A = $urandom_range(0,31);
        BCIN = $urandom_range(0,15);
        D = $urandom_range(0,31);
        CARRYIN = $random;
        PCIN = $urandom_range(0,31);
        #20;
    end

    //now freezing the opmode for x mux to zero and change the rest of z mux opmode to test every signal alone

    //**************case 5 (opmode[1:0] = 0 , opmode[3:2] = 1)**************\\
    repeat(3) begin
        OPMODE[1:0] = 0 ;
        OPMODE[3:2] = 1 ;
        OPMODE[4] = 1;  //in this case I'm expecting the first input to the multiplier to be the output of the pre-adder/subtractor
        OPMODE[5] = 0;  //making the carry in to be zero in this case
        OPMODE[6] = 0;   //pre-adder/subtracter is on addition operation
        OPMODE[7] = 0;   //post-adder/subtracter is on addition operation
        D = $urandom_range(0,31); //data randomization
        B = $urandom_range(0,15); //put less range for b so as if it's a subtract operation it be easier detecting
        A = $urandom_range(0,31);
        BCIN = $urandom_range(0,15);
        D = $urandom_range(0,31);
        CARRYIN = $random;
        PCIN = $urandom_range(0,31);
        #20;
    end


    //**************case 6 (opmode[1:0] = 0 , opmode[3:2] = 2)**************\\
    repeat(3) begin
        OPMODE[1:0] = 0 ;
        OPMODE[3:2] = 2 ;
        OPMODE[4] = 0;  //in this case I'm expecting the first input to the multiplier to be the output of the B input reg
        OPMODE[5] = 0;  //making the carry in to be zero in this case
        OPMODE[6] = 0;   //pre-adder/subtracter is on addition operation
        OPMODE[7] = 0;   //post-adder/subtracter is on addition operation
        D = $urandom_range(0,31); //data randomization
        B = $urandom_range(0,15); //put less range for b so as if it's a subtract operation it be easier detecting
        A = $urandom_range(0,31);
        BCIN = $urandom_range(0,15);
        D = $urandom_range(0,31);
        CARRYIN = $random;
        PCIN = $urandom_range(0,31);
        #20;
    end


    //**************case 7 (opmode[1:0] = 0 , opmode[3:2] = 3)**************\\
    repeat(3) begin
        OPMODE[1:0] = 0 ;
        OPMODE[3:2] = 3 ;
        OPMODE[4] = 0;  //in this case I'm expecting the first input to the multiplier to be the output of the B input reg
        OPMODE[5] = 0;  //making the carry in to be zero in this case
        OPMODE[6] = 0;   //pre-adder/subtracter is on addition operation
        OPMODE[7] = 0;   //post-adder/subtracter is on addition operation
        D = $urandom_range(0,31); //data randomization
        B = $urandom_range(0,15); //put less range for b so as if it's a subtract operation it be easier detecting
        A = $urandom_range(0,31);
        BCIN = $urandom_range(0,15);
        D = $urandom_range(0,31);
        CARRYIN = $random;
        PCIN = $urandom_range(0,31);
        #20;
    end
    #40;
    $stop;

end
endmodule