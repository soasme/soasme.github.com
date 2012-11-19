---
layout: post
category: technology
tags: [audio]
---

使用alsa播放声音
=====

    ➜  minimad  ./snd 
    ALSA lib pcm_hw.c:1401:(_snd_pcm_hw_open) Invalid value for card
    Error opening PCM device plughw:0,0, retcode: -2
    ➜  minimad  ls /dev/snd -l
    total 0
    drwxr-xr-x 2 root root       60 Nov 11  2012 by-path
    crw-rw---T 1 root audio 116,  7 Nov 11  2012 controlC0
    crw-rw---T 1 root audio 116,  6 Nov 11  2012 hwC0D0
    crw-rw---T 1 root audio 116,  5 Nov 11  2012 pcmC0D0c
    crw-rw---T 1 root audio 116,  4 Nov 11  2012 pcmC0D0p
    crw-rw---T 1 root audio 116,  3 Nov 11  2012 pcmC0D1c
    crw-rw---T 1 root audio 116,  2 Nov 11  2012 pcmC0D1p
    crw-rw---T 1 root audio 116,  1 Nov 11  2012 seq
    crw-rw---T 1 root audio 116, 33 Nov 11  2012 timer
    ➜  minimad  sudo ./snd
    ➜  minimad  ./snd
    ALSA lib pcm_hw.c:1401:(_snd_pcm_hw_open) Invalid value for card
    Error opening PCM device plughw:0,0, retcode: -2
    ➜  minimad  sudo ./snd

    ➜  minimad cd /dev/snd
    ➜  snd  sudo chown vagrant:vagrant *
    ➜  snd  ls -l
    total 0
    drwxr-xr-x 2 vagrant vagrant      60 Nov 11  2012 by-path
    crw-rw---T 1 vagrant vagrant 116,  7 Nov 11  2012 controlC0
    crw-rw---T 1 vagrant vagrant 116,  6 Nov 11  2012 hwC0D0
    crw-rw---T 1 vagrant vagrant 116,  5 Nov 11  2012 pcmC0D0c
    crw-rw---T 1 vagrant vagrant 116,  4 Nov 11  2012 pcmC0D0p
    crw-rw---T 1 vagrant vagrant 116,  3 Nov 11  2012 pcmC0D1c
    crw-rw---T 1 vagrant vagrant 116,  2 Nov 11  2012 pcmC0D1p
    crw-rw---T 1 vagrant vagrant 116,  1 Nov 11  2012 seq
    crw-rw---T 1 vagrant vagrant 116, 33 Nov 11  2012 time
    ➜  minimad  ./snd
