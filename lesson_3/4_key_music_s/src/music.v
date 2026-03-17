/************************************
***********易思达FPGA实验*************     
**软    件：GOwin云源软件              
**项    目：音调产生模块                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  music(
    input              clk_50m ,//时钟输入
    input              rst_n   ,//复位输入
    input      [6:0]   key     ,
    output             start   ,
    output reg [2:0]   num1    , //7个音色
    output reg [1:0]   num2      //中高低调0：低   1：中   2：高
    );
//参数定义
parameter   CNT_MAX = 25'd20_000_000 ;//0.5s

//信号定义
reg   [24:0]  cnt      ;//0.5s
wire          add_cnt  ;//计数器使能
wire          end_cnt  ;//计数器结束
reg           key_flag ;//翻转信号
reg  [7:0]    music_cnt;

    //start
    assign start = 1'b1;
    //cnt计数器
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 1'b0 ;
        end
        else if(add_cnt)begin
            if (end_cnt)begin
                cnt <= 1'b0 ;
            end
            else begin
                cnt <= cnt + 1'b1 ;
            end
        end
    end
    assign add_cnt = start ;
    assign end_cnt = add_cnt && (cnt == CNT_MAX>>1 - 1'b1) ;
    //music_cnt
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            music_cnt <= 1'b0;
        end
        else if(music_cnt == 100 || !add_cnt || key[0])begin
            music_cnt <= 1'b0;
        end
        else if(end_cnt)begin
            music_cnt <= music_cnt + 1'b1 ;
        end
    end
    //key_cnt
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            key_flag <= 1'b0 ;
        end
        else if(key[0])begin
            key_flag <= ~key_flag;
        end
    end
    //num1  num2
    always @(*)begin
        if(key_flag)begin
            case (music_cnt)
                'd0 : begin num2 <=2 ; num1 <= 1; end
                'd1 : begin num2 <=2 ; num1 <= 2; end
                'd2 : begin num2 <=2 ; num1 <= 3; end
                'd3 : begin num2 <=2 ; num1 <= 5; end
                'd4 : begin num2 <=2 ; num1 <= 5; end
                'd5 : begin num2 <=2 ; num1 <= 5; end

                'd6 : begin num2 <=2 ; num1 <= 3; end
                'd7 : begin num2 <=2 ; num1 <= 2; end
                'd8 : begin num2 <=2 ; num1 <= 1; end
                'd9 : begin num2 <=2 ; num1 <= 2; end
                'd10: begin num2 <=2 ; num1 <= 3; end
                'd11: begin num2 <=2 ; num1 <= 3; end
                'd12: begin num2 <=2 ; num1 <= 1; end
                'd13: begin num2 <=2 ; num1 <= 2; end

                'd14: begin num2 <=2 ; num1 <= 3; end
                'd15: begin num2 <=3 ; num1 <= 1; end
                'd16: begin num2 <=3 ; num1 <= 1; end
                'd17: begin num2 <=3 ; num1 <= 1; end
                'd18: begin num2 <=2 ; num1 <= 7; end
                'd19: begin num2 <=3 ; num1 <= 1; end
                'd20: begin num2 <=3 ; num1 <= 1; end
                'd21: begin num2 <=2 ; num1 <= 7; end

                'd22: begin num2 <=3 ; num1 <= 3; end
                'd23: begin num2 <=2 ; num1 <= 5; end
                'd24: begin num2 <=2 ; num1 <= 2; end
                'd25: begin num2 <=2 ; num1 <= 2; end
                'd26: begin num2 <=2 ; num1 <= 2; end
                'd27: begin num2 <=1 ; num1 <= 5; end
                'd28: begin num2 <=1 ; num1 <= 5; end
                'd29: begin num2 <=1 ; num1 <= 5; end

                'd30: begin num2 <=0 ; num1 <= 4; end
                'd31: begin num2 <=1 ; num1 <= 1; end
                'd32: begin num2 <=1 ; num1 <= 4; end
                'd33: begin num2 <=1 ; num1 <= 1; end
                'd34: begin num2 <=0 ; num1 <= 5; end
                'd35: begin num2 <=1 ; num1 <= 2; end
                'd36: begin num2 <=1 ; num1 <= 5; end
                'd37: begin num2 <=1 ; num1 <= 2; end

                'd38: begin num2 <=0 ; num1 <= 1; end
                'd39: begin num2 <=0 ; num1 <= 5; end
                'd40: begin num2 <=1 ; num1 <= 1; end
                'd41: begin num2 <=0 ; num1 <= 5; end
                'd42: begin num2 <=1 ; num1 <= 1; end
                'd43: begin num2 <=0 ; num1 <= 5; end
                'd44: begin num2 <=1 ; num1 <= 1; end
                'd45: begin num2 <=0 ; num1 <= 5; end

                'd46: begin num2 <=0 ; num1 <= 4; end
                'd47: begin num2 <=1 ; num1 <= 1; end
                'd48: begin num2 <=1 ; num1 <= 4; end
                'd49: begin num2 <=1 ; num1 <= 1; end
                'd50: begin num2 <=0 ; num1 <= 5; end
                'd51: begin num2 <=1 ; num1 <= 2; end
                'd52: begin num2 <=1 ; num1 <= 5; end
                'd53: begin num2 <=1 ; num1 <= 2; end

                'd54: begin num2 <=2 ; num1 <= 6; end
                'd55: begin num2 <=2 ; num1 <= 5; end
                'd56: begin num2 <=2 ; num1 <= 5; end
                'd57: begin num2 <=2 ; num1 <= 1; end
                'd58: begin num2 <=2 ; num1 <= 2; end
                'd59: begin num2 <=2 ; num1 <= 3; end
                'd60: begin num2 <=2 ; num1 <= 5; end

                'd61: begin num2 <=2 ; num1 <= 5; end
                'd62: begin num2 <=2 ; num1 <= 5; end
                'd63: begin num2 <=2 ; num1 <= 3; end
                'd64: begin num2 <=2 ; num1 <= 2; end
                'd65: begin num2 <=2 ; num1 <= 1; end
                'd66: begin num2 <=2 ; num1 <= 2; end			
                'd67: begin num2 <=2 ; num1 <= 1; end
                'd68: begin num2 <=2 ; num1 <= 1; end

                'd69: begin num2 <=2 ; num1 <= 1; end
                'd70: begin num2 <=2 ; num1 <= 2; end	
                'd71: begin num2 <=2 ; num1 <= 3; end
                'd72: begin num2 <=2 ; num1 <= 5; end
                'd73: begin num2 <=2 ; num1 <= 1; end
                'd74: begin num2 <=2 ; num1 <= 1; end
                'd75: begin num2 <=2 ; num1 <= 1; end
                'd76: begin num2 <=2 ; num1 <= 1; end

                'd77: begin num2 <=1 ; num1 <= 7; end
                'd78: begin num2 <=1 ; num1 <= 6; end
                'd79: begin num2 <=1 ; num1 <= 7; end
                'd80: begin num2 <=0 ; num1 <= 1; end				
                'd81: begin num2 <=0 ; num1 <= 5; end
                'd82: begin num2 <=1 ; num1 <= 1; end
                'd83: begin num2 <=0 ; num1 <= 5; end
                'd84: begin num2 <=0 ; num1 <= 6; end

                'd85: begin num2 <=0 ; num1 <= 5; end
                'd86: begin num2 <=1 ; num1 <= 1; end
                'd87: begin num2 <=0 ; num1 <= 5; end
                'd88: begin num2 <=0 ; num1 <= 4; end
                'd89: begin num2 <=1 ; num1 <= 1; end
                'd90: begin num2 <=1 ; num1 <= 4; end
                'd91: begin num2 <=1 ; num1 <= 1; end
                'd92: begin num2 <=0 ; num1 <= 3; end

                'd93: begin num2 <=0 ; num1 <= 7; end
                'd94: begin num2 <=1 ; num1 <= 3; end
                'd95: begin num2 <=0 ; num1 <= 7; end
                'd96: begin num2 <=0 ; num1 <= 6; end
                'd97: begin num2 <=0 ; num1 <= 3; end
                'd98: begin num2 <=0 ; num1 <= 6; end
                'd99: begin num2 <=0 ; num1 <= 3; end
                'd100: begin num2 <=0 ; num1 <= 2; end
                default :  begin num2 <=0 ; num1 <= 0; end	
            endcase
        end
        else begin
            case (music_cnt)
                'd0 : begin num2 <=3 ; num1 <= 0; end
                'd1 : begin num2 <=0 ; num1 <= 3; end
                'd2 : begin num2 <=0 ; num1 <= 3; end
                'd3 : begin num2 <=0 ; num1 <= 3; end
                'd4 : begin num2 <=0 ; num1 <= 3; end
                'd5 : begin num2 <=0 ; num1 <= 5; end
                'd6 : begin num2 <=0 ; num1 <= 5; end
                'd7 : begin num2 <=0 ; num1 <= 5; end
                'd8 : begin num2 <=0 ; num1 <= 6; end
                'd9 : begin num2 <=1 ; num1 <= 1; end
                'd10: begin num2 <=1 ; num1 <= 1; end
                'd11: begin num2 <=1 ; num1 <= 1; end
                'd12: begin num2 <=1 ; num1 <= 2; end
                'd13: begin num2 <=0 ; num1 <= 6; end
                'd14: begin num2 <=1 ; num1 <= 1; end
                'd15: begin num2 <=0 ; num1 <= 5; end
                'd16: begin num2 <=1 ; num1 <= 5; end
                'd17: begin num2 <=1 ; num1 <= 5; end
                'd18: begin num2 <=1 ; num1 <= 5; end
                'd19: begin num2 <=2 ; num1 <= 1; end
                'd20: begin num2 <=1 ; num1 <= 6; end
                'd21: begin num2 <=1 ; num1 <= 5; end
                'd22: begin num2 <=1 ; num1 <= 3; end
                'd23: begin num2 <=1 ; num1 <= 5; end
                'd24: begin num2 <=1 ; num1 <= 2; end
                'd25: begin num2 <=1 ; num1 <= 2; end
                'd26: begin num2 <=1 ; num1 <= 2; end
                'd27: begin num2 <=1 ; num1 <= 2; end
                'd28: begin num2 <=1 ; num1 <= 2; end
                'd29: begin num2 <=1 ; num1 <= 2; end
                'd30: begin num2 <=1 ; num1 <= 2; end
                'd31: begin num2 <=1 ; num1 <= 2; end
                'd32: begin num2 <=1 ; num1 <= 2; end
                'd33: begin num2 <=1 ; num1 <= 2; end
                'd34: begin num2 <=1 ; num1 <= 2; end
                'd35: begin num2 <=1 ; num1 <= 2; end
                'd36: begin num2 <=1 ; num1 <= 3; end
                'd37: begin num2 <=0 ; num1 <= 7; end
                'd38: begin num2 <=0 ; num1 <= 6; end
                'd39: begin num2 <=0 ; num1 <= 5; end
                'd40: begin num2 <=0 ; num1 <= 5; end
                'd41: begin num2 <=0 ; num1 <= 6; end
                'd42: begin num2 <=1 ; num1 <= 1; end
                'd43: begin num2 <=1 ; num1 <= 1; end
                'd44: begin num2 <=1 ; num1 <= 2; end
                'd45: begin num2 <=1 ; num1 <= 2; end
                'd46: begin num2 <=0 ; num1 <= 3; end
                'd47: begin num2 <=0 ; num1 <= 3; end
                'd48: begin num2 <=1 ; num1 <= 1; end
                'd49: begin num2 <=1 ; num1 <= 1; end
                'd50: begin num2 <=0 ; num1 <= 6; end
                'd51: begin num2 <=0 ; num1 <= 5; end
                'd52: begin num2 <=0 ; num1 <= 6; end
                'd53: begin num2 <=1 ; num1 <= 1; end
                'd54: begin num2 <=0 ; num1 <= 5; end
                'd55: begin num2 <=2 ; num1 <= 1; end
                'd56: begin num2 <=1 ; num1 <= 5; end
                'd57: begin num2 <=0 ; num1 <= 5; end
                'd58: begin num2 <=0 ; num1 <= 5; end
                'd59: begin num2 <=0 ; num1 <= 5; end
                'd60: begin num2 <=0 ; num1 <= 5; end
                'd61: begin num2 <=0 ; num1 <= 5; end
                'd62: begin num2 <=0 ; num1 <= 5; end
                'd63: begin num2 <=0 ; num1 <= 5; end
                'd64: begin num2 <=0 ; num1 <= 5; end
                'd65: begin num2 <=0 ; num1 <= 5; end
                'd66: begin num2 <=0 ; num1 <= 5; end			
                'd67: begin num2 <=0 ; num1 <= 5; end
                'd68: begin num2 <=1 ; num1 <= 3; end
                'd69: begin num2 <=1 ; num1 <= 3; end
                'd70: begin num2 <=1 ; num1 <= 3; end	
                'd71: begin num2 <=1 ; num1 <= 3; end
                'd72: begin num2 <=0 ; num1 <= 5; end
                'd73: begin num2 <=0 ; num1 <= 7; end
                'd74: begin num2 <=0 ; num1 <= 7; end
                'd75: begin num2 <=1 ; num1 <= 2; end
                'd76: begin num2 <=1 ; num1 <= 2; end
                'd77: begin num2 <=0 ; num1 <= 6; end
                'd78: begin num2 <=1 ; num1 <= 1; end
                'd79: begin num2 <=0 ; num1 <= 5; end
                'd80: begin num2 <=0 ; num1 <= 5; end				
                'd81: begin num2 <=0 ; num1 <= 5; end
                'd82: begin num2 <=0 ; num1 <= 5; end
                'd83: begin num2 <=0 ; num1 <= 5; end
                'd84: begin num2 <=0 ; num1 <= 5; end
                'd85: begin num2 <=1 ; num1 <= 5; end
                'd86: begin num2 <=1 ; num1 <= 5; end
                'd87: begin num2 <=0 ; num1 <= 6; end
                'd88: begin num2 <=1 ; num1 <= 1; end
                'd89: begin num2 <=0 ; num1 <= 5; end
                'd90: begin num2 <=0 ; num1 <= 5; end
                'd91: begin num2 <=0 ; num1 <= 5; end	
                default :  begin num2 <=3 ; num1 <= 0; end	
            endcase
        end
    end

endmodule

