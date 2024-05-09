// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: DS1340Z_driver
// 
// Author: Step
// 
// Description: DS1340Z_driver
// 
// Web: www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.1     |2016/10/30   |Initial ver
// --------------------------------------------------------------------
module DS1340Z_driver
(
input				clk,		//ϵͳʱ��
input				rst_n,	//ϵͳ��λ������Ч

input				key_set,	//������������

output				i2c_scl,	//I2C����SCL
inout				i2c_sda,	//I2C����SDA

input		[7:0]	adj_sec,	//���ӵ�������
input		[7:0]	adj_min,    //���ӵ�������
input		[7:0]	adj_hour,   //ʱ�ӵ�������
input		[7:0]	adj_week,   //���ڵ�������
input		[7:0]	adj_day,    //���ڵ�������
input		[7:0]	adj_mon,    //�·ݵ�������
input		[7:0]	adj_year,   //��ݵ�������

output	reg	[7:0]	rtc_sec,	//ʵʱ�������
output	reg	[7:0]	rtc_min,    //ʵʱ�������
output	reg	[7:0]	rtc_hour,   //ʵʱʱ�����
output	reg	[7:0]	rtc_week,   //ʵʱ�������
output	reg	[7:0]	rtc_day,    //ʵʱ�������
output	reg	[7:0]	rtc_mon,    //ʵʱ�·����
output	reg	[7:0]	rtc_year    //ʵʱ������
);

parameter	CNT_NUM	=	15;

localparam	IDLE	=	3'd0;
localparam	MAIN	=	3'd1;
localparam	START	=	3'd2;
localparam	WRITE	=	3'd3;
localparam	READ	=	3'd4;
localparam	STOP	=	3'd5;

localparam	ACK		=	1'b0;
localparam	NACK	=	1'b1;

//ʹ�ü�������Ƶ����400KHzʱ���ź�clk_400khz
reg					clk_400khz;
reg		[9:0]		cnt_400khz;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt_400khz <= 10'd0;
		clk_400khz <= 1'b0;
	end else if(cnt_400khz >= CNT_NUM-1) begin
		cnt_400khz <= 10'd0;
		clk_400khz <= ~clk_400khz;
	end else begin
		cnt_400khz <= cnt_400khz + 1'b1;
	end
end

