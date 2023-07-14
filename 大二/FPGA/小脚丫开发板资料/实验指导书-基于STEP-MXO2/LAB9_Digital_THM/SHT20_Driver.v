// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: SHT20_Driver
// 
// Author: Step
// 
// Description: SHT20_Driver
// 
// Web: www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.1     |2016/10/30   |Initial ver
// --------------------------------------------------------------------
module SHT20_Driver
(
	input				clk,		//ϵͳʱ��
	input				rst_n,		//ϵͳ��λ������Ч
	
	output				i2c_scl,	//I2C����SCL
	inout				i2c_sda,	//I2C����SDA
	
	output	reg	[15:0]	T_code,		//�¶���ֵ
	output	reg	[15:0]	H_code		//ʪ����ֵ
);
	
	parameter	CNT_NUM	=	15;
	
	localparam	IDLE	=	4'd0;
	localparam	MAIN	=	4'd1;
	localparam	MODE1	=	4'd2;
	localparam	MODE2	=	4'd3;
	localparam	START	=	4'd4;
	localparam	WRITE	=	4'd5;
	localparam	READ	=	4'd6;
	localparam	STOP	=	4'd7;
	localparam	DELAY	=	4'd8;
	
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
	
	reg scl,sda,ack,ack_flag;
	reg [3:0] cnt, cnt_main, cnt_mode1, cnt_mode2, cnt_start, cnt_write, cnt_read, cnt_stop;
	reg [7:0] data_wr, dev_addr, reg_addr, reg_data, data_r, dat_l, dat_h;
	reg [23:0] cnt_delay, num_delay;
	reg [3:0]  state, state_back;

	always@(posedge clk_400khz or negedge rst_n) begin
		if(!rst_n) begin	//���������λ����������ݳ�ʼ��
			scl <= 1'd1; sda <= 1'd1; ack <= ACK; ack_flag <= 1'b0; cnt <= 1'b0;
			cnt_main <= 1'b0; cnt_mode1 <= 1'b0; cnt_mode2 <= 1'b0;
			cnt_start <= 1'b0; cnt_write <= 1'b0; cnt_read <= 1'b0; cnt_stop <= 1'b0;
			cnt_delay <= 1'b0; num_delay <= 24'd48000;
			state <= IDLE; state_back <= IDLE;
		end else begin
			case(state)
				IDLE:begin	//����Ը�λ����Ҫ���ڳ����ܷɺ�Ĵ���
						scl <= 1'd1; sda <= 1'd1; ack <= ACK; ack_flag <= 1'b0; cnt <= 1'b0;
						cnt_main <= 1'b0; cnt_mode1 <= 1'b0; cnt_mode2 <= 1'b0;
						cnt_start <= 1'b0; cnt_write <= 1'b0; cnt_read <= 1'b0; cnt_stop <= 1'b0;
						cnt_delay <= 1'b0; num_delay <= 24'd48000;
						state <= MAIN; state_back <= IDLE;
					end
				MAIN:begin
						if(cnt_main >= 4'd9) cnt_main <= 4'd2;  	//д�����ָ���ѭ��������
						else cnt_main <= cnt_main + 1'b1;	
						case(cnt_main)
							4'd0:	begin dev_addr <= 7'h40; reg_addr <= 8'hfe; state <= MODE1; end	//�����λ
							4'd1:	begin num_delay <= 24'd6000; state <= DELAY; end	//15ms��ʱ
							
							4'd2:	begin dev_addr <= 7'h40; reg_addr <= 8'hf3; state <= MODE1; end	//д������
							4'd3:	begin num_delay <= 24'd34000; state <= DELAY; end	//85ms��ʱ
							4'd4:	begin dev_addr <= 7'h40; state <= MODE2; end	//��ȡ����
							4'd5:	begin T_code <= {dat_h,dat_l}; end	//��ȡ����
							
							4'd6:	begin dev_addr <= 7'h40; reg_addr <= 8'hf5; state <= MODE1; end	//д������
							4'd7:	begin num_delay <= 24'd12000; state <= DELAY; end	//30ms��ʱ
							4'd8:	begin dev_addr <= 7'h40; state <= MODE2; end	//��ȡ����
							4'd9:	begin H_code <= {dat_h,dat_l}; end	//��ȡ����
							default: state <= IDLE;	//�������ʧ�أ�����IDLE�Ը�λ״̬
						endcase
					end
				MODE1:begin	//����д����
						if(cnt_mode1 >= 4'd4) cnt_mode1 <= 1'b0;	//��START�е���״ִ̬�п���cnt_start
						else cnt_mode1 <= cnt_mode1 + 1'b1;
						state_back <= MODE1;
						case(cnt_mode1)
							4'd0:	begin state <= START; end	//I2Cͨ��ʱ���е�START
							4'd1:	begin data_wr <= dev_addr<<1; state <= WRITE; end	//�豸��ַ
							4'd2:	begin data_wr <= reg_addr; state <= WRITE; end	//�Ĵ�����ַ
							4'd3:	begin state <= STOP; end	//I2Cͨ��ʱ���е�STOP
							4'd4:	begin state <= MAIN; end	//����MAIN
							default: state <= IDLE;	//�������ʧ�أ�����IDLE�Ը�λ״̬
						endcase
					end
				MODE2:begin	//���ζ�����
						if(cnt_mode2 >= 4'd7) cnt_mode2 <= 4'd0;	//��START�е���״ִ̬�п���cnt_start
						else cnt_mode2 <= cnt_mode2 + 1'b1;
						state_back <= MODE2;
						case(cnt_mode2)
							4'd0:	begin state <= START; end	//I2Cͨ��ʱ���е�START
							4'd1:	begin data_wr <= (dev_addr<<1)|8'h01; state <= WRITE; end	//�豸��ַ
							4'd2:	begin ack <= ACK; state <= READ; end	//���Ĵ�������
							4'd3:	begin dat_h <= data_r; end
							4'd4:	begin ack <= NACK; state <= READ; end	//���Ĵ�������
							4'd5:	begin dat_l <= data_r; end
							4'd6:	begin state <= STOP; end	//I2Cͨ��ʱ���е�STOP
							4'd7:	begin state <= MAIN; end	//����MAIN
							default: state <= IDLE;	//�������ʧ�أ�����IDLE�Ը�λ״̬
						endcase
					end
				START:begin	//I2Cͨ��ʱ���е���ʼSTART
						if(cnt_start >= 3'd5) cnt_start <= 1'b0;	//��START�е���״ִ̬�п���cnt_start
						else cnt_start <= cnt_start + 1'b1;
						case(cnt_start)
							3'd0:	begin sda <= 1'b1; scl <= 1'b1; end	//��SCL��SDA���ߣ�����4.7us����
							3'd1:	begin sda <= 1'b1; scl <= 1'b1; end	//clk_400khzÿ������2.5us����Ҫ��������
							3'd2:	begin sda <= 1'b0; end	//SDA���͵�SCL���ͣ�����4.0us����
							3'd3:	begin sda <= 1'b0; end	//clk_400khzÿ������2.5us����Ҫ��������
							3'd4:	begin scl <= 1'b0; end	//SCL���ͣ�����4.7us����
							3'd5:	begin scl <= 1'b0; state <= state_back; end	//clk_400khzÿ������2.5us����Ҫ�������ڣ�����MAIN
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
							3'd0:	begin scl <= 1'b0; sda <= data_wr[7-cnt]; end	//SCL���ͣ�������SDA�����Ӧ��λ
							3'd1:	begin scl <= 1'b1; end	//SCL���ߣ�����4.0us����
							3'd2:	begin scl <= 1'b1; end	//clk_400khzÿ������2.5us����Ҫ��������
							3'd3:	begin scl <= 1'b0; end	//SCL���ͣ�׼��������1bit������
							//��ȡ���豸����Ӧ�źŲ��ж�
							3'd4:	begin sda <= 1'bz; end	//�ͷ�SDA�ߣ�׼�����մ��豸����Ӧ�ź�
							3'd5:	begin scl <= 1'b1; end	//SCL���ߣ�����4.0us����
							3'd6:	begin ack_flag <= i2c_sda; end	//��ȡ���豸����Ӧ�źŲ��ж�
							3'd7:	begin scl <= 1'b0; if(ack_flag)state <= state; else state <= state_back; end //SCL���ͣ������Ӧ��ѭ��д
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
							3'd0:	begin scl <= 1'b0; sda <= 1'bz; end	//SCL���ͣ��ͷ�SDA�ߣ�׼�����մ��豸����
							3'd1:	begin scl <= 1'b1; end	//SCL���ߣ�����4.0us����
							3'd2:	begin data_r[7-cnt] <= i2c_sda; end	//��ȡ���豸���ص�����
							3'd3:	begin scl <= 1'b0; end	//SCL���ͣ�׼��������1bit������
							//����豸������Ӧ�ź�
							3'd4:	begin sda <= ack; end	//������Ӧ�źţ���ǰ����յ���������
							3'd5:	begin scl <= 1'b1; end	//SCL���ߣ�����4.0us����
							3'd6:	begin scl <= 1'b1; end	//SCL���ߣ�����4.0us����
							3'd7:	begin scl <= 1'b0; state <= state_back; end	//SCL���ͣ�����MAIN״̬
							default: state <= IDLE;	//�������ʧ�أ�����IDLE�Ը�λ״̬
						endcase
					end
				STOP:begin	//I2Cͨ��ʱ���еĽ���STOP
						if(cnt_stop >= 3'd5) cnt_stop <= 1'b0;	//��STOP�е���״ִ̬�п���cnt_stop
						else cnt_stop <= cnt_stop + 1'b1;
						case(cnt_stop)
							3'd0:	begin sda <= 1'b0; end	//SDA���ͣ�׼��STOP
							3'd1:	begin sda <= 1'b0; end	//SDA���ͣ�׼��STOP
							3'd2:	begin scl <= 1'b1; end	//SCL��ǰSDA����4.0us
							3'd3:	begin scl <= 1'b1; end	//SCL��ǰSDA����4.0us
							3'd4:	begin sda <= 1'b1; end	//SDA����
							3'd5:	begin sda <= 1'b1; state <= state_back; end	//���STOP����������MAIN״̬
							default: state <= IDLE;	//�������ʧ�أ�����IDLE�Ը�λ״̬
						endcase
					end
				DELAY:begin	//12ms��ʱ
						if(cnt_delay >= num_delay) begin
							cnt_delay <= 1'b0;
							state <= MAIN; 
						end else cnt_delay <= cnt_delay + 1'b1;
					end
				default:;
			endcase
		end
	end
	
	assign	i2c_scl = scl;	//��SCL�˿ڸ�ֵ
	assign	i2c_sda = sda;	//��SDA�˿ڸ�ֵ

endmodule
