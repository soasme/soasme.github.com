---
layout: post
tags: mp3, mad, c
---

安装libmad
===

`libmad` 是一个解码 `mp3` 的开源库.

今天尝试了安装, 发现两三年没碰c, 手生了很多.  记录一下步骤

因为遇到了下面这样的报错:

    ➜  libmad-0.15.1b  make
    (sed -e '1s|.*|/*|' -e '1b' -e '$s|.*| */|' -e '$b'  \
            -e 's/^.*/ *&/' ./COPYRIGHT; echo;  \
        echo "# ifdef __cplusplus";  \
        echo 'extern "C" {';  \
        echo "# endif"; echo;  \
        if [ ".-DFPM_DEFAULT" != "." ]; then  \
            echo ".-DFPM_DEFAULT" | sed -e 's|^\.-D|# define |'; echo;  \
        fi;  \
        sed -ne 's/^# *define  *\(HAVE_.*_ASM\).*/# define \1/p'  \
            config.h; echo;  \
        sed -ne 's/^# *define  *OPT_\(SPEED\|ACCURACY\).*/# define OPT_\1/p'  \
            config.h; echo;  \
        sed -ne 's/^# *define  *\(SIZEOF_.*\)/# define \1/p'  \
            config.h; echo;  \
        for header in version.h fixed.h bit.h timer.h stream.h frame.h synth.h decoder.h; do  \
            echo;  \
            sed -n -f ./mad.h.sed ./$header;  \
        done; echo;  \
        echo "# ifdef __cplusplus";  \
        echo '}';  \
        echo "# endif") >mad.h
    make  all-recursive
    make[1]: Entering directory `/dou/tmp/libmad-0.15.1b'
    make[2]: Entering directory `/dou/tmp/libmad-0.15.1b'
    if /bin/bash ./libtool --mode=compile gcc -DHAVE_CONFIG_H -I. -I. -I. -DFPM_DEFAULT     -Wall -g -O -fforce-mem -fforce-addr -fthread-jumps -fcse-follow-jumps -fcse-skip-blocks -fexpensive-optimizations -fregmove -fschedule-insns2 -MT version.lo -MD -MP -MF ".deps/version.Tpo" -c -o version.lo version.c; \
        then mv -f ".deps/version.Tpo" ".deps/version.Plo"; else rm -f ".deps/version.Tpo"; exit 1; fi
    mkdir .libs
     gcc -DHAVE_CONFIG_H -I. -I. -I. -DFPM_DEFAULT -Wall -g -O -fforce-mem -fforce-addr -fthread-jumps -fcse-follow-jumps -fcse-skip-blocks -fexpensive-optimizations -fregmove -fschedule-insns2 -MT version.lo -MD -MP -MF .deps/version.Tpo -c version.c  -fPIC -DPIC -o .libs/version.o
    cc1: error: unrecognized command line option ‘-fforce-mem’
    make[2]: *** [version.lo] Error 1
    make[2]: Leaving directory `/dou/tmp/libmad-0.15.1b'

所以找到 congifure 里面的 -fforce-mem 选项并注释掉了。似乎作者并没有针对 `arm` 禁掉这个选项呢。

解决这个问题后

    ./configure
    make
    sudo make install

看到信息

    Libraries have been installed in:
       /usr/local/lib

欣慰了.

单独拿出 `minimad.c` 开个工程 

    ➜  minimad  gcc -o minimad minimad.c -l mad
    minimad.c: In function ‘error’:
    minimad.c:179:4: warning: format ‘%u’ expects argument of type ‘unsigned int’, but argument 5 has type ‘long int’ [-Wformat]

生成的binary报错:

    ./minimad: error while loading shared libraries: libmad.so.0: cannot open shared object file: No such file or director

亲, 欺负我真的大丈夫吗?

    ➜  minimad  sudo ldconfig /usr/local/lib
    ➜  minimad  ./minimad < ~/tmp/p1639263.mp3 > tmp.pcm
    ➜  minimad  ls
    minimad  minimad.c tmp.pcm
    ➜  minimad  ls -l
    -rwxrwxr-x 1 501 dialout    13195 Nov 10 16:15 minimad
    -rw-rw-r-- 1 501 dialout     5935 Nov 10 16:07 minimad.c
    -rw-rw-r-- 1 501 dialout 23954688 Nov 10 16:19 tmp.pcm

so 生成的pcm可以给设备直接播放了.