reg					set_flag;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) set_flag <= 1'b0;
	else if(cnt_main==5'd11) set_flag <= 1'b0;	//�����д��ʱ�������λset_flag
	else if(key_set) set_flag <= 1'b1;			//�����������set_flag��λ
	else set_flag <= set_flag;
end

reg		[7:0]		rtc_data_r;
reg					scl_out_r;
reg					sda_out_r;
reg					ack;
reg		[2:0]		cnt;
reg		[5:0]		cnt_main;
reg		[7:0]		data_wr;
reg		[2:0]		cnt_start;
reg		[2:0]		cnt_write;
reg		[4:0]		cnt_read;
reg		[2:0]		cnt_stop;
reg		[2:0] 		state;

always@(posedge clk_400khz or negedge rst_n) begin
	if(!rst_n) begin	//���������λ����������ݳ�ʼ��
		scl_out_r <= 1'd1;
		sda_out_r <= 1'd1;
		ack <= ACK;
		cnt <= 1'b0;
		cnt_main <= 6'd12;
		cnt_start <= 3'd0;
		cnt_write <= 3'd0;
		cnt_read <= 5'd0;
		cnt_stop <= 1'd0;
		state <= IDLE;
	end else begin
		case(state)
			IDLE:begin	//����Ը�λ����Ҫ���ڳ����ܷɺ�Ĵ���
					scl_out_r <= 1'd1;
					sda_out_r <= 1'd1;
					ack <= ACK;
					cnt <= 1'b0;
					cnt_main <= 6'd12;
					cnt_start <= 3'd0;
					cnt_write <= 3'd0;
					cnt_read <= 5'd0;
					cnt_stop <= 1'd0;
					state <= MAIN;
				end
			MAIN:begin
					if(cnt_main >= 6'd32) //��MAIN�е���״ִ̬�п���cnt_main
						if(set_flag)cnt_main <= 6'd0;	//��set_flag����λʱ�Ż�ִ��ʱ��д�����
						else cnt_main <= 6'd12;  		//����ִֻ��ʱ���ȡ����
					else cnt_main <= cnt_main + 1'b1;	
					case(cnt_main)
						6'd0:	begin state <= START; end	//I2Cͨ��ʱ���е�START
						6'd1:	begin data_wr <= 8'hd0; state <= WRITE; end		//д��ַΪ8'hd0
						6'd2:	begin data_wr <= 8'h00; state <= WRITE; end		//8'h00���Ĵ�����ʼ��ַ
						6'd3:	begin data_wr <= adj_sec; state <= WRITE; end	//д��
						6'd4:	begin data_wr <= adj_min; state <= WRITE; end	//д��
						6'd5:	begin data_wr <= adj_hour; state <= WRITE; end	//дʱ
						6'd6:	begin data_wr <= adj_week; state <= WRITE; end	//д��
						6'd7:	begin data_wr <= adj_day; state <= WRITE; end	//д��
						6'd8:	begin data_wr <= adj_mon; state <= WRITE; end	//д��
						6'd9:	begin data_wr <= adj_year; state <= WRITE; end	//д��
						6'd10:	begin data_wr <= 8'h40; state <= WRITE; end		//8'h40������
						6'd11:	begin state <= STOP; end	//I2Cͨ��ʱ���е�STOP
						
						6'd12:	begin state <= START; end	//I2Cͨ��ʱ���е�START
						6'd13:	begin data_wr <= 8'hd0; state <= WRITE; end	//д��ַΪ8'hd0
						6'd14:	begin data_wr <= 8'h00; state <= WRITE; end	//8'h00���Ĵ�����ʼ��ַ
						6'd15:	begin state <= START; end	//I2Cͨ��ʱ���е�START
						6'd16:	begin data_wr <= 8'hd1; state <= WRITE; end	//����ַΪ8'hd1
						6'd17:	begin ack <= ACK; state <= READ; end	//����
						6'd18:	begin rtc_sec <= rtc_data_r; end
						6'd19:	begin ack <= ACK; state <= READ; end	//����
						6'd20:	begin rtc_min <= rtc_data_r; end
						6'd21:	begin ack <= ACK; state <= READ; end	//��ʱ
						6'd22:	begin rtc_hour <= rtc_data_r; end
						6'd23:	begin ack <= ACK; state <= READ; end	//����
						6'd24:	begin rtc_week <= rtc_data_r; end
						6'd25:	begin ack <= ACK; state <= READ; end	//����
						6'd26:	begin rtc_day <= rtc_data_r; end
						6'd27:	begin ack <= ACK; state <= READ; end	//����
						6'd28:	begin rtc_mon <= rtc_data_r; end
						6'd29:	begin ack <= ACK; state <= READ; end	//����
						6'd30:	begin rtc_year <= rtc_data_r; end
						6'd31:	begin ack <= NACK; state <= READ; end	//����
						6'd32:	begin state <= STOP; end	//I2Cͨ��ʱ���е�STOP����ȡ��ɱ�־
						default: state <= IDLE;	//�������ʧ�أ�����IDLE�Ը�λ״̬
					endcase
				end
			START:begin	//I2Cͨ��ʱ���е���ʼSTART
					if(cnt_start >= 3'd5) cnt_start <= 1'b0;	//��START�е���״ִ̬�п���cnt_start
					else cnt_start <= cnt_start + 1'b1;
					case(cnt_start)
						3'd0:	begin sda_out_r <= 1'b1; scl_out_r <= 1'b1; end	//��SCL��SDA���ߣ�����4.7us����
						3'd1:	begin sda_out_r <= 1'b1; scl_out_r <= 1'b1; end	//clk_400khzÿ������2.5us����Ҫ��������
						3'd2:	begin sda_out_r <= 1'b0; end	//SDA���͵�SCL���ͣ�����4.0us����
						3'd3:	begin sda_out_r <= 1'b0; end	//clk_400khzÿ������2.5us����Ҫ��������
						3'd4:	begin scl_out_r <= 1'b0; end	//SCL���ͣ�����4.7us����
						3'd5:	begin scl_out_r <= 1'b0; state <= MAIN; end	//clk_400khzÿ������2.5us����Ҫ�������ڣ�����MAIN
						default: state <= IDLE;	//�������ʧ�أ�����IDLE�Ը�λ״̬
					endcase
				end
			WRITE:begin	//I2Cͨ��ʱ���е�д����WRITE����Ӧ�жϲ���ACK
					if(cnt <= 3'd6) begin	//����Ҫ����8bit�����ݣ��������ѭ���Ĵ���
						if(cnt_write >= 3'd3) begin cnt_write <= 1'b0; cnt <= cnt + 1'b1; end
						else begin cnt_write <= cnt_write + 1'b1; cnt <= cnt; end
					end else begin
						if(cnt_write >= 3'd7) begin cnt_write <= 1'b0; cnt <= 1'b0; end	//�����������ָ���ֵ
						else begin cnt_write <= cnt_write + 1'b1; cnt <= cnt; end
					end
					case(cnt_write)
						//����I2C��ʱ��������
						3'd0:	begin scl_out_r <= 1'b0; sda_out_r <= data_wr[7-cnt]; end	//SCL���ͣ�������SDA�����Ӧ��λ
						3'd1:	begin scl_out_r <= 1'b1; end	//SCL���ߣ�����4.0us����
						3'd2:	begin scl_out_r <= 1'b1; end	//clk_400khzÿ������2.5us����Ҫ��������
						3'd3:	begin scl_out_r <= 1'b0; end	//SCL���ͣ�׼��������1bit������
						//��ȡ���豸����Ӧ�źŲ��ж�
						3'd4:	begin sda_out_r <= 1'bz; end	//�ͷ�SDA�ߣ�׼�����մ��豸����Ӧ�ź�
						3'd5:	begin scl_out_r <= 1'b1; end	//SCL���ߣ�����4.0us����
						3'd6:	begin if(i2c_sda) state <= IDLE; else state <= state; end	//��ȡ���豸����Ӧ�źŲ��ж�
						3'd7:	begin scl_out_r <= 1'b0; state <= MAIN; end	//SCL���ͣ�����MAIN״̬
						default: state <= IDLE;	//�������ʧ�أ�����IDLE�Ը�λ״̬
					endcase
				end
			READ:begin	//I2Cͨ��ʱ���еĶ�����READ�ͷ���ACK�Ĳ���
					if(cnt <= 3'd6) begin	//����Ҫ����8bit�����ݣ��������ѭ���Ĵ���
						if(cnt_read >= 3'd3) begin cnt_read <= 1'b0; cnt <= cnt + 1'b1; end
						else begin cnt_read <= cnt_read + 1'b1; cnt <= cnt; end
					end else begin
						if(cnt_read >= 3'd7) begin cnt_read <= 1'b0; cnt <= 1'b0; end	//�����������ָ���ֵ
						else begin cnt_read <= cnt_read + 1'b1; cnt <= cnt; end
					end
					case(cnt_read)
						//����I2C��ʱ���������
						3'd0:	begin scl_out_r <= 1'b0; sda_out_r <= 1'bz; end	//SCL���ͣ��ͷ�SDA�ߣ�׼�����մ��豸����
						3'd1:	begin scl_out_r <= 1'b1; end	//SCL���ߣ�����4.0us����
						3'd2:	begin rtc_data_r[7-cnt] <= i2c_sda; end	//��ȡ���豸���ص�����
						3'd3:	begin scl_out_r <= 1'b0; end	//SCL���ͣ�׼��������1bit������
						//����豸������Ӧ�ź�
						3'd4:	begin sda_out_r <= ack; end	//������Ӧ�źţ���ǰ����յ���������
						3'd5:	begin scl_out_r <= 1'b1; end	//SCL���ߣ�����4.0us����
						3'd6:	begin scl_out_r <= 1'b1; end	//SCL���ߣ�����4.0us����
						3'd7:	begin scl_out_r <= 1'b0; state <= MAIN; end	//SCL���ͣ�����MAIN״̬
						default: state <= IDLE;	//�������ʧ�أ�����IDLE�Ը�λ״̬
					endcase
				end
			STOP:begin	//I2Cͨ��ʱ���еĽ���STOP
					if(cnt_stop >= 3'd5) cnt_stop <= 1'b0;	//��STOP�е���״ִ̬�п���cnt_stop
					else cnt_stop <= cnt_stop + 1'b1;
					case(cnt_stop)
						3'd0:	begin sda_out_r <= 1'b0; end	//SDA���ͣ�׼��STOP
						3'd1:	begin sda_out_r <= 1'b0; end	//SDA���ͣ�׼��STOP
						3'd2:	begin scl_out_r <= 1'b1; end	//SCL��ǰSDA����4.0us
						3'd3:	begin scl_out_r <= 1'b1; end	//SCL��ǰSDA����4.0us
						3'd4:	begin sda_out_r <= 1'b1; end	//SDA����
						3'd5:	begin sda_out_r <= 1'b1; state <= MAIN; end	//���STOP����������MAIN״̬
						default: state <= IDLE;	//�������ʧ�أ�����IDLE�Ը�λ״̬
					endcase
				end
			default:;
		endcase
	end
end

assign	i2c_scl = scl_out_r;	//��SCL�˿ڸ�ֵ
assign	i2c_sda = sda_out_r;	//��SDA�˿ڸ�ֵ

endmodule
