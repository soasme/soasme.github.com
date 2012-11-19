---
layout: post
category: technology
tags: [iOS, game, lua]
---

使用lua开发iOS游戏
=====


由于 cocos2d-x 内置了 `lua engine` 这使得我们可以通过lua开发iOS游戏。

首先需要安装 cocos2d-x , 下载包以后 执行 install-template.sh 即可。启动xCode后新建 `cocos2dx_lua` 项目。

另外，需要安装 `ios-sim` , 可以 `brew install ios-sim`, 也可以直接从github上checkout下来安装。

新建好项目 `testlua` 后，选择虚拟机，编译。

从 `~/Library/Developer/Xcode/DerivedData/testlua-asftbziwkwijygeemeggirrjspoc/Build/Products/Debug-iphonesimulator/` 可以找到 `testlua.app` (这个地址自己灵活选定 DeriveData 后面是 项目名+一串字符), 复制到我们的开发目录, 比如 `~/work/game/` , 这是一个目录，所以可以用 `cp -R testlua.app ~/work/game` 来复制.

将以下脚本保存为 `serve.sh` 放在 `game` 下( 文件自动检查 `testlua.app` 中我们即将更新的脚本的更新并重启虚拟机中程序), 

    #!/usr/bin/php
    <?php

    if ($argc < 2)
    {
        print("usage: testapp.sh app\n");
        exit(1);
    }

    define("DS", DIRECTORY_SEPARATOR);

    $target = realpath(trim($argv[1]));
    $target_dir = dirname($target);
    $app_name = basename($target);
    $log_path = $target_dir.DS.$app_name.".log";
    print("Output to log file: ".$log_path."\n");

    $command = "ios-sim launch \"{$target}\" --sdk 6.0 --stderr \"${log_path}\" --stdout \"${log_path}\"";

    $hostProcHandle = openHost($command, $target);
    $line = str_repeat("-", 60) . "\n";

    while (true)
    {
        sleep(1);

        if ($hostProcHandle != false)
        {
            $status = proc_get_status($hostProcHandle);
            if ($status == false || $status["running"] == false)
            {
                // host 已经退出，在下一次更新文件后将重新启动 host
                $hostProcHandle = false;
                print("\n");
                print($line);
                print("HOST ENDED.\n");
                print($line);
                print("\n\n");
            }
        }

        $isUpdated = checkFilesUpdate($target);
        if ($isUpdated)
        {
            // 文件有变化时，重新启动 host
            if ($hostProcHandle != false) { proc_terminate($hostProcHandle); }
            print("\n");
            print($line);
            print("APP FILES UPDATED, RELAUNCH HOST.\n");
            print($line);
            print("\n\n");

            $hostProcHandle = openHost($command, $target);
        }
    }

    function openHost($command, $appSrcDir)
    {
        $descr = array();
        $pipes = array();
        return proc_open($command, $descr, $pipes, $appSrcDir, NULL);
    }

    function getFilesState($dir)
    {
        $state = array();
        $dir = rtrim(realpath($dir), "/\\") . DS;
        $dh = opendir($dir);
        if ($dh == false) { return $state; }

        while (($file = readdir($dh)) !== false)
        {
            if ($file{0} == ".") { continue; }

            $path = $dir . $file;
            if (is_dir($path))
            {
                $state = array_merge($state, getFilesState($path));
            }
            elseif (is_file($path))
            {
                $state[$path] = filemtime($path);
            }
        }
        closedir($dh);

        return $state;
    }


    // 检查指定目录下是否有文件发生改变（新增、删除、更新）
    function checkFilesUpdate($checkDir)
    {
        static $lastCheckDir;
        static $lastState;

        clearstatcache(true);
        $isUpdated = false;

        if ($lastCheckDir != $checkDir)
        {
            $lastCheckDir = $checkDir;
            $lastState = array();
        }

        $state = getFilesState($checkDir);
        if (!empty($lastState))
        {
            foreach ($state as $path => $mtime)
            {
                if (!isset($lastState[$path]) || $lastState[$path] != $mtime)
                {
                    $isUpdated = true;
                    break;
                }
                unset($lastState[$path]);
            }
            if (!empty($lastState)) { $isUpdated = true; }
        }
        $lastState = $state;

        return $isUpdated;
    }


执行:

    ./serve.sh testlua.app

此时，不仅虚拟机已经运行起了游戏画面，我们还可以看到 `serve.sh` 的输出:


    Output to log file: ~/work/game/testlua.app.log

另开一个窗口我们可以监控log:

    tail -f ~/work/game/testlua.app.log

ok, 再开一个窗口 我们可以编辑 `testlua.app/hello.lua` 开始游戏之旅了!
