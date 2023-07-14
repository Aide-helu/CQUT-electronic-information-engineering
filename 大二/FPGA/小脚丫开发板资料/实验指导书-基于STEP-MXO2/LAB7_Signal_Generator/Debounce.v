// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Debounce
// 
// Author: Step
// 
// Description: Debounce for button with FPGA/CPLD
// 
// Web: www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2015/11/11   |Initial ver
// --------------------------------------------------------------------
module Debounce #
(
parameter	KEY_WIDTH = 1				//������������
)
(
input   					clk,		//ϵͳʱ�� 12MHz
input   					rst_n,		//ϵͳ��λ ����Ч
input   	[KEY_WIDTH-1:0]	key_n,		//�����ź�����
output  reg	[KEY_WIDTH-1:0]	key_jit,	//��ʱ�������
output  wire[KEY_WIDTH-1:0]	key_pulse,	//�����������
output	reg	[KEY_WIDTH-1:0]	key_state	//������ת���
); 

localparam	CNT_NUM = 18'd240000;		//����ϵͳʱ�ӵ�20ms������ֵ

reg [KEY_WIDTH-1:0] key_n_r,key_n_r1,key_n_r2;   
//�ӳ����棬��������̬
always @(posedge clk) begin
	key_n_r <= key_n;
	key_n_r1 <= key_n_r;
	key_n_r2 <= key_n_r1;
end

//���ؼ��
wire  key_edge = (key_n_r1 == key_n_r2)? 1'b0:1'b1;

reg [17:0]  cnt;
//20ms��ʱ������
always @(posedge clk or negedge rst_n)
    if (!rst_n) cnt <= 18'd0;
    else if(key_edge) cnt <=18'd0;
    else cnt <= cnt + 1'b1;

//��ʱ20msʱ��������õ���ʱ�������
always @(posedge clk or negedge rst_n)
    if (!rst_n)  key_jit <= {KEY_WIDTH{1'b1}};
	else if (cnt == CNT_NUM-1) key_jit <= key_n_r2;

reg [KEY_WIDTH-1:0] key_jit_r;
//����ʱ�������key_jit�ӳ�����
always @(posedge clk or negedge rst_n)
    if (!rst_n) key_jit_r <= {KEY_WIDTH{1'b1}};
    else  key_jit_r <= key_jit;

//�����ʱ�������key_jit�½��أ��õ������������
assign key_pulse = key_jit_r & ( ~key_jit);

//�������������źţ���Ӧ���������ת������������һ��
always @(posedge clk or negedge rst_n)
	if (!rst_n) key_state <= {KEY_WIDTH{1'b1}};
    else if(key_pulse) key_state <= key_state ^ key_pulse;
	else key_state <= key_state;

endmodule
