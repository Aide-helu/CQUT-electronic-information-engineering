// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Signal_Generator
// 
// Author: Step
// 
// Description: Signal_Generator
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module Signal_Generator
(
input				clk,		//ϵͳʱ��
input				rst_n,  	//ϵͳ��λ������Ч

input				key_a,		//��ת������EC11��A�� 
input				key_b,		//��ת������EC11��B�� 
input				key_o,		//��ת������EC11��D��

output				dac_sync,	//SPI����CS
output				dac_clk,	//SPI����SCLK
output				dac_dat		//SPI����MOSI
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

wire key_jit,key_pulse,key_state;
//key debounce module
Debounce u2
(
.clk				(clk		),	//ϵͳʱ�� 12MHz
.rst_n				(rst_n		),	//ϵͳ��λ ����Ч
.key_n				(key_o		),	//�����ź�����
.key_jit			(key_jit	),	//��ʱ�������
.key_pulse			(key_pulse	),	//�����������
.key_state			(key_state	)	//������ת���
);

wire [1:0] wave;
wire [23:0] f_inc;
logic_ctrl u3
(
.clk				(clk		),	//12MHzϵͳʱ��
.rst_n				(rst_n		),	//ϵͳ��λ������Ч
.L_pulse			(L_pulse	),	//��������������
.R_pulse			(R_pulse	),	//��������������
.O_pulse			(key_pulse	),	//��������������
.wave				(wave		),	//�������
.f_inc				(f_inc		)	//Ƶ�ʿ�����
);

wire dac_done,sps_clk;
wire [7:0] sps_dat;
DDS u4
(
.clk				(dac_done	),	//
.rst_n				(rst_n		),	//
.wave				(wave		),	//
.f_inc				(f_inc		),	//
.p_inc				(1'b0		),	//
.dac_clk			(sps_clk	),	//
.dac_dat			(sps_dat	)	//
);

DAC081S101_driver u5
(
.clk				(clk		),	//ϵͳʱ��
.rst_n				(rst_n		),  //ϵͳ��λ������Ч
.dac_done			(dac_done	),	//DAC������ɱ�־
.dac_data			(sps_dat	),	//DAC��������
.dac_sync			(dac_sync	),	//SPI����CS
.dac_clk			(dac_clk	),	//SPI����SCLK
.dac_dat			(dac_dat	)	//SPI����MOSI
);

endmodule
