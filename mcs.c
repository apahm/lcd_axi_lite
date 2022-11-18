#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xparameters.h"
#include "sleep.h"
#include "string.h"
XGpio gpio;

#define MYIP_S00_AXI_SLV_REG0_OFFSET 0
#define MYIP_S00_AXI_SLV_REG1_OFFSET 4
#define MYIP_S00_AXI_SLV_REG2_OFFSET 8
#define MYIP_S00_AXI_SLV_REG3_OFFSET 12
#define MYIP_S00_AXI_SLV_REG4_OFFSET 16
#define MYIP_S00_AXI_SLV_REG5_OFFSET 20
#define MYIP_S00_AXI_SLV_REG6_OFFSET 24
#define MYIP_S00_AXI_SLV_REG7_OFFSET 28
#define MYIP_S00_AXI_SLV_REG8_OFFSET 32
#define MYIP_S00_AXI_SLV_REG9_OFFSET 36

int main()
{
	init_platform();

	xil_printf("Hello World\n\r");
	u32 i = 0;
	u32 led = 0;

	XGpio_Initialize(&gpio, XPAR_GPIO_0_DEVICE_ID);

	char str_upper[16];
	char str_lower[16];

	strcpy(str_upper, "Microblaze Work!");
	strcpy(str_lower, "Firmware loaded!");

	u32 reg_0 = (str_upper[3] << 24) | (str_upper[2] << 16) | (str_upper[1] << 8) | str_upper[0];
	u32 reg_1 = (str_upper[7] << 24) | (str_upper[6] << 16) | (str_upper[5] << 8) | str_upper[4];
	u32 reg_2 = (str_upper[11] << 24) | (str_upper[10] << 16) | (str_upper[9] << 8) | str_upper[8];
	u32 reg_3 = (str_upper[15] << 24) | (str_upper[14] << 16) | (str_upper[13] << 8) | str_upper[12];
	u32 reg_4 = (str_lower[3] << 24) | (str_lower[2] << 16) | (str_lower[1] << 8) | str_lower[0];
	u32 reg_5 = (str_lower[7] << 24) | (str_lower[6] << 16) | (str_lower[5] << 8) | str_lower[4];
	u32 reg_6 = (str_lower[11] << 24) | (str_lower[10] << 16) | (str_lower[9] << 8) | str_lower[8];
	u32 reg_7 = (str_lower[15] << 24) | (str_lower[14] << 16) | (str_lower[13] << 8) | str_lower[12];


	sleep(1);
	Xil_Out32(XPAR_MYIP_0_S00_AXI_BASEADDR + MYIP_S00_AXI_SLV_REG0_OFFSET, reg_0);
	Xil_Out32(XPAR_MYIP_0_S00_AXI_BASEADDR + MYIP_S00_AXI_SLV_REG1_OFFSET, reg_1);
	Xil_Out32(XPAR_MYIP_0_S00_AXI_BASEADDR + MYIP_S00_AXI_SLV_REG2_OFFSET, reg_2);
	Xil_Out32(XPAR_MYIP_0_S00_AXI_BASEADDR + MYIP_S00_AXI_SLV_REG3_OFFSET, reg_3);
	Xil_Out32(XPAR_MYIP_0_S00_AXI_BASEADDR + MYIP_S00_AXI_SLV_REG4_OFFSET, reg_4);
	Xil_Out32(XPAR_MYIP_0_S00_AXI_BASEADDR + MYIP_S00_AXI_SLV_REG5_OFFSET, reg_5);
	Xil_Out32(XPAR_MYIP_0_S00_AXI_BASEADDR + MYIP_S00_AXI_SLV_REG6_OFFSET, reg_6);
	Xil_Out32(XPAR_MYIP_0_S00_AXI_BASEADDR + MYIP_S00_AXI_SLV_REG7_OFFSET, reg_7);

	Xil_Out32(XPAR_MYIP_0_S00_AXI_BASEADDR + MYIP_S00_AXI_SLV_REG9_OFFSET, 0x1);

	while(1)
	{
		i++;
		if(i == 1000000)
		{
			led = !led;
			XGpio_DiscreteWrite(&gpio, 1, led);
			i = 0;
		}
	}

	cleanup_platform();
	return 0;
}