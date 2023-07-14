// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: logic_ctrl
// 
// Author: Step
// 
// Description: logic_ctrl
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module logic_ctrl
(
input				clk,		//12MHzϵͳʱ��
input				rst_n,		//ϵͳ��λ������Ч

input				L_pulse,	//��������������
input				R_pulse,	//��������������
input				O_pulse,	//��������������

output	reg	[1:0]	wave,		//�������
output	reg	[23:0]	f_inc		//Ƶ�ʿ�����
);

localparam	SIN = 2'b00, SAW = 2'b01, TRI = 2'b10, SQU = 2'b11;

//�������ѡ��
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) wave <= SIN;
	else if(O_pulse)begin
		case(wave)
			SIN: wave <= SAW;
			SAW: wave <= TRI;
			TRI: wave <= SQU;
			SQU: wave <= SIN;
			default: wave <= SIN;
		endcase
	end else wave <= wave;
end

//���ƿ���
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) f_inc <= 24'ha0000;
	else if(L_pulse) begin
		if(f_inc <= 24'h10000) f_inc <= f_inc;
		else f_inc <= f_inc - 24'h10000;
	end else if(R_pulse) begin
		if(f_inc >= 24'h140000) f_inc <= f_inc;
		else f_inc <= f_inc + 24'h10000;
	end else f_inc <= f_inc;
end

endmodule
