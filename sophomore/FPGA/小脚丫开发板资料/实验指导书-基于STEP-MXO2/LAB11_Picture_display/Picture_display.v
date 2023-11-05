// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Picture_display
// 
// Author: Step
// 
// Description: Picture_display
// 
// Web: www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.1     |2016/10/30   |Initial ver
// --------------------------------------------------------------------
module Picture_display
(
input					clk,			//12MHzϵͳʱ��
input					rst_n,			//ϵͳ��λ������Ч

output					lcd_res,		//LCDҺ������λ
output					lcd_bl,			//LCD�������
output					lcd_dc,			//LCD����ָ�����
output					lcd_clk,		//LCDʱ���ź�
output					lcd_din			//LCD�����ź�
);

/*
������ʹ��С��Ѿ���İ������װ��ϵ�Һ������1.8�� 128*160 RGB TFT_LCD��ʵ�ֵ�ɫͼƬ��ʾ
����а��������֣�
1.����Һ��������ģ�飬���������ú����ݵĴ��䣻
2.RAMģ�飬����ʹ�õķֲ�ʽRAM���洢ͼƬ���ݣ�
���Ƚ�ͼƬȡģ����mem�ļ���RAM��ʼ��Ϊmem�ļ������ݣ�LCD����ģ���ϵ��ʼ��LCD��Ȼ���RAM�ж�ȡ����ͨ��SPIʱ�򷢸�LCD��
*/

wire			ram_clk_en;
wire	[7:0]	ram_addr;
wire	[131:0]	ram_data;
LCD_RGB LCD_RGB_uut
(
.clk				(clk		),	//12MHzϵͳʱ��
.rst_n				(rst_n		),	//ϵͳ��λ������Ч

.ram_clk_en			(ram_clk_en	),  //RAMʱ��ʹ��
.ram_addr			(ram_addr	),  //RAM��ַ�ź�
.ram_data			(ram_data	),  //RAM�����ź�

.lcd_res			(lcd_res	),  //LCDҺ������λ
.lcd_bl				(lcd_bl		),  //LCD�������
.lcd_dc				(lcd_dc		),  //LCD����ָ�����
.lcd_clk			(lcd_clk	),	//LCDʱ���ź�
.lcd_din			(lcd_din	)	//LCD�����ź�
);

LCD_RAM LCD_RAM_uut
( 
.Address			(ram_addr	),	//RAM��ַ�ź�
.Q					(ram_data	)	//RAM�����ź�
);

endmodule
