/*
qiniu-image-tool.ahk

a small tool that help you upload local image or screenshot to qiniu cloud and get the markdown-style
url in clipboard as well as your current editor. actually you can upload any file by this script.

github: https://github.com/jiwenxing/qimage-win

CHANGE LOG
 2.1 -- 2018/01 -- add an optional config to support user-defined qiniu image style
 2.0 -- 2017/04 -- screenshot & image copy from web both supported
 1.0 -- 2016/08 -- basic function realized, only local files supported.

----- 以上为fork前信息 -----

2019-05-03
适应新版qshell更改后的account/fput命令；
若上传失败报错，不覆写粘贴板；
支持key前缀（存储在默认子路径）；
支持自定义存储路径/文件名（保持源文件的路径文件名，或修改后上传）；
支持自定义格式的粘贴文本，如markdown、html、bbcode等；
支持fetch命令远程下载网络图片，即复制网址后直接上传，无须先将文件存储在本地；
识别剪切板类型，确保为可操作的对象类型，检测排除多行文本；
变量命名等一些语义修改，以及去除个别冗余代码；
支持日志，保存源文件路径-CDN路径-时间-hash-filesize-mimetype信息；
*/

WORKING_DIR = %A_ScriptDir%\
SetWorkingDir, %WORKING_DIR%
Menu,Tray,Icon, qimage.ico, , 1

