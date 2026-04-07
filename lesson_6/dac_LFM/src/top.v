/*****************************************************************
*****************************FPGA实验************************             
**软    件:GOwin云源软件                
**项    目:DAC-LFM                     
**时    钟:100MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/  
module  top(
    input        clk_50m      ,//时钟输入
    input        rst_n       ,//复位输入
    output       da_clk_100m  ,
    output [9:0] da_data     
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s


//信号定义
wire         clk_100m;
wire [9:0]   rd_addr ;
wire [9:0]   rd_data ;
wire         pll_lock_o;
wire         pll_clkoutp_o;
wire         pll_clkoutd_o;
wire         pll_clkoutd3_o;
wire         gw_gnd;

assign gw_gnd = 1'b0;


//模块例化
    rPLL rpll_inst (
        .CLKOUT(clk_100m),
        .LOCK(pll_lock_o),
        .CLKOUTP(pll_clkoutp_o),
        .CLKOUTD(pll_clkoutd_o),
        .CLKOUTD3(pll_clkoutd3_o),
        .RESET(gw_gnd),
        .RESET_P(gw_gnd),
        .CLKIN(clk_50m),
        .CLKFB(gw_gnd),
        .FBDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .IDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .ODSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .PSDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .DUTYDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .FDLY({gw_gnd,gw_gnd,gw_gnd,gw_gnd})
    );

    defparam rpll_inst.FCLKIN = "50";
    defparam rpll_inst.DYN_IDIV_SEL = "false";
    defparam rpll_inst.IDIV_SEL = 0;
    defparam rpll_inst.DYN_FBDIV_SEL = "false";
    defparam rpll_inst.FBDIV_SEL = 1;
    defparam rpll_inst.DYN_ODIV_SEL = "false";
    defparam rpll_inst.ODIV_SEL = 4;
    defparam rpll_inst.PSDA_SEL = "0000";
    defparam rpll_inst.DYN_DA_EN = "true";
    defparam rpll_inst.DUTYDA_SEL = "1000";
    defparam rpll_inst.CLKOUT_FT_DIR = 1'b1;
    defparam rpll_inst.CLKOUTP_FT_DIR = 1'b1;
    defparam rpll_inst.CLKOUT_DLY_STEP = 0;
    defparam rpll_inst.CLKOUTP_DLY_STEP = 0;
    defparam rpll_inst.CLKFB_SEL = "internal";
    defparam rpll_inst.CLKOUT_BYPASS = "false";
    defparam rpll_inst.CLKOUTP_BYPASS = "false";
    defparam rpll_inst.CLKOUTD_BYPASS = "false";
    defparam rpll_inst.DYN_SDIV_SEL = 2;
    defparam rpll_inst.CLKOUTD_SRC = "CLKOUT";
    defparam rpll_inst.CLKOUTD3_SRC = "CLKOUT";
    defparam rpll_inst.DEVICE = "GW1N-9C";

    Gowin_pROM u_Gowin_pROM(
        .dout  (rd_data    ), //output [9:0] dout
        .clk   (clk_100m   ), //input clk
        .oce   (1'b1       ), //input oce
        .ce    (1'b1       ), //input ce
        .reset (1'b0       ), //input reset
        .ad    (rd_addr    ) //input [9:0] ad
    );
    dac_LFM u_dac_LFM(
    /*input                 */.clk_100m      (clk_100m       )  ,  //系统时钟
    /*input                 */.rst_n         (rst_n         )  ,  //系统复位，低电平有效

    /*input        [9:0]    */.rd_data       (rd_data       )  ,  //ROM读出的数据
    /*output  reg  [9:0]    */.rd_addr       (rd_addr       )  ,  //读ROM地址
//DA接口
    /*output                */.da_clk_100m   (da_clk_100m   )  ,  //DA驱动时钟
    /*output       [9:0]    */.da_data       (da_data       )     //输出给DA的数据  
    );

    
endmodule

