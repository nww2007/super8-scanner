#!/usr/bin/env python
# vim:fileencoding=UTF-8
# -*- coding: UTF-8 -*-

'''
Created on 4 january 2023 y.

@author: nww
'''


from serial import serial_for_url, Serial, PARITY_NONE,  STOPBITS_ONE,  EIGHTBITS

from config import logging



class MotorsSerialException(Exception):
    ...


class Ser():


    def __init__(self, port='/dev/ttyUSB0', debug_mode=False):
        if debug_mode:
            self.ser = Serial()
            self.ser.port  = port
            self.ser.open()
        else:
            self.ser = serial_for_url(f'spy://{port}?file=test.txt')

        self.write = self.ser.write

        self.ser.timeout  = 2   #make sure that the alive event can be checked from time to time
        self.ser.baudrate = 115200
        self.ser.parity   = PARITY_NONE
        self.ser.stopbits = STOPBITS_ONE
        self.ser.bytesize = EIGHTBITS


    def read_for(self, what):
#         logging.debug(what)
        for i in range(3):
            readed = self.ser.read(1000)
#             logging.debug(readed)
#             if readed == what:
            if what in readed:
                break
        else:
            raise MotorsSerialException


class Motor:
    def __init__(self, serial):
        self.ser = serial
        self.curren_coordinate = 0


    def go(self, delta):
        logging.debug(delta)
        self.curren_coordinate += delta
#         logging.debug(self.curren_coordinate)
#         logging.debug(bytes(f'g0x{self.curren_coordinate}\r\n', 'utf-8'))
        self.ser.write(bytes(f'g0x{self.curren_coordinate}\r\n', 'utf-8'))
        self.ser.read_for(b'ok\r\nok\r\n')
        self.wait_for_end_move()


    def wait_for_end_move(self):
        last_timeout = self.ser.ser.timeout
        self.ser.ser.timeout  = 0.01   #make sure that the alive event can be checked from time to time
        while True:
            self.ser.write(b'$#\r\n')
            try:
                self.ser.read_for(b'error: Not idle')
            except MotorsSerialException:
                break
        self.ser.ser.timeout  = last_timeout   #make sure that the alive event can be checked from time to time


class Motors:
    def __init__(self):
        self.ser = Ser(port='/dev/ttyUSB0', debug_mode=True)
        self.ser.read_for(b"\r\nGrbl 0.9j ['$' for help]\r\n")

        motor1 = Motor(self.ser)
        motor2 = Motor(self.ser)

#         while True:
#             motor1.go(100)
#             motor1.go(-100)