^+V::
^!V::

    IfNotExist, settings.ini
    {
        MsgBox settings.ini not found.
        Return
    }

    IniRead, ACCESS_KEY, settings.ini, settings, ACCESS_KEY
    IniRead, SECRET_KEY, settings.ini, settings, SECRET_KEY
    IniRead, USERNAME, settings.ini, settings, USERNAME
    IniRead, BUCKET_NAME, settings.ini, settings, BUCKET_NAME
    IniRead, BUCKET_DOMAIN, settings.ini, settings, BUCKET_DOMAIN
    IniRead, PASTE_FORMAT, settings.ini, img, PASTE_FORMAT
    IniRead, BUCKET_PATH, settings.ini, optional, BUCKET_PATH
    IniRead, UP_HOST, settings.ini, optional, UP_HOST
    IniRead, DEBUG_MODE, settings.ini, optional, DEBUG_MODE
    IniRead, STYLE_SUFFIX, settings.ini, optional, STYLE_SUFFIX
    ; suffix
    BUCKET_DOMAIN = %BUCKET_DOMAIN%/
    if (STYLE_SUFFIX!="")
        STYLE_SUFFIX = ?%STYLE_SUFFIX%
    ; debug mode
    isDebug = /c
    if (DEBUG_MODE="true")
        isDebug = /k

    ; url or localpath, verify local path
    if (Clipboard) {
        srcpath := Clipboard
        if InStr(srcpath, "`n") {
            MsgBox, Multilines in Clipboard, please check!
            Return
        }
        isFetch := RegExMatch(srcpath, "https?://.*?([^/?]+)(\?.*)?$", http_matches) ? 1 : 0
        if (isFetch == 0 && !FileExist(srcpath)) {
            MsgBox, % Format("file {:s} not exist", srcpath)
            Return
        }
    } else if DllCall("IsClipboardFormatAvailable", "Uint", 2) {
    	;2:CF_BITMAP
        srcpath := "ScreenShot"
    } else {
    	MsgBox, Unknown Clipboard format
    	return
    }

    ; name the file
    if (A_ThisHotkey == "^+V" && srcpath) {
        if (isFetch) {
            filepath := http_matches1
        } else {
            filepath := SubStr(StrReplace(srcpath, "\", "/", replaceCount), 4)
        }
        Gosub, PromptName
        WinWait, 指定云上文件的保存路径
        WinWaitClose
        StringSplit, ColorArray, filepath, `.  ; split by '.'
        maxIndex := ColorArray0  ; get array lenth
        ;;;;; get file type by extension
        if (maxIndex == 1) {
            fileType := ""
            filePrefix := filepath
        } else {
            fileType := ColorArray%maxIndex%  ; get last element of array, namely file type or file extension
            filePrefix := StrReplace(filepath, "." . fileType, "")
        }
    } else {
        ;;;; datetime+randomNum as file name prefix
        Random, rand, 1, 1000
        filePrefix =  %A_yyyy%%A_MM%%A_DD%%A_Hour%%A_Min%_%rand%
        fileType := "png"
    }
    if (isFetch == 1) {
        Gosub, AddUser
        key := Trim(BUCKET_PATH . filePrefix . "." . fileType, " `t./\")
        RunWait, %comspec% %isDebug% qshell user cu %USERNAME% && qshell fetch "%srcpath%" %BUCKET_NAME% -k %key% > qimage-result.txt
        if (check_result("fetch") == 0)
            Return
    } else if (srcpath) {
        ; MsgBox, probably file in srcpath
        key := Trim(BUCKET_PATH . filePrefix . "." . fileType, " `t./\")
        Gosub, AddUser
        ; To run multiple commands consecutively, use "&&" between each
        RunWait, %comspec% %isDebug% qshell user cu %USERNAME% && qshell fput %BUCKET_NAME% %key% %srcpath% -u %UP_HOST% > qimage-result.txt
        if (check_result("upload") == 0)
            Return
    } else {
        ; MsgBox, probably binary image in Clipboard
        key = %BUCKET_PATH%%filePrefix%.png
        filename = %filePrefix%.png
        tmpfile_path = %WORKING_DIR%%filename%
        ; MsgBox, %tmpfile_path%
        Gosub, AddUser
        ; here, thanks for https://github.com/octan3/img-Clipboard-dump
        RunWait, %comspec% %isDebug% powershell set-executionpolicy remotesigned && powershell -sta -f dump-Clipboard-png.ps1 %tmpfile_path% && qshell user cu %USERNAME% && qshell fput %BUCKET_NAME% %key% %tmpfile_path% -u %UP_HOST% > qimage-result.txt && del %tmpfile_path%
        if (check_result("upload") == 0)
            Return
    }

    ;;;; paste markdown format url to current editor
    resourceUrl = %BUCKET_DOMAIN%%key%%STYLE_SUFFIX%
    logline := Format("{:s}`t{:s}`t{:s}`t{:s}`t{:s}`t{:s}`n", srcpath, resourceUrl, A_Now, rfields1, rfields2, rfields4)
    FileAppend, %logline%, qimage-log.txt
    ; MsgBox, %resourceUrl%
    ; if image file
    if (fileType="jpg" or fileType="png" or fileType="gif" or fileType="bmp" or fileType="jpeg") {
        resourceUrl := Format(PASTE_FORMAT, resourceUrl)
    }
    ; MsgBox, %resourceUrl%
    Clipboard =  ; Empty the Clipboard.
    Clipboard = %resourceUrl%

    ; MsgBox %srcpath%
    Send ^v

Return

AddUser:
    If (!FileExist("qimage-user.txt")) {
        RunWait, %comspec% %isDebug% qshell user lookup %USERNAME% > qimage-user.txt
    }
    FileRead, user, qimage-user.txt
    if (InStr(user, Format("Name: {:s}", USERNAME)) != 0) {
        Return
    }
    RunWait, %comspec% %isDebug% qshell account %ACCESS_KEY% %SECRET_KEY% %USERNAME% && qshell user lookup %USERNAME% > qimage-user.txt
Return

PromptName:
Gui, Destroy
Gui, +AlwaysOnTop -SysMenu +Owner
Gui, Add, Text, , %BUCKET_DOMAIN%%BUCKET_PATH%
Gui, Add, Edit, vFilepath w400 ym, %filepath%
Gui, Add, Button, default gUpload, 确定上传
Gui, Show,, 指定云上文件的保存路径
Return

Upload:
Gui, Submit
Filepath := Trim(Filepath, " `t`n/")
Gui, destroy

check_result(action) {
    FileRead, result, qimage-result.txt
    global rfields
    r := RegExMatch(result, "Hash: (.*)\nFsize: (.*)\nMime(Type)?: (.*?)\n?", rfields)
    If (r == 0) {
        MsgBox, %action% failed!
    }
    Return r
}
