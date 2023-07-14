// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module:Digtal_Calender 
// 
// Author: Step
// 
// Description: Digital clock with RTC DS1340Z
// 
// Web: www.stepfpga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2015/11/11   |Initial ver
// --------------------------------------------------------------------
module Digtal_Calender
(
input				clk,		//ϵͳʱ��
input				rst_n,		//ϵͳ��λ������Ч

input				key_a,		//��ת������A�ܽ�
input				key_b,		//��ת������B�ܽ�
input				key_o,		//��ת������D�ܽ�

output				i2c_scl,	//I2C����SCL
inout				i2c_sda,	//I2C����SDA

output				seg_rck,	//74HC595��RCK�ܽ�
output				seg_sck,	//74HC595��SCK�ܽ�
output				seg_din		//74HC595��SER�ܽ�
);

wire L_pulse,R_pulse;
Encoder u1
(
.clk				(clk		),	//ϵͳʱ�� 12MHz
.rst_n				(rst_n		),	//ϵͳ��λ ����Ч
.key_a				(key_a		),	//��ת������EC11��A��
.key_b				(key_b		),	//��ת������EC11��B��
.L_pulse			(L_pulse	),	//�����������
.R_pulse			(R_pulse	)	//�����������
);

wire O_jit,O_pulse,O_state;
//key debounce module
Debounce u2
(
.clk				(clk		),	//ϵͳʱ�� 12MHz
.rst_n				(rst_n		),	//ϵͳ��λ ����Ч
.key_n				(key_o		),	//�����ź�����
.key_jit			(O_jit		),	//��ʱ�������
.key_pulse			(O_pulse	),	//�����������
.key_state			(O_state	)	//������ת���
);

wire [2:0] state;
wire [3:0] disp_en;
wire [7:0] adj_sec,adj_min,adj_hour,adj_week,adj_day,adj_mon,adj_year;
wire [7:0] rtc_sec,rtc_min,rtc_hour,rtc_week,rtc_day,rtc_mon,rtc_year;
mode_ctrl u3
(
.clk				(clk		),		//ϵͳʱ��
.rst_n				(rst_n		),		//ϵͳ��λ������Ч
.L_pulse			(L_pulse	),		//����ת��������
.R_pulse			(R_pulse	),		//����ת��������
.O_pulse			(O_pulse	),		//������������
		
.rtc_sec			(rtc_sec	),		//ʵʱ��������
.rtc_min			(rtc_min	),		//ʵʱ��������
.rtc_hour			(rtc_hour	),		//ʵʱʱ������
.rtc_week			(rtc_week	),		//ʵʱ��������
.rtc_day			(rtc_day	),		//ʵʱ��������
.rtc_mon			(rtc_mon	),		//ʵʱ�·�����
.rtc_year			(rtc_year	),		//ʵʱ�������
		
.state				(state		),		//����״̬���
.disp_en			(disp_en	),		//��ʾ�������
.adj_sec			(adj_sec	),		//���ӵ������
.adj_min			(adj_min	),		//���ӵ������
.adj_hour			(adj_hour	),		//ʱ�ӵ������
.adj_week			(adj_week	),		//���ڵ������
.adj_day			(adj_day	),		//���ڵ������
.adj_mon			(adj_mon	),		//�·ݵ������
.adj_year			(adj_year	)		//��ݵ������
);

DS1340Z_driver u4
(
.clk				(clk		),		//ϵͳʱ��
.rst_n				(rst_n		),		//ϵͳ��λ������Ч
.key_set			(O_pulse	),		//������������
.i2c_scl			(i2c_scl	),		//I2C����SCL
.i2c_sda			(i2c_sda	),		//I2C����SDA
		
.adj_sec			(adj_sec	),		//���ӵ�������
.adj_min			(adj_min	),      //���ӵ�������
.adj_hour			(adj_hour	),      //ʱ�ӵ�������
.adj_week			(adj_week	),      //���ڵ�������
.adj_day			(adj_day	),      //���ڵ�������
.adj_mon			(adj_mon	),      //�·ݵ�������
.adj_year			(adj_year	),      //��ݵ�������
		
.rtc_sec			(rtc_sec	),		//ʵʱ�������
.rtc_min			(rtc_min	),      //ʵʱ�������
.rtc_hour			(rtc_hour	),      //ʵʱʱ�����
.rtc_week			(rtc_week	),      //ʵʱ�������
.rtc_day			(rtc_day	),      //ʵʱ�������
.rtc_mon			(rtc_mon	),      //ʵʱ�·����
.rtc_year			(rtc_year	)       //ʵʱ������
);

wire [3:0] data_1,data_2,data_3,data_4,data_5,data_6,data_7,data_8;
wire [7:0] data_en = {{2{disp_en[3]}},{2{disp_en[2]}},{2{disp_en[1]}},{2{disp_en[0]}}};				//�����λѡ����
wire [7:0] dot_en = {1'b0,disp_en[3],1'b0,disp_en[2],1'b0,disp_en[1],1'b0,disp_en[0]};				//�����С������ʾ����
assign {data_1,data_2} = state? adj_year:rtc_year;													//��ʾ����
assign {data_3,data_4} = state? ((state>=3'd4)? adj_mon:adj_hour):((&disp_en)? rtc_mon:rtc_hour);	//��ʾ����
assign {data_5,data_6} = state? ((state>=3'd4)? adj_day:adj_min):((&disp_en)? rtc_day:rtc_min);		//��ʾ����
assign {data_7,data_8} = state? ((state>=3'd4)? adj_week:adj_sec):((&disp_en)? rtc_week:rtc_sec);	//��ʾ����

Segment_scan u5
(
.clk				(clk		),	//ϵͳʱ��
.rst_n				(rst_n		),	//ϵͳ��λ������Ч
.dat_1				(data_1		),	//SEG1 �����Ҫ��ʾ������
.dat_2				(data_2		),	//SEG2 �����Ҫ��ʾ������
.dat_3				(data_3		),	//SEG3 �����Ҫ��ʾ������
.dat_4				(data_4		),	//SEG4 �����Ҫ��ʾ������
.dat_5				(data_5		),	//SEG5 �����Ҫ��ʾ������
.dat_6				(data_6		),	//SEG6 �����Ҫ��ʾ������
.dat_7				(data_7		),	//SEG7 �����Ҫ��ʾ������
.dat_8				(data_8		),	//SEG8 �����Ҫ��ʾ������
.dat_en				(data_en	),	//��λ�����������ʾʹ�ܣ�[MSB~LSB]=[SEG8~SEG1]
.dot_en				(dot_en		),	//��λ�����С������ʾʹ�ܣ�[MSB~LSB]=[SEG8~SEG1]
.seg_rck			(seg_rck	),	//74HC595��RCK�ܽ�
.seg_sck			(seg_sck	),	//74HC595��SCK�ܽ�
.seg_din			(seg_din	)	//74HC595��SER�ܽ�
);

endmodule
