// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: LCD_RGB
// 
// Author: Step
// 
// Description: Drive TFT_RGB_LCD_1.8 to display
// 
// Web: www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.1     |2016/10/30   |Initial ver
// --------------------------------------------------------------------
module LCD_RGB #
(
parameter LCD_W = 8'd132,		//Һ�������ؿ��
parameter LCD_H = 8'd162		//Һ�������ظ߶�
)
(
input				clk,		//12MHzϵͳʱ��
input				rst_n,		//ϵͳ��λ������Ч

output	reg			ram_clk_en,	//RAMʱ��ʹ��
output	reg	[7:0]	ram_addr,	//RAM��ַ�ź�
input		[131:0]	ram_data,	//RAM�����ź�

output	reg			lcd_res,	//LCDҺ������λ
output				lcd_bl,		//LCD�������
output	reg			lcd_dc,		//LCD����ָ�����
output	reg			lcd_clk,	//LCDʱ���ź�
output	reg			lcd_din		//LCD�����ź�
);

localparam INIT_DEPTH = 16'd62; //LCD��ʼ����������ݵ�����

localparam BLACK = 16'h0000;	//��ɫ
localparam YELLOW =	16'hffe0;	//��ɫ
localparam IDLE	= 3'd0, MAIN = 3'd1, INIT = 3'd2, SCAN = 3'd3, WRITE = 3'd4, DELAY = 3'd5;
localparam LOW = 1'b0, HIGH = 1'b1;

assign	lcd_bl = HIGH;			// backlight active high level

wire [15:0] color_t	= YELLOW;	//����ɫΪ��ɫ
wire [15:0] color_b	= BLACK;	//����ɫΪ��ɫ

reg [8:0] reg_setxy [10:0];
reg [8:0] reg_init [72:0];

