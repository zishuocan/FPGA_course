  
module  seg_data(
    input              clk_50m  ,//时钟输入
    input              rst_n    ,//复位输入
    input              data_vld ,//接收数据有效
    input       [7:0]  data     ,//接收数据
    output reg  [3:0]  sel      ,//位选
    output reg  [7:0]  seg       //段选
);
//参数定义
parameter   CNT1_MAX = 25'd25_000_000 ,//0.5s
            CNT2_MAX = 25'd50_000     ;//0.5s
localparam  char_A = 8'b0100_0001 ,
            char_B = 8'b0100_0010 ,
            char_C = 8'b0100_0011 ,
            char_D = 8'b0100_0100 ,
            char_E = 8'b0100_0101 ,
            char_F = 8'b0100_0110 ,
            char_G = 8'b0100_0111 ,
            char_H = 8'b0100_1000 ,
            char_I = 8'b0100_1001 ,
            char_J = 8'b0100_1010 ,
            char_K = 8'b0100_1011 ,
            char_L = 8'b0100_1100 ,
            char_M = 8'b0100_1101 ,
            char_N = 8'b0100_1110 ,
            char_O = 8'b0100_1111 ,
            char_P = 8'b0101_0000 ,
            char_Q = 8'b0101_0001 ,
            char_R = 8'b0101_0010 ,
            char_S = 8'b0101_0011 ,
            char_T = 8'b0101_0100 ,
            char_U = 8'b0101_0101 ,
            char_V = 8'b0101_0110 ,
            char_W = 8'b0101_0111 ,
            char_X = 8'b0101_1000 ,
            char_Y = 8'b0101_1001 ,
            char_Z = 8'b0101_1010 ,
            char_a = 8'b0110_0001 ,
            char_b = 8'b0110_0010 ,
            char_c = 8'b0110_0011 ,
            char_d = 8'b0110_0100 ,
            char_e = 8'b0110_0101 ,
            char_f = 8'b0110_0110 ,
            char_g = 8'b0110_0111 ,
            char_h = 8'b0110_1000 ,
            char_i = 8'b0110_1001 ,
            char_j = 8'b0110_1010 ,
            char_k = 8'b0110_1011 ,
            char_l = 8'b0110_1100 ,
            char_m = 8'b0110_1101 ,
            char_n = 8'b0110_1110 ,
            char_o = 8'b0110_1111 ,
            char_p = 8'b0111_0000 ,
            char_q = 8'b0111_0001 ,
            char_r = 8'b0111_0010 ,
            char_s = 8'b0111_0011 ,
            char_t = 8'b0111_0100 ,
            char_u = 8'b0111_0101 ,
            char_v = 8'b0111_0110 ,
            char_w = 8'b0111_0111 ,
            char_x = 8'b0111_1000 ,
            char_y = 8'b0111_1001 ,
            char_z = 8'b0111_1010 ;
//信号定义
reg  [7:0]    seg_r      ;//存放显示码
reg           data_vld_r ;//打拍
reg  [31:0]   data_r     ;//寄存接收的数据
reg  [24:0]   cnt        ;
wire          add_cnt    ;//计数器使能
wire          end_cnt    ;//计数器结束
reg  [9:0]    cnt_d      ;//辅助计数器

