
## Setup

必要なパッケージのインストール
See [setup.sh](./setup.sh)

USBマイクが認識されているかどうかを確認する。

```
# USBマイクを挿していないとき
pi@raspberrypi:~/scripts/thermometer $ lsusb
Bus 001 Device 003: ID 0424:ec00 Standard Microsystems Corp. SMSC9512/9514 Fast EthernetAdapter
Bus 001 Device 002: ID 0424:9514 Standard Microsystems Corp.
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

# USBマイクを挿しているとき
pi@raspberrypi:~/scripts/thermometer $ lsusb
Bus 001 Device 005: ID 0d8c:0016 C-Media Electronics, Inc.  # <--- これ
Bus 001 Device 003: ID 0424:ec00 Standard Microsystems Corp. SMSC9512/9514 Fast EthernetAdapter
Bus 001 Device 002: ID 0424:9514 Standard Microsystems Corp.
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

挿したUSBマイクをプライマリの入力デバイスとして設定する。

```
$ arecord -l
**** List of CAPTURE Hardware Devices ****
card 1: Micophone [USB Micophone], device 0: USB Audio [USB Audio]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```

上記の出力からcard:1, subdevice:0ということがわかる。なので、`ALSADEV`を以下の様に設定する。

```
$ export ALSADEV="plughw:1,0"
```

## マイクボリュームの調整

```
# 確認
$ amixer sget Mic -c 1
Simple mixer control 'Mic',0
  Capabilities: cvolume cvolume-joined cswitch cswitch-joined
  Capture channels: Mono
  Limits: Capture 0 - 62
  Mono: Capture 50 [81%] [16.59dB] [on]

# 調整
$ amixer sset Mic 10 -c 1
Simple mixer control 'Mic',0
  Capabilities: cvolume cvolume-joined cswitch cswitch-joined
  Capture channels: Mono
  Limits: Capture 0 - 62
  Mono: Capture 10 [16%] [-3.09dB] [on]

# もう1度確認
$ amixer sget Mic -c 1
Simple mixer control 'Mic',0
  Capabilities: cvolume cvolume-joined cswitch cswitch-joined
  Capture channels: Mono
  Limits: Capture 0 - 62
  Mono: Capture 10 [16%] [-3.09dB] [on]
```

## 録音

```
$ arecord -M -d5 -twav -fdat /tmp/test.wav -D plughw:1
Recording WAVE '/tmp/test.wav' : Signed 16 bit Little Endian, Rate 48000 Hz, Stereo
```

出力ファイル名（上の例だと`/tmp/test.wav`）は毎回変える必要がある。

## 再生

イヤホンを挿して`aplay -l`を実行する。

```
$ aplay -l
**** List of PLAYBACK Hardware Devices ****
card 0: ALSA [bcm2835 ALSA], device 0: bcm2835 ALSA [bcm2835 ALSA]
  Subdevices: 8/8
  Subdevice #0: subdevice #0
  Subdevice #1: subdevice #1
  Subdevice #2: subdevice #2
  Subdevice #3: subdevice #3
  Subdevice #4: subdevice #4
  Subdevice #5: subdevice #5
  Subdevice #6: subdevice #6
  Subdevice #7: subdevice #7
card 0: ALSA [bcm2835 ALSA], device 1: bcm2835 ALSA [bcm2835 IEC958/HDMI]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```

上記の出力からcard:0, subdevice:0ということがわかる。よって以下の様に実行すると録音した音声ファイルが再生される。

```
$ aplay -Dhw:0,0 /tmp/test.wav
```

## soundmeterの設定

[soundmeter]はsetup.shでインストール済みのはず。そのまま使うと例外が出てしまうので、調整が必要となる。

設定は`~/.soundmeter/config`に書けば良い。今回は以下のようにした。

```ini
[soundmeter]
channels = 1
frames_per_buffer = 512
```

### IOError: [Errno -9998] Invalid number of channels

`channels = 1`で解決できるのは以下の例外である。

```
$ soundmeter
Expression 'parameters->channelCount <= maxChans' failed in 'src/hostapi/alsa/pa_linux_alsa.c', line: 1514
Expression 'ValidateParameters( inputParameters, hostApi, StreamDirection_In )' failed in 'src/hostapi/alsa/pa_linux_alsa.c', line: 2818
Traceback (most recent call last):
  File "/usr/local/bin/soundmeter", line 9, in <module>
    load_entry_point('soundmeter==0.1.3', 'console_scripts', 'soundmeter')()
  File "/usr/local/lib/python2.7/dist-packages/soundmeter/meter.py", line 310, in main
    m = Meter(**kwargs)
  File "/usr/local/lib/python2.7/dist-packages/soundmeter/meter.py", line 66, in __init__
    frames_per_buffer=FRAMES_PER_BUFFER)
  File "/usr/local/lib/python2.7/dist-packages/pyaudio.py", line 750, in open
    stream = Stream(self, *args, **kwargs)
  File "/usr/local/lib/python2.7/dist-packages/pyaudio.py", line 441, in __init__
    self._stream = pa.open(**arguments)
IOError: [Errno -9998] Invalid number of channels
```

### IOError: [Errno -9981] Input overflowed

`frames_per_buffer = 512`で解決できるのは以下の例外である。

```
$ soundmeter
Traceback (most recent call last):
  File "/usr/local/bin/soundmeter", line 9, in <module>
    load_entry_point('soundmeter==0.1.3', 'console_scripts', 'soundmeter')()
  File "/usr/local/lib/python2.7/dist-packages/soundmeter/meter.py", line 311, in main
    m.start()
  File "/usr/local/lib/python2.7/dist-packages/soundmeter/meter.py", line 116, in start
    self.record()  # Record stream in `AUDIO_SEGMENT_LENGTH' long
  File "/usr/local/lib/python2.7/dist-packages/soundmeter/meter.py", line 90, in record
    data = self.stream.read(FRAMES_PER_BUFFER)
  File "/usr/local/lib/python2.7/dist-packages/pyaudio.py", line 608, in read
    return pa.read_stream(self._stream, num_frames, exception_on_overflow)
IOError: [Errno -9981] Input overflowed
```

## Reference

- [Raspberry PIとUSBマイクとMackerelを組み合わせて、室内の騒音レベルを可視化する](http://ariarijp.hatenablog.com/entry/2016/07/17/232752)
- [Raspberry Piで音声認識](http://qiita.com/t_oginogin/items/f0ba9d2eb622c05558f4)
- [Raspberry Pi3を音声操作する方法① USBマイクで音声を録音する](http://kyochika-labo.hatenablog.com/entry/RaspberryPi_record_voice)
