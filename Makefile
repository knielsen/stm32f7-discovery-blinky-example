TARGET=blinky

OBJS = $(TARGET).o

STM_DIR=/kvm/src/STM32Cube_FW_F7_V1.1.0

STM_SRC = $(STM_DIR)/Drivers/STM32F7xx_HAL_Driver/Src
STM_TEMPLATE = $(STM_DIR)/Drivers/CMSIS/Device/ST/STM32F7xx/Source/Templates
vpath %.c $(STM_SRC) $(STM_TEMPLATE)
# ToDo: Can use the pristine ST startup_stm32f746xx.s once gcc is upgraded to know M7
# vpath %.s $(STM_TEMPLATE)/gcc

# The file system_stm32f7xx.c defines the SystemInit() function, which sets up
# FPU and resets the RCC clock configuration. Note that it does not configure
# any clock except the default 16 MHz HSI.
STM_OBJS = system_stm32f7xx.o
# The file startup_stm32f746xx.s contains the vector table and the reset
# handler. The reset handler sets up data and bss segments, calls SystemInit(),
# and transfers control to main().
STM_OBJS += startup_stm32f746xx.o
# HAL peripheral drivers.
STM_OBJS += stm32f7xx_hal_gpio.o

INC_DIRS += $(STM_DIR)/Drivers/CMSIS/Include
INC_DIRS += $(STM_DIR)/Drivers/CMSIS/Device/ST/STM32F7xx/Include
INC_DIRS += $(STM_DIR)/Drivers/STM32F7xx_HAL_Driver/Inc
INC_DIRS += .
INC = $(addprefix -I,$(INC_DIRS))


CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy

LINKSCRIPT=$(TARGET).ld

# ToDo: Can use here: -mcpu=cortex-m7 -mfpu=fpv5-sp-d16
ARCH_FLAGS=-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -ffunction-sections -fdata-sections -ffast-math

CFLAGS=-ggdb -O2 -std=c99 -Wall -Wextra -Warray-bounds -Wno-unused-parameter $(ARCH_FLAGS) $(INC) -DSTM32F746xx -DUSE_HAL_DRIVER
LDFLAGS=-Wl,--gc-sections -lm


.PHONY: all flash clean tty cat

all: $(TARGET).bin

$(TARGET).bin: $(TARGET).elf

$(TARGET).elf: $(OBJS) $(STM_OBJS) $(LINKSCRIPT)
	$(LD) $(ARCH_FLAGS) -T $(LINKSCRIPT) -o $@ $(OBJS) $(STM_OBJS) $(LDFLAGS)

$(TARGET).o: $(TARGET).c stm32f7xx_hal_conf.h

%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

# ToDo: Remove this once gcc is upgraded to understand cortex-m7
startup_stm32f746xx.s: $(STM_TEMPLATE)/gcc/startup_stm32f746xx.s
	sed -e 's/cortex-m7/cortex-m4/' < $< > $@

%.o: %.c $(TARGET).h stm32f7xx_hal_conf.h
	$(CC) $(CFLAGS) -c $< -o $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

flash: $(TARGET).bin
	st-flash write $(TARGET).bin 0x8000000

clean:
	rm -f $(OBJS) $(STM_OBJS) $(TARGET).elf $(TARGET).bin
