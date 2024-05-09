// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: mode_ctrl
// 
// Author: Step
// 
// Description: mode_ctrl
// 
// Web: www.stepfapga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2016/04/20   |Initial ver
// --------------------------------------------------------------------
module mode_ctrl
(
input					clk,			//ϵͳʱ��
input					rst_n,		//ϵͳ��λ������Ч
input					L_pulse,		//����ת��������
input					R_pulse,	//����ת��������
input					O_pulse,		//������������

input			[7:0]	rtc_sec,		//ʵʱ��������
input			[7:0]	rtc_min,		//ʵʱ��������
input			[7:0]	rtc_hour,		//ʵʱʱ������
input			[7:0]	rtc_week,		//ʵʱ��������
input			[7:0]	rtc_day,		//ʵʱ��������
input			[7:0]	rtc_mon,		//ʵʱ�·�����
input			[7:0]	rtc_year,		//ʵʱ�������

output	reg		[2:0]	state,			//����״̬���
output	reg		[3:0]	disp_en,		//��ʾ�������
output	reg		[7:0]	adj_sec,		//���ӵ������
output	reg		[7:0]	adj_min,		//���ӵ������
output	reg		[7:0]	adj_hour,		//ʱ�ӵ������
output	reg		[7:0]	adj_week,		//���ڵ������
output	reg		[7:0]	adj_day,		//���ڵ������
output	reg		[7:0]	adj_mon,		//�·ݵ������
output	reg		[7:0]	adj_year		//��ݵ������
);

//ʱ������״̬����
always@(posedge clk or negedge rst_n )
	if(!rst_n) state <= 3'd0;
	else if(O_pulse) //�����������ʱ������״̬�����䣬
		if(state) state <= state - 3'd1;
		else state <= 3'd7;
	else state <= state;

//ͨ�����ӵ����ݵõ�1Hz�����ź�
reg	rtc_sec_r1,rtc_sec_r2;
always@(posedge clk or negedge rst_n )
	if(!rst_n) begin
		rtc_sec_r1 <= 1'b0;
		rtc_sec_r2 <= 1'b0;
	end else begin
		rtc_sec_r1 <= rtc_sec[0];	//��ʱ����
		rtc_sec_r2 <= rtc_sec_r1;	//��ʱ����
	end
	
//ͨ�����ӵ����ݵõ�1Hz�����ź�
wire sec_pulse = (rtc_sec_r2 != rtc_sec_r1);	

//�����λѡ����
always@(posedge clk or negedge rst_n )
	if(!rst_n) disp_en <= 4'b0111;
	else case(state)
		3'd0:			//����ģʽ
			if(L_pulse) disp_en <= 4'b1111;				//����ģʽ�£�������ʾ��������ʱ�������ȫ��
			else if(R_pulse) disp_en <= 4'b0111;		//����ģʽ�£�������ʾʱ����ʱ�������ʱ����λ��
			else disp_en <= disp_en;
		3'd1: begin 	//����ģʽ
				disp_en[3:1] <= 3'b011;	
				if(L_pulse|R_pulse) disp_en[0] <= 1'b1;
				else if(sec_pulse) disp_en[0] <= ~disp_en[0];	//����ģʽ�£�������˸��ʾ
				else if(O_pulse) disp_en <= 4'b0111;
				else disp_en[0] <= disp_en[0];
			  end
		3'd2: begin 	//����ģʽ
				disp_en[3:2] <= 2'b01;
				disp_en[0] <= 1'b1;
				if(L_pulse|R_pulse) disp_en[1] <= 1'b1;
				else if(sec_pulse) disp_en[1] <= ~disp_en[1];	//����ģʽ�£�������˸��ʾ
				else disp_en[1] <= disp_en[1];
			  end
		3'd3: begin 	//��ʱģʽ
				disp_en[3] <= 1'b0;
				disp_en[1:0] <= 2'b11;
				if(L_pulse|R_pulse) disp_en[2] <= 1'b1;
				else if(sec_pulse) disp_en[2] <= ~disp_en[2];	//��ʱģʽ�£�ʱ����˸��ʾ
				else disp_en[2] <= disp_en[2];
			  end
		3'd4: begin 	//����ģʽ
				disp_en[3:1] <= 3'b111;
				if(L_pulse|R_pulse) disp_en[0] <= 1'b1;
				else if(sec_pulse) disp_en[0] <= ~disp_en[0];	//����ģʽ�£�����˸��ʾ
				else disp_en[0] <= disp_en[0];
			  end
		3'd5: begin 	//����ģʽ
				disp_en[3:2] <= 2'b11;
				disp_en[0] <= 1'b1;
				if(L_pulse|R_pulse) disp_en[1] <= 1'b1;
				else if(sec_pulse) disp_en[1] <= ~disp_en[1];	//������ģʽ�£�������˸��ʾ
				else disp_en[1] <= disp_en[1];
			  end
		3'd6: begin 	//����ģʽ
				disp_en[3] <= 1'b1;
				disp_en[1:0] <= 2'b11;
				if(L_pulse|R_pulse) disp_en[2] <= 1'b1;
				else if(sec_pulse) disp_en[2] <= ~disp_en[2];	//���·�ģʽ�£��·���˸��ʾ
				else disp_en[2] <= disp_en[2];
			  end
		3'd7: begin 	//����ģʽ
				disp_en[2:0] <= 3'b111;
				if(L_pulse|R_pulse) disp_en[3] <= 1'b1;
				else if(sec_pulse) disp_en[3] <= ~disp_en[3];	//����ģʽ�£������˸��ʾ
				else disp_en[3] <= disp_en[3];
			  end
		default: disp_en <= 4'b0111;
	endcase
	
