#!/usr/bin/env python
import RPi.GPIO as GPIO
import time

GPIO_NO = 25

GPIO.setmode(GPIO.BCM)
GPIO.setup(GPIO_NO, GPIO.OUT)

try:
    while True:
        GPIO.output(GPIO_NO, GPIO.HIGH)
        time.sleep(0.5)

        GPIO.output(GPIO_NO, GPIO.LOW)
        time.sleep(0.5)
except KeyboardInterrupt as e:
    print("")
    pass

GPIO.cleanup()
