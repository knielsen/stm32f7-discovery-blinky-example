#include "stm32f7xx.h"


static void
led_on(void)
{
  HAL_GPIO_WritePin(GPIOI, GPIO_PIN_1, GPIO_PIN_SET);
}


static void
led_off(void)
{
  HAL_GPIO_WritePin(GPIOI, GPIO_PIN_1, GPIO_PIN_RESET);
}


static void
setup_led(void)
{
  GPIO_InitTypeDef gpioInitStructure;

  __HAL_RCC_GPIOI_CLK_ENABLE();
  gpioInitStructure.Pin = GPIO_PIN_1;
  gpioInitStructure.Mode = GPIO_MODE_OUTPUT_PP;
  gpioInitStructure.Pull = GPIO_PULLUP;
  gpioInitStructure.Speed = GPIO_SPEED_HIGH;
  HAL_GPIO_Init(GPIOI, &gpioInitStructure);
  led_off();
}


int
main(void)
{
  uint32_t i;

  setup_led();

  i = 0;
  for(;;)
  {
    if (i % 2)
      led_off();
    else
      led_on();

    for (int j = 0; j < 1000000; j++)
      __asm volatile("nop");
    ++i;
  }

  /* NotReached */
  return 0;
}