//display enable control
always@(posedge clk or negedge rst_n )
	if(!rst_n) begin
		adj_sec  <= 8'h01;
		adj_min  <= 8'h01;
		adj_hour <= 8'h01;
		adj_week <= 8'h01;
		adj_day  <= 8'h01;
		adj_mon  <= 8'h01;
		adj_year <= 8'h18;
	end else case(state)
		3'd0:		//����ģʽ
			begin
				if(O_pulse)begin			//������ģʽ�°�OK�������Ὣ��ǰ��ʵʱʱ�丳ֵ�����ڼĴ���
					adj_sec  <= rtc_sec;
					adj_min  <= rtc_min;
					adj_hour <= rtc_hour;
					adj_week <= rtc_week;
					adj_day  <= rtc_day;
					adj_mon  <= rtc_mon;
					adj_year <= rtc_year;
				end
			end
		3'd1: 		//����ģʽ
			begin
				if(L_pulse) begin
					if(adj_sec[3:0]) adj_sec <= adj_sec - 1'h1;
					else if(adj_sec[7:4]) adj_sec <= {adj_sec[7:4]-1'h1,4'h9};
					else adj_sec <= 8'h59;
				end else if(R_pulse) begin
					if(adj_sec[3:0]!=4'h9) adj_sec <= adj_sec + 1'h1;
					else if(adj_sec[7:4]!=4'h5) adj_sec <= {adj_sec[7:4]+1'h1,4'h0};
					else adj_sec <= 8'h00;
				end else adj_sec <= adj_sec;
			end
		3'd2:
			begin
				if(L_pulse) begin
					if(adj_min[3:0]) adj_min <= adj_min - 1'h1;
					else if(adj_min[7:4]) adj_min <= {adj_min[7:4]-1'h1,4'h9};
					else adj_min <= 8'h59;
				end else if(R_pulse) begin
					if(adj_min[3:0]!=4'h9) adj_min <= adj_min + 1'h1;
					else if(adj_min[7:4]!=4'h5) adj_min <= {adj_min[7:4]+1'h1,4'h0};
					else adj_min <= 8'h00;
				end else adj_min <= adj_min;
			end
		3'd3:
			begin
				if(L_pulse) begin
					if(adj_hour[3:0]) adj_hour <= adj_hour - 1'h1;
					else if(adj_hour[7:4]) adj_hour <= {adj_hour[7:4]-1'h1,4'h9};
					else adj_hour <= 8'h23;
				end else if(R_pulse) begin
					if(adj_hour==8'h23) adj_hour <= 8'h00;
					else if(adj_hour[3:0]!=4'h9) adj_hour <= adj_hour + 1'h1;
					else adj_hour <= {adj_hour[7:4]+1'h1,4'h0};
				end else adj_hour <= adj_hour;
			end
		3'd4:
			begin
				if(L_pulse) begin
					if(adj_week==8'h01) adj_week <= 8'h07;
					else adj_week <= adj_week - 1'h1;
				end else if(R_pulse) begin
					if(adj_week==8'h07) adj_week <= 8'h01;
					else adj_week <= adj_week + 1'h1;
				end else adj_week <= adj_week;
			end
		3'd5:
			begin
				if((adj_mon==8'h4)|(adj_mon==8'h6)|(adj_mon==8'h9)|(adj_mon==8'h11)) begin
					if(L_pulse) begin
						if(adj_day==8'h01) adj_day <= 8'h30;
						else if(adj_day[3:0]) adj_day <= adj_day - 1'h1;
						else adj_day <= {adj_day[7:4]-1'h1,4'h9};
					end else if(R_pulse) begin
						if(adj_day==8'h30) adj_day <= 8'h01;
						else if(adj_day[3:0]!=4'h9) adj_day <= adj_day + 1'h1;
						else adj_day <= {adj_day[7:4]+1'h1,4'h0};
					end else adj_day <= adj_day;
				end else if(adj_mon==8'h02) begin
					if(adj_year[1:0]) begin
						if(L_pulse) begin
							if(adj_day==8'h01) adj_day <= 8'h29;
							else if(adj_day[3:0]) adj_day <= adj_day - 1'h1;
							else adj_day <= {adj_day[7:4]-1'h1,4'h9};
						end else if(R_pulse) begin
							if(adj_day==8'h29) adj_day <= 8'h01;
							else if(adj_day[3:0]!=4'h9) adj_day <= adj_day + 1'h1;
							else adj_day <= {adj_day[7:4]+1'h1,4'h0};
						end else adj_day <= adj_day;
					end else begin
						if(L_pulse) begin
							if(adj_day==8'h01) adj_day <= 8'h28;
							else if(adj_day[3:0]) adj_day <= adj_day - 1'h1;
							else adj_day <= {adj_day[7:4]-1'h1,4'h9};
						end else if(R_pulse) begin
							if(adj_day==8'h28) adj_day <= 8'h01;
							else if(adj_day[3:0]!=4'h9) adj_day <= adj_day + 1'h1;
							else adj_day <= {adj_day[7:4]+1'h1,4'h0};
						end else adj_day <= adj_day;
					end
				end else begin
					if(L_pulse) begin
						if(adj_day==8'h01) adj_day <= 8'h31;
						else if(adj_day[3:0]) adj_day <= adj_day - 1'h1;
						else adj_day <= {adj_day[7:4]-1'h1,4'h9};
					end else if(R_pulse) begin
						if(adj_day==8'h31) adj_day <= 8'h01;
						else if(adj_day[3:0]!=4'h9) adj_day <= adj_day + 1'h1;
						else adj_day <= {adj_day[7:4]+1'h1,4'h0};
					end else adj_day <= adj_day;
				end
			end
		3'd6:
			begin
				if(L_pulse) begin
					if(adj_mon==8'h01) adj_mon <= 8'h12;
					else if(adj_mon[3:0]) adj_mon <= adj_mon - 1'h1;
					else adj_mon <= {adj_mon[7:4]-1'h1,4'h9};
				end else if(R_pulse) begin
					if(adj_mon==8'h12) adj_mon <= 8'h01;
					else if(adj_mon[3:0]!=4'h9) adj_mon <= adj_mon + 1'h1;
					else adj_mon <= {adj_mon[7:4]+1'h1,4'h0};
				end else adj_mon <= adj_mon;
			end
		3'd7:
			begin
				if(L_pulse) begin
					if(adj_year[3:0]) adj_year <= adj_year - 1'h1;
					else if(adj_year[7:4]) adj_year <= {adj_year[7:4]-1'h1,4'h9};
					else adj_year <= 8'h99;
				end else if(R_pulse) begin
					if(adj_year[3:0]!=4'h9) adj_year <= adj_year + 1'h1;
					else if(adj_year[7:4]!=4'd9) adj_year <= {adj_year[7:4]+1'h1,4'h0};
					else adj_year <= 8'h00;
				end else adj_year <= adj_year;
			end
		default:
			begin
				adj_sec  <= rtc_sec;
				adj_min  <= rtc_min;
				adj_hour <= rtc_hour;
				adj_week <= rtc_week;
				adj_day  <= rtc_day;
				adj_mon  <= rtc_mon;
				adj_year <= rtc_year;
			end
	endcase	
	
endmodule
