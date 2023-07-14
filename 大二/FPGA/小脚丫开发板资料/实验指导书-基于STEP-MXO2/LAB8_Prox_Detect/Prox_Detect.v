// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Prox_Detect
// 
// Author: Step
// 
// Description: Prox_Detect
// 
// Web: www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.1     |2016/10/30   |Initial ver
// --------------------------------------------------------------------
module Prox_Detect
(
input				clk,
input				rst_n,

output				i2c_scl,	//I2Cʱ������
inout				i2c_sda,	//I2C��������

output		[7:0]	led			//led��
);

wire dat_valid;
wire [15:0] ch0_dat, ch1_dat, prox_dat;
APDS_9901_Driver u1
(
.clk			(clk			),	//ϵͳʱ��
.rst_n			(rst_n			),	//ϵͳ��λ������Ч
.i2c_scl		(i2c_scl		),	//I2C����SCL
.i2c_sda		(i2c_sda		),	//I2C����SDA

.dat_valid		(dat_valid		),	//������Ч����
.ch0_dat		(ch0_dat		),	//ALS����
.ch1_dat		(ch1_dat		),	//IR����
.prox_dat		(prox_dat		)	//Prox����
);

Decoder u2
(
.dat_valid		(dat_valid		),
.prox_dat		(prox_dat		),
.Y_out			(led			)
);

endmodule
