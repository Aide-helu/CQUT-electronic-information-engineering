// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Screen_Saver
// 
// Author: Step
// 
// Description: Screen_Saver
// 
// Web: www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.1     |2016/10/30   |Initial ver
// --------------------------------------------------------------------
`define		VGA_800X600_60Hz
`include	"Param_define.v"

module Screen_Saver
(
input 				clk,		// system clock
input 				rst_n,		// system reset, active low
output 				sync_v,		// sync_v
output 				sync_h,		// sync_h
output  	[2:0]	vga			// vga,MSB~LSB = {R,G,B}
);

wire					clk_240mhz;
//lattice diamond��IP�˲�֧�ֱ�Ƶͬʱ��Ƶ�������ȱ�Ƶ��240MHz��Ȼ���ֶ�6��Ƶ��40MHz
pll_mxo2 u1 
(
.CLKI 				(clk 		),	//12MHzʱ������
.CLKOP 				(clk_240mhz )	//240MHzʱ�����
);

reg				[1:0]	cnt;
reg						clk_40mhz;
//ʹ�ü�������240MHzʱ�ӽ��з�Ƶ����40MHz�ź�
always@(posedge clk_240mhz or negedge rst_n) begin
	if(!rst_n) begin
		cnt <= 1'b0;
		clk_40mhz <= 1'b0;
	end else begin
		if(cnt==2'd2)begin 
			cnt <= 1'b0;
			clk_40mhz <= ~clk_40mhz;
		end else cnt <= cnt + 1'b1;
	end
end

wire [6:0] rom_addr;
wire [127:0] rom_data;

Vga_Module u2
(
.clk				(clk_40mhz	),	// system clock
.rst_n				(rst_n		),	// system reset, active low

.rom_addr			(rom_addr	),	// sync_v
.rom_data			(rom_data	),	// sync_v

.sync_v				(sync_v		),	// sync_v
.sync_h				(sync_h		),	// sync_h
.vga				(vga		)	// vga,MSB~LSB = {R,G,B}
);

// rom module
step_rom u3
( 
.Address			(rom_addr	), 
.Q					(rom_data	)
);

endmodule
