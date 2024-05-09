// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Encoder
// 
// Author: Step
// 
// Description: Driver for rotary encoder
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module Encoder
(
input					clk,		// ϵͳʱ�� 12MHz
input					rst_n,		// ϵͳ��λ ����Ч
input					key_a,		// ��ת������EC11��A��
input					key_b,		// ��ת������EC11��B��
output	reg				L_pulse,	// �����������
output	reg				R_pulse		// �����������
);
	
localparam				NUM_250US = 3_000;

reg	[12:0]	cnt;
//count for clk_500us
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) cnt <= 0;
	else if(cnt >= NUM_250US-1) cnt <= 1'b0;
	else cnt <= cnt + 1'b1;
end
	
reg	clk_500us;	
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) clk_500us <= 0;
	else if(cnt == NUM_250US-1) clk_500us <= ~clk_500us;
	else clk_500us <= clk_500us;
end
	
reg	key_a_r,key_a_r1,key_a_r2;
//��������̬
always@(posedge clk_500us) begin
	key_a_r		<=	key_a;
	key_a_r1	<=	key_a_r;
	key_a_r2	<=	key_a_r1;
end 

reg	A_state;
//��ȥ��������
always@(key_a_r1 or key_a_r2) begin
	case({key_a_r1,key_a_r2})
		2'b11:	A_state <= 1'b1;
		2'b00:	A_state <= 1'b0;
		default: A_state <= A_state;
	endcase
end 

reg	key_b_r,key_b_r1,key_b_r2;
//��������̬
always@(posedge clk_500us) begin
	key_b_r		<=	key_b;
	key_b_r1	<=	key_b_r;
	key_b_r2	<=	key_b_r1;
end 

reg	B_state;
//��ȥ��������
always@(key_b_r1 or key_b_r2) begin
	case({key_b_r1,key_b_r2})
		2'b11:	B_state <= 1'b1;
		2'b00:	B_state <= 1'b0;
		default: B_state <= B_state;
	endcase
end

reg A_state_r,A_state_r1;
//��A_state�źŽ��б��ؼ��
always@(posedge clk) begin
	A_state_r <= A_state; 
	A_state_r1 <= A_state_r;
end

wire	A_pos	= (!A_state_r1) && A_state_r;
wire	A_neg	= A_state_r1 && (!A_state_r);

//��A�������ذ���B�ĸߵ�ƽ��A���½��ذ���B�ĵ͵�ƽ Ϊ������ת
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) L_pulse <= 1'b0;
	else if((A_pos&&B_state)||(A_neg&&(!B_state))) L_pulse <= 1'b1;
	else L_pulse <= 1'b0;
end 

//��A�������ذ���B�ĵ͵�ƽ��A���½��ذ���B�ĸߵ�ƽ Ϊ������ת
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) R_pulse <= 1'b0;
	else if((A_pos&&(!B_state))||(A_neg&&B_state)) R_pulse <= 1'b1;
	else R_pulse <= 1'b0;
end 

endmodule
