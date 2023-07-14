// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Voltage_Meas
// 
// Author: Step
// 
// Description: Voltage Measure system
// 
// Web: www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.1     |2016/10/30   |Initial ver
// --------------------------------------------------------------------
module Voltage_Meas
(
input				clk,		//ϵͳʱ��
input				rst_n,		//ϵͳ��λ������Ч

output				adc_cs,		//SPI����CS
output				adc_clk,	//SPI����SCK
input				adc_dat,	//SPI����SDA

output		[8:0]	seg_1,  	//MSB~LSB = SEG,DP,G,F,E,D,C,B,A
output		[8:0]	seg_2   	//MSB~LSB = SEG,DP,G,F,E,D,C,B,A
);
	
/*
Ϊ����֤PCF8591��ADC����I2C��������ƣ��������������top�ļ���BCDת��ģ���ļ����������ʾģ���ļ�
ͨ������ADC������ȡ��Ӧ�Ĳ���ֵ��ͨ���Բ������ݵ����㼰BCDת��Ĳ����õ����Ƿ����ȡ�ĵ�ѹ��������
�����ĵ�ѹֵͨ������ܶ�̬����ʾ������ʵ�ֵ�ѹ�źŲɼ������
*/

wire clk_24mhz,locked;
pll u1
(
.areset				(!rst_n			), //pllģ��ĸ�λΪ����Ч
.inclk0				(clk			), //12MHzϵͳʱ������
.c0					(clk_24mhz		), //24MHzʱ�����
.locked				(locked			)  //pll lock�ź����
);

wire adc_done;
wire [7:0] adc_data;
//ʹ��I2C��������PCF8591��ADC���ܣ�����
ADC081S101_driver u2
(
.clk				(clk_24mhz		),	//ϵͳʱ��
.rst_n				(rst_n			),	//ϵͳ��λ������Ч
.adc_cs				(adc_cs			),	//SPI����CS
.adc_clk			(adc_clk		),	//SPI����SCK
.adc_dat			(adc_dat		),	//SPI����SDA
.adc_done			(adc_done		),	//ADC������ɱ�־
.adc_data			(adc_data		)	//ADC��������
);

//��ADC�������ݰ�����ת��Ϊ��ѹ���ݣ�����0.0129������������ֱ�ӳ���129���õ������ݾ���BCDת���С��������4λ����
wire [15:0]	bin_code = adc_data * 16'd129;
wire [19:0]	bcd_code;

//��������ADC���ݽ���BCDת�룬����
bin_to_bcd u3
(
.rst_n				(rst_n			),	//ϵͳ��λ������Ч
.bin_code			(bin_code		),	//��Ҫ����BCDת��Ķ���������
.bcd_code			(bcd_code		)	//ת����BCD�����������
);

//��λ�����ģ������	
Segment_led u4
(
.seg_dot			(1'b1			),	//seg_dot input
.seg_data			(bcd_code[19:16]),	//seg_data input
.segment_led		(seg_1			)	//MSB~LSB = SEG,DP,G,F,E,D,C,B,A
);

//��λ�����ģ������
Segment_led u5
(
.seg_dot			(1'b0			),	//seg_dot input
.seg_data			(bcd_code[15:12]),	//seg_data input
.segment_led		(seg_2			)	//MSB~LSB = SEG,DP,G,F,E,D,C,B,A
);	
	
endmodule
