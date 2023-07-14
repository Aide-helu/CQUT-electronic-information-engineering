// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Digital_THM
// 
// Author: Step
// 
// Description: Digital_THM
// 
// Web: www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.1     |2016/10/30   |Initial ver
// --------------------------------------------------------------------
module Digital_THM
(
input			clk,
input			rst_n,

output			i2c_scl,	//I2Cʱ������
inout			i2c_sda,	//I2C��������

output			seg_rck,	//74HC595��RCK�ܽ�
output			seg_sck,	//74HC595��SCK�ܽ�
output			seg_din		//74HC595��SER�ܽ�
);

wire [15:0] T_code,H_code;
SHT20_Driver u1
(
.clk			(clk			),	//ϵͳʱ��
.rst_n			(rst_n			),	//ϵͳ��λ������Ч

.i2c_scl		(i2c_scl		),	//I2C����SCL
.i2c_sda		(i2c_sda		),	//I2C����SDA

.T_code			(T_code			),	//�¶���ֵ
.H_code			(H_code			)	//ʪ����ֵ
);

wire [ 7: 0] dat_en, dot_en;
wire [15: 0] T_data, H_data;
Calculate u2
(
.rst_n			(rst_n			),	//ϵͳ��λ������Ч

.T_code			(T_code			),	//�¶���ֵ
.H_code			(H_code			),	//ʪ����ֵ

.T_data			(T_data			),	//�¶�BCD��
.H_data			(H_data			),	//ʪ��BCD��

.dat_en			(dat_en			),	//������ʾʹ��
.dot_en			(dot_en			)	//С������ʾʹ��
);


Segment_scan u3
(
.clk			(clk			),	//ϵͳʱ��
.rst_n			(rst_n			),	//ϵͳ��λ������Ч
.dat_1			(T_data[15:12]	),	//SEG1 ��ʾ�¶Ȱ�λ
.dat_2			(T_data[11: 8]	),	//SEG2 ��ʾ�¶�ʮλ
.dat_3			(T_data[ 7: 4]	),	//SEG3 ��ʾ�¶ȸ�λ
.dat_4			(T_data[ 3: 0]	),	//SEG4 ��ʾ�¶�С��λ
.dat_5			(H_data[15:12]	),	//SEG5 ��ʾʪ�Ȱ�λ
.dat_6			(H_data[11: 8]	),	//SEG6 ��ʾʪ��ʮλ
.dat_7			(H_data[ 7: 4]	),	//SEG7 ��ʾʪ�ȸ�λ
.dat_8			(H_data[ 3: 0]	),	//SEG8 ��ʾʪ��С��λ
.dat_en			(dat_en			),	//��λ�����������ʾʹ�ܣ�[MSB~LSB]=[SEG1~SEG8]
.dot_en			(dot_en			),	//��λ�����С������ʾʹ�ܣ�[MSB~LSB]=[SEG1~SEG8]
.seg_rck		(seg_rck		),	//74HC595��RCK�ܽ�
.seg_sck		(seg_sck		),	//74HC595��SCK�ܽ�
.seg_din		(seg_din		)	//74HC595��SER�ܽ�
);

endmodule
