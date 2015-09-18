MEMORY
{
	FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 1024K
	/* The first 64K of SRAM is the CPU tightly coupled memory. But it is
	   accessible also by DMA on the STM32F7. */
	RAM_MAIN (rwx) : ORIGIN = 0x20000000, LENGTH = 320K
	/* Tightly coupled memory. */
	RAM_CPU (rwx) : ORIGIN = 0x20000000, LENGTH = 64K
}
_estack = 0x20050000;


SECTIONS
{
	.text :
	{
		KEEP(*(.isr_vector))
		*(.text*)
		*(.rodata*)
		. = ALIGN(4);
		_etext = .;
	} > FLASH

	_sidata = .;

	.data : AT(_sidata)
	{
		_sdata = .;
		*(.data*)
		. = ALIGN(4);
		_edata = .;
	} > RAM_MAIN

	.bss :
	{
		_sbss = .;
		*(.bss*)
		*(COMMON)
		. = ALIGN(4);
		_ebss = .;
	} > RAM_MAIN

	/* Check that there is room for stack. */
	._stack_free_space :
	{
		. = . + 4K;  /* Minimum 4 kByte stack free. */
	} > RAM_MAIN
}

ENTRY(Reset_Handler)