/*--------------------------------------显示数据寄存-------------------------------------*/
    //seg_r
    always@(*)begin
        case(data)
            "0"    : begin seg_r = {1'b0,7'b100_0000}  ; end
            "1"    : begin seg_r = {1'b0,7'b111_1001}  ; end
            "2"    : begin seg_r = {1'b0,7'b010_0100}  ; end
            "3"    : begin seg_r = {1'b0,7'b011_0000}  ; end
            "4"    : begin seg_r = {1'b0,7'b001_1001}  ; end
            "5"    : begin seg_r = {1'b0,7'b001_0010}  ; end
            "6"    : begin seg_r = {1'b0,7'b000_0010}  ; end
            "7"    : begin seg_r = {1'b0,7'b111_1000}  ; end
            "8"    : begin seg_r = {1'b0,7'b000_0000}  ; end
            "9"    : begin seg_r = {1'b0,7'b001_0000}  ; end   
            char_A : begin seg_r = {1'b1,7'b000_1000}  ; end
            char_B : begin seg_r = {1'b1,7'b000_0011}  ; end
            char_C : begin seg_r = {1'b1,7'b100_0110}  ; end
            char_D : begin seg_r = {1'b1,7'b010_0001}  ; end
            char_E : begin seg_r = {1'b1,7'b000_0110}  ; end
            char_F : begin seg_r = {1'b1,7'b000_1110}  ; end
            char_G : begin seg_r = {1'b1,7'b100_0010}  ; end
            char_H : begin seg_r = {1'b1,7'b000_1001}  ; end
            char_I : begin seg_r = {1'b1,7'b111_0000}  ; end
            char_J : begin seg_r = {1'b1,7'b111_0001}  ; end
            char_K : begin seg_r = {1'b1,7'b000_1010}  ; end
            char_L : begin seg_r = {1'b1,7'b100_0111}  ; end
            char_M : begin seg_r = {1'b1,7'b100_1000}  ; end
            char_N : begin seg_r = {1'b1,7'b010_1011}  ; end
            char_O : begin seg_r = {1'b1,7'b010_0011}  ; end
            char_P : begin seg_r = {1'b1,7'b000_1100}  ; end
            char_Q : begin seg_r = {1'b1,7'b001_1000}  ; end
            char_R : begin seg_r = {1'b1,7'b100_1110}  ; end
            char_S : begin seg_r = {1'b1,7'b001_0010}  ; end
            char_T : begin seg_r = {1'b1,7'b000_0111}  ; end
            char_U : begin seg_r = {1'b1,7'b100_0001}  ; end
            char_V : begin seg_r = {1'b1,7'b110_0011}  ; end
            char_W : begin seg_r = {1'b1,7'b000_0001}  ; end
            char_X : begin seg_r = {1'b1,7'b001_1011}  ; end
            char_Y : begin seg_r = {1'b1,7'b001_0001}  ; end
            char_Z : begin seg_r = {1'b1,7'b010_0101}  ; end
            char_a : begin seg_r = {1'b1,7'b000_1000}  ; end
            char_b : begin seg_r = {1'b1,7'b000_0011}  ; end
            char_c : begin seg_r = {1'b1,7'b100_0110}  ; end
            char_d : begin seg_r = {1'b1,7'b010_0001}  ; end
            char_e : begin seg_r = {1'b1,7'b000_0110}  ; end
            char_f : begin seg_r = {1'b1,7'b000_1110}  ; end
            char_g : begin seg_r = {1'b1,7'b100_0010}  ; end
            char_h : begin seg_r = {1'b1,7'b000_1001}  ; end
            char_i : begin seg_r = {1'b1,7'b111_0000}  ; end
            char_j : begin seg_r = {1'b1,7'b111_0001}  ; end
            char_k : begin seg_r = {1'b1,7'b000_1010}  ; end
            char_l : begin seg_r = {1'b1,7'b100_0111}  ; end
            char_m : begin seg_r = {1'b1,7'b100_1000}  ; end
            char_n : begin seg_r = {1'b1,7'b010_1011}  ; end
            char_o : begin seg_r = {1'b1,7'b010_0011}  ; end
            char_p : begin seg_r = {1'b1,7'b000_1100}  ; end
            char_q : begin seg_r = {1'b1,7'b001_1000}  ; end
            char_r : begin seg_r = {1'b1,7'b100_1110}  ; end
            char_s : begin seg_r = {1'b1,7'b001_0010}  ; end
            char_t : begin seg_r = {1'b1,7'b000_0111}  ; end
            char_u : begin seg_r = {1'b1,7'b100_0001}  ; end
            char_v : begin seg_r = {1'b1,7'b110_0011}  ; end
            char_w : begin seg_r = {1'b1,7'b000_0001}  ; end
            char_x : begin seg_r = {1'b1,7'b001_1011}  ; end
            char_y : begin seg_r = {1'b1,7'b001_0001}  ; end
            char_z : begin seg_r = {1'b1,7'b010_0101}  ; end
            default : begin seg_r = {1'b1,7'b111_1111} ; end
        endcase
    end
    //data_vld_r
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            data_vld_r <= 1'b0;
        end
        else begin
            data_vld_r <= data_vld;
        end
    end
    //data_r  显示码
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            data_r <= 32'b0;
            cnt_d  <= 10'b0; 
        end
        else if(data_vld_r)begin
            data_r <= {data_r[23:0],seg_r};
            cnt_d  <= cnt_d + 1'b1;
        end
    end
/*-----------------------------------------显示-----------------------------------------*/
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
    assign add_cnt = 1'b1 ;
    assign end_cnt = add_cnt && (cnt == CNT2_MAX - 1'b1) ;
    //sel
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            sel <= 4'b1110;
        end
        else if(end_cnt)begin
            sel <= {sel[2:0],sel[3]};
        end
    end
    //seg
    always@(*)begin
        if(cnt_d>=4)begin
            case(sel)
                4'b1110:seg = data_r[7:0  ];
                4'b1101:seg = data_r[15:8 ];
                4'b1011:seg = data_r[23:16];
                4'b0111:seg = data_r[31:24];
            endcase
        end
        else if(cnt_d==3)begin
            case(sel)
                4'b1110:seg = data_r[7:0  ];
                4'b1101:seg = data_r[15:8 ];
                4'b1011:seg = data_r[23:16];
                4'b0111:seg = 8'b1111_1111 ;
            endcase
        end
        else if(cnt_d==2)begin
            case(sel)
                4'b1110:seg = data_r[7:0]  ;
                4'b1101:seg = data_r[15:8] ;
                4'b1011:seg = 8'b1111_1111 ;
                4'b0111:seg = 8'b1111_1111 ;
            endcase
        end
        else if(cnt_d==1)begin
            case(sel)
                4'b1110:seg = data_r[7:0]  ;
                4'b1101:seg = 8'b1111_1111 ;
                4'b1011:seg = 8'b1111_1111 ;
                4'b0111:seg = 8'b1111_1111 ;
            endcase
        end
        else if(cnt_d==0)begin
            case(sel)
                4'b1110:seg = 8'b1111_1111 ;
                4'b1101:seg = 8'b1111_1111 ;
                4'b1011:seg = 8'b1111_1111 ;
                4'b0111:seg = 8'b1111_1111 ;
            endcase
        end
    end

endmodule

