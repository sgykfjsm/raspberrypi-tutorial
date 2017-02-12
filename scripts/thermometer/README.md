# 温度計とLCDの回路設定

## 回路設定

| LCD (FC-113) | Sensor (DHT11) | Board | Breadboard | Wire |
|:------------:|:--------------:|:------:|:----------:|:---------:|
| GND | - | - | -9 | オス-メス |
| VCC | - | - | +8 | オス-メス |
| SDA | - | SDA1 | - | メス-メス |
| SCL | - | SCL1 | - | メス-メス |
| - | GND | - | -6 | オス-メス |
| - | DATA | GPIO04 | - | メス-メス |
| - | VCC | - | +4 | オス-メス |
| - | - | 5VO | +2 | オス-メス |
| - | - | GPIO21 | -1 | オス-メス |

## Setup

See [install_i2c.sh](install_i2c.sh)

Confirm the address

```
pi@raspberrypi:~/scripts/thermometer $ i2cdetect -y 1
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- --
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
20: -- -- -- -- -- -- -- 27 -- -- -- -- -- -- -- --
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
70: -- -- -- -- -- -- -- --
```

In above case, you should change like following:

```
# Before
# I2C_ADDR = 0x3f

# After
I2C_ADDR = 0x27
```

Confirm the position of sensor. In my case, I use GPIO4.

```
Temp_sensor = 4
```

## Run

```
$ python ./pi-dht11-i2clcd.py
```