reg high_word;
reg [131:0]	ram_data_r;
reg [8:0] data_reg;	
reg [7:0] x_cnt, y_cnt;
reg [7:0] cnt_main, cnt_init, cnt_scan, cnt_write;
reg [15:0] num_delay, cnt_delay, cnt;
reg [2:0] state = IDLE, state_back = IDLE;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		high_word <= 1'b1;
		x_cnt <= 1'b0; y_cnt <= 1'b0;
		ram_clk_en <= 1'b0; ram_addr <= 1'b0;
		cnt_main <= 1'b0; cnt_init <= 1'b0; cnt_scan <= 1'b0; cnt_write <= 1'b0;
		num_delay <= 16'd50; cnt_delay <= 1'b0; cnt <= 1'b0;
		state <= IDLE; state_back <= IDLE;
	end else begin
		case(state)
			IDLE:begin
					high_word <= 1'b1;
					x_cnt <= 1'b0; y_cnt <= 1'b0;
					ram_clk_en <= 1'b0; ram_addr <= 1'b0;
					cnt_main <= 1'b0; cnt_init <= 1'b0; cnt_scan <= 1'b0; cnt_write <= 1'b0;
					num_delay <= 16'd50; cnt_delay <= 1'b0; cnt <= 1'b0;
					state <= MAIN; state_back <= MAIN;
				end
			MAIN:begin
					if(cnt_main >= 3'd1) cnt_main <= 1'b1;
					else cnt_main <= cnt_main + 1'b1;
					case(cnt_main)	//MAIN״̬
						3'd0:	begin state <= INIT; end
						3'd1:	begin state <= SCAN; end
						default: state <= IDLE;
					endcase
				end
			INIT:begin	//��ʼ��״̬
					if(cnt_init==3'd4) begin
						if(cnt==INIT_DEPTH) cnt_init <= 1'b0;
						else cnt_init <= cnt_init;
					end else cnt_init <= cnt_init + 1'b1;
					case(cnt_init)
						3'd0:	lcd_res <= 1'b0;	//��λ��Ч
						3'd1:	begin num_delay <= 16'd3000; state <= DELAY; state_back <= INIT; end	//��ʱ
						3'd2:	lcd_res <= 1'b1;	//��λ�ָ�
						3'd3:	begin num_delay <= 16'd3000; state <= DELAY; state_back <= INIT; end	//��ʱ
						3'd4:	if(cnt>=INIT_DEPTH) begin //��62��ָ����ݷ������������
									cnt <= 16'd0;	
									state <= MAIN;
								end else begin
									cnt <= cnt + 16'd1;
									data_reg <= reg_init[cnt];	
									if(cnt==16'd0) num_delay <= 16'd50000; //��һ��ָ����Ҫ�ϳ���ʱ
									else num_delay <= 16'd50;
									state <= WRITE; state_back <= INIT;
								end
						default: state <= IDLE;
					endcase
				end
			SCAN:begin	//ˢ��״̬����RAM�ж�ȡ����ˢ��
					case(cnt_scan)
						3'd0:	if(cnt >= 11) begin	//ȷ��ˢ�����������꣬����Ϊȫ��
									cnt <= 16'd0;
									cnt_scan <= cnt_scan + 1'b1;
								end else begin
									cnt <= cnt + 16'd1;
									data_reg <= reg_setxy[cnt];
									num_delay <= 16'd50;
									state <= WRITE; state_back <= SCAN;
								end
						3'd1:	begin ram_clk_en <= HIGH; ram_addr <= y_cnt; cnt_scan <= cnt_scan + 1'b1; end	//RAMʱ��ʹ��
						3'd2:	begin cnt_scan <= cnt_scan + 1'b1; end	//��ʱһ��ʱ��
						3'd3:	begin ram_clk_en <= LOW; ram_data_r <= ram_data; cnt_scan <= cnt_scan + 1'b1; end	//��ȡRAM���ݣ�ͬʱ�ر�RAMʱ��ʹ��
						3'd4:	begin //ÿ�����ص���Ҫ16bit�����ݣ�SPIÿ�δ�8bit�����ηֱ��͸�8λ�͵�8λ
									if(x_cnt>=LCD_W) begin	//��һ������(һ����Ļ)д���
										x_cnt <= 8'd0;	
										if(y_cnt>=LCD_H) begin y_cnt <= 8'd0; cnt_scan <= cnt_scan + 1'b1; end	//��������һ�о�����ѭ��
										else begin y_cnt <= y_cnt + 1'b1; cnt_scan <= 3'd1; end		//������ת��RAMʱ��ʹ�ܣ�ѭ��ˢ��
									end else begin
										if(high_word) data_reg <= {1'b1,(ram_data_r[x_cnt]? color_t[15:8]:color_b[15:8])};	//������Ӧbit��״̬�ж���ʾ����ɫ�򱳾�ɫ,����high_word��״̬�ж�д��8λ���8λ
										else begin data_reg <= {1'b1,(ram_data_r[x_cnt]? color_t[7:0]:color_b[7:0])}; x_cnt <= x_cnt + 1'b1; end	//������Ӧbit��״̬�ж���ʾ����ɫ�򱳾�ɫ,����high_word��״̬�ж�д��8λ���8λ��ͬʱָ����һ��bit
										high_word <= ~high_word;	//high_word��״̬��ת
										num_delay <= 16'd50;	//�趨��ʱʱ��
										state <= WRITE;	//��ת��WRITE״̬
										state_back <= SCAN;	//ִ����WRITE��DELAY�����󷵻�SCAN״̬
									end
								end
						3'd5:	begin cnt_scan <= 1'b0; state <= MAIN; end
						default: state <= IDLE;
					endcase
				end
			WRITE:begin	//WRITE״̬�������ݰ���SPIʱ���͸���Ļ
					if(cnt_write >= 6'd17) cnt_write <= 1'b0;
					else cnt_write <= cnt_write + 1'b1;
					case(cnt_write)
						6'd0:	begin lcd_dc <= data_reg[8]; end	//9λ�������λΪ�������ݿ���λ
						6'd1:	begin lcd_clk <= LOW; lcd_din <= data_reg[7]; end	//�ȷ���λ����
						6'd2:	begin lcd_clk <= HIGH; end
						6'd3:	begin lcd_clk <= LOW; lcd_din <= data_reg[6]; end
						6'd4:	begin lcd_clk <= HIGH; end
						6'd5:	begin lcd_clk <= LOW; lcd_din <= data_reg[5]; end
						6'd6:	begin lcd_clk <= HIGH; end
						6'd7:	begin lcd_clk <= LOW; lcd_din <= data_reg[4]; end
						6'd8:	begin lcd_clk <= HIGH; end
						6'd9:	begin lcd_clk <= LOW; lcd_din <= data_reg[3]; end
						6'd10:	begin lcd_clk <= HIGH; end
						6'd11:	begin lcd_clk <= LOW; lcd_din <= data_reg[2]; end
						6'd12:	begin lcd_clk <= HIGH; end
						6'd13:	begin lcd_clk <= LOW; lcd_din <= data_reg[1]; end
						6'd14:	begin lcd_clk <= HIGH; end
						6'd15:	begin lcd_clk <= LOW; lcd_din <= data_reg[0]; end	//�󷢵�λ����
						6'd16:	begin lcd_clk <= HIGH; end
						6'd17:	begin lcd_clk <= LOW; state <= DELAY; end	//
						default: state <= IDLE;
					endcase
				end
			DELAY:begin	//��ʱ״̬
					if(cnt_delay >= num_delay) begin
						cnt_delay <= 16'd0;
						state <= state_back; 
					end else cnt_delay <= cnt_delay + 1'b1;
				end
			default:state <= IDLE;
		endcase
	end
end

// data for setxy
always@(negedge rst_n)	//�趨��ʾ����ָ�����
	begin
		reg_setxy[0]	=	{1'b0,8'h2a};
		reg_setxy[1]	=	{1'b1,8'h00};
		reg_setxy[2]	=	{1'b1,8'h00};
		reg_setxy[3]	=	{1'b1,8'h00};
		reg_setxy[4]	=	{1'b1,LCD_W-1};
		reg_setxy[5]	=	{1'b0,8'h2b};
		reg_setxy[6]	=	{1'b1,8'h00};
		reg_setxy[7]	=	{1'b1,8'h00};
		reg_setxy[8]	=	{1'b1,8'h00};
		reg_setxy[9]	=	{1'b1,LCD_H-1};
		reg_setxy[10]	=	{1'b0,8'h2c};
	end

// data for init
always@(negedge rst_n)	//LCD��ʼ�����������
	begin
		reg_init[ 0]	=	{1'b0,8'h11}; 
		reg_init[ 1]	=	{1'b0,8'hb1};  //16bit color
		reg_init[ 2]	=	{1'b1,8'h05}; 
		reg_init[ 3]	=	{1'b1,8'h3c}; 
		reg_init[ 4]	=	{1'b1,8'h3c};   
		reg_init[ 5]	=	{1'b0,8'hb4}; 
		reg_init[ 6]	=	{1'b1,8'h03}; 
		reg_init[ 7]	=	{1'b0,8'hc0}; 
		reg_init[ 8]	=	{1'b1,8'h28}; 
		reg_init[ 9]	=	{1'b1,8'h08}; 
		reg_init[10]	=	{1'b1,8'h04}; 
		reg_init[11]	=	{1'b0,8'hc1}; 
		reg_init[12]	=	{1'b1,8'hc0}; 
		reg_init[13]	=	{1'b0,8'hc2}; 
		reg_init[14]	=	{1'b1,8'h0d}; 
		reg_init[15]	=	{1'b1,8'h00}; 
		reg_init[16]	=	{1'b0,8'hc3}; 
		reg_init[17]	=	{1'b1,8'h8d}; 
		reg_init[18]	=	{1'b1,8'h2a}; 
		reg_init[19]	=	{1'b0,8'hc4}; 
		reg_init[20]	=	{1'b1,8'h8d}; 
		reg_init[21]	=	{1'b1,8'hee}; 
		reg_init[22]	=	{1'b0,8'hc5}; 
		reg_init[23]	=	{1'b1,8'h1a}; 
		reg_init[24]	=	{1'b0,8'h36}; 
		reg_init[25]	=	{1'b1,8'hc0}; 
		reg_init[26]	=	{1'b0,8'he0}; 
		reg_init[27]	=	{1'b1,8'h04}; 
		reg_init[28]	=	{1'b1,8'h22}; 
		reg_init[29]	=	{1'b1,8'h07}; 
		reg_init[30]	=	{1'b1,8'h0a}; 
		reg_init[31]	=	{1'b1,8'h2e}; 
		reg_init[32]	=	{1'b1,8'h30}; 
		reg_init[32]	=	{1'b1,8'h25}; 
		reg_init[33]	=	{1'b1,8'h2a}; 
		reg_init[34]	=	{1'b1,8'h28}; 
		reg_init[35]	=	{1'b1,8'h26}; 
		reg_init[36]	=	{1'b1,8'h2e}; 
		reg_init[37]	=	{1'b1,8'h3a}; 
		reg_init[38]	=	{1'b1,8'h00}; 
		reg_init[39]	=	{1'b1,8'h01}; 
		reg_init[40]	=	{1'b1,8'h03}; 
		reg_init[41]	=	{1'b1,8'h13}; 
		reg_init[42]	=	{1'b0,8'he1}; 
		reg_init[43]	=	{1'b1,8'h04}; 
		reg_init[44]	=	{1'b1,8'h16}; 
		reg_init[45]	=	{1'b1,8'h06}; 
		reg_init[46]	=	{1'b1,8'h0d}; 
		reg_init[47]	=	{1'b1,8'h2d}; 
		reg_init[48]	=	{1'b1,8'h26}; 
		reg_init[49]	=	{1'b1,8'h23}; 
		reg_init[50]	=	{1'b1,8'h27}; 
		reg_init[51]	=	{1'b1,8'h27}; 
		reg_init[52]	=	{1'b1,8'h25}; 
		reg_init[53]	=	{1'b1,8'h2d}; 
		reg_init[54]	=	{1'b1,8'h3b}; 
		reg_init[55]	=	{1'b1,8'h00}; 
		reg_init[56]	=	{1'b1,8'h01}; 
		reg_init[57]	=	{1'b1,8'h04}; 
		reg_init[58]	=	{1'b1,8'h13}; 
		reg_init[59]	=	{1'b0,8'h3a}; 
		reg_init[60]	=	{1'b1,8'h05}; 
		reg_init[61]	=	{1'b0,8'h29}; 
	end          
	
endmodule
