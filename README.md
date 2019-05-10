<div align=center>
    <a target="_blank" href="https://travis-ci.org/cdoco/grank" title="platform">
    	<img src="https://img.shields.io/badge/platform-win--32%20%7C%20win--64-lightgrey.svg">
    </a>
    <a target="_blank" href="https://github.com/qijianjun/qiniu-image-tool-win/archive/v2.2.zip" title="download">
    	<img src="https://img.shields.io/badge/download-821.1K%20v2.2-yellowgreen.svg">
    </a>
    <a target="_blank" href="https://opensource.org/licenses/MIT" title="License: MIT">
    	<img src="https://img.shields.io/badge/License-MIT-blue.svg">
    </a>
</div>


---

![](https://raw.githubusercontent.com/jiwenxing/qimage-win/master/res/qimge.png)

# About

qimage-win 是 windows 版本的 markdown 一键贴图工具，支持本地文件、截图及网络图片一键上传七牛云，并粘贴资源链接至当前编辑器，使用简单方便，从此 markdown 中贴图成为一种享受。

# Fork后更新

## 关键特性

- 支持上传类型：本地文件、剪切板上的图片对象（截图、从网页复制的图片等）、http链接；
- 支持保存路径：自定义路径前缀，可按时间自动命名，或手动修改远程保存路径；
- 其它：自定义粘贴格式，记录历史上传的全部文件信息；

## 使用步骤
- 下载并解压程序，使用`qimage.exe`，如果你已安装`autohotkey`，可执行`qimage.ahk`；
- 下载`qshell`（详后），将所需版本命名为`qshell.exe`保存在此程序目录下，或放在$PATH搜索路径下；
- 修改配置文件`settings.ini`，具体看文件内注释；
- 执行exe或ahk程序，`Ctrl+Alt+V`是上传并获取链接，`Ctrl+Shift+V`是修改确认保存路径后，上传并获取链接；

## TODO
- 提供窗口查看最近上传的N条资料，若为图片且本地有保存，提供悬浮预览

## 更新日志

### 2019-05-10
- 要求管理员权限，以避免powershell脚本将内存中的图片保存为本地临时文件时发生权限错误
- 支持Esc退出自定义路径的窗口

### 2019-05-03

- 适配新版qshell更改后的`account`/`fput`命令；
- 若上传失败报错，不覆写粘贴板；
- 支持key前缀（存储在默认子路径）；
- 支持自定义存储路径/文件名（保持源文件的路径文件名，或修改后上传）；
- 支持自定义格式的粘贴文本，如markdown、html、bbcode等；
- 支持`fetch`命令远程下载网络图片，即复制网址后直接上传，无须先将文件存储在本地；
- 识别剪切板类型，确保为可操作的对象类型，检测排除多行文本；
- 变量命名等一些语义修改，以及去除个别冗余代码；
- 支持日志，保存`源文件路径-CDN路径-时间-hash-filesize-mimetype`信息；

## qshell下载
仓库中不再包含qshell，请从以下链接自行最新版本：

<a href="http://devtools.qiniu.com/qshell-v2.3.6.zip">qshell v2.3.6官方链接 | 含Mac OSX, Linux, Windows各版本的压缩包</a>

如果官方下载速度慢，可从以下链接下载解压后的windows版执行文件：

<a href="https://eagent.ctfile.com/fs/20035996-371697665" target="_blank">qshell_windows_x64_v2.3.6.exe</a>

<a href="https://eagent.ctfile.com/fs/20035996-371697707" target="_blank">qshell_windows_x86_v2.3.6.exe</a>

↓↓↓以下↓↓↓为<a href="https://github.com/jiwenxing/qimage-win" target="_blank">原版</a>说明。

---

# Usage

目前已更新到2.x版本，极大的简化了使用方法，详细请参考：[windows版本markdown一键贴图工具](http://jverson.com/2017/05/28/qiniu-image-v2/)

mac版本请移步至：https://github.com/jiwenxing/qiniu-image-tool

# Features
- 支持各种图片格式上传
- 支持截图及网络图片直接复制上传
- 支持包括js、css、视频等各种其它格式本地文件上传
- AutoHotkey开放源码，完全免费
- 安装使用非常简单

# Requirements
**`qshell`**  **`七牛账号`**

# Preview
1. 本地图片文件上传 <br/>
![](https://github.com/jiwenxing/qiniu-image-tool-win/blob/master/res/local.gif?raw=true)

2. 截图上传  <br/>
![](https://github.com/jiwenxing/qiniu-image-tool-win/blob/master/res/screenshot.gif?raw=true)

3. 其它文件上传  <br/>
![](https://raw.githubusercontent.com/jiwenxing/qiniu-image-tool-win/master/res/file.gif)


注：演示gif使用wiznote及licecap制作



# License
[MIT License](https://github.com/jiwenxing/qiniu-image-tool-win/blob/master/LICENSE).
Copyright (c) 2017 Jverson