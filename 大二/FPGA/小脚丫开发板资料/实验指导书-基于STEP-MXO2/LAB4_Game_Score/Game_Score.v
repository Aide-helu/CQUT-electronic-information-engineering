// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Game_Score
// 
// Author: Step
// 
// Description: Score for game
// 
// Web: www.stepfpga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module Game_Score
(
input					clk,		//ϵͳʱ�� 12MHz
input					rst_n,		//ϵͳ��λ ����Ч
input					key_red,	//��ӵ÷ְ�ť����K3
input					key_blue,	//���ӵ÷ְ�ť����K4
output					seg_rck,	//74HC595��RCK�ܽ�
output					seg_sck,	//74HC595��SCK�ܽ�
output					seg_din		//74HC595��SER�ܽ�
);

wire			[1:0]	key_jit,key_pulse,key_state;
//key debounce module
Debounce #
(
.KEY_WIDTH				(2'd2			)
)
u1
(
.clk					(clk			),	//ϵͳʱ�� 12MHz
.rst_n					(rst_n			),	//ϵͳ��λ ����Ч
.key_n					({key_red,key_blue}),	//�����ź�����
.key_jit				(key_jit		),	//��ʱ�������
.key_pulse				(key_pulse		),	//�����������
.key_state				(key_state		)	//������ת���
);

wire	[11:0]	red_seg;
//count for key_pulse
Counter u2
(
.key_in					(key_jit[1]		),	//�ӷְ���
.rst_n					(rst_n			),	//ϵͳ��λ ����Ч
.score_data				(red_seg		)	//��ֵ ���999��
);

wire	[11:0]	blue_seg;
//count for key_pulse
Counter u3
(
.key_in					(key_jit[0]		),	//�ӷְ���
.rst_n					(rst_n			),	//ϵͳ��λ ����Ч
.score_data				(blue_seg		)	//��ֵ ���999��
);

wire	[7:0]	dat_en;		//��������ܵ���
assign	dat_en[7] = 1'b0;
assign	dat_en[6] = red_seg[11:8]? 1'b1:1'b0;
assign	dat_en[5] = red_seg[11:4]? 1'b1:1'b0;
assign	dat_en[4] = 1'b1;

assign	dat_en[3] = 1'b0;
assign	dat_en[2] = blue_seg[11:8]? 1'b1:1'b0;
assign	dat_en[1] = blue_seg[11:4]? 1'b1:1'b0;
assign	dat_en[0] = 1'b1;

//segment_scan display module
Segment_scan u4
(
.clk					(clk			),	//ϵͳʱ�� 12MHz
.rst_n					(rst_n			),	//ϵͳ��λ ����Ч
.dat_1					(4'd0			),	//SEG1 ��ʾ����������
.dat_2					(red_seg[11:8]	),	//SEG2 ��ʾ����������
.dat_3					(red_seg[7:4]	),	//SEG3 ��ʾ����������
.dat_4					(red_seg[3:0]	),	//SEG4 ��ʾ����������
.dat_5					(4'd0			),	//SEG5 ��ʾ����������
.dat_6					(blue_seg[11:8]	),	//SEG6 ��ʾ����������
.dat_7					(blue_seg[7:4]	),	//SEG7 ��ʾ����������
.dat_8					(blue_seg[3:0]	),	//SEG8 ��ʾ����������
.dat_en					(dat_en			),	//���������λ��ʾʹ�ܣ�[MSB~LSB]=[SEG1~SEG8]
.dot_en					(8'b0001_0001	),	//�����С����λ��ʾʹ�ܣ�[MSB~LSB]=[SEG1~SEG8]
.seg_rck				(seg_rck		),	//74HC595��RCK�ܽ�
.seg_sck				(seg_sck		),	//74HC595��SCK�ܽ�
.seg_din				(seg_din		)	//74HC595��SER�ܽ�
);

endmodule
