@SET  logrartitle=日志文件压缩备份工具 LOG-RAR 0.3


@REM 0.3, 2017-01-04, same.
@REM   新增：按年和月分子目录。
@REM   修正：处理月和日加0变双位数时会依赖系统短日期格式的问题。
@REM   修正：未指定rar路径导致指定工作目录时找不到rar的问题。
@REM 0.2, 2016-12-25, same.
@REM   新增：支持对单一不分日期的日志文件每天压缩存储多个版本，目前为存储最多100个。
@REM   新增：支持对单一不分日期的日志文件改名后立即初始化，尽量避免丢失日志的风险，一般情况下也可以免掉 log-init.lst 了。
@REM 0.1, 2016-12-24, same.
@REM   新增：支持初始化日志文件清单 log-init.lst
@REM 0.0, 2016-12-23, same.
@REM   初始版本。


@ECHO %logrartitle%


@IF "%1"=="/?" (
    @ECHO log-rar [path] [sep]
    @ECHO 	path	待压缩备份日志文件所在路径，默认为当前目录。
    @ECHO 	sep	待压缩备份日志文件名中的日期分隔符，默认为减号（-）。

    @ECHO 例如：
    @ECHO log-rar C:\AppServer

    @ECHO 	就会压缩 C:\AppServer\log-rar.lst 里列出的大小超过8192字节的文件到
    @ECHO 	C:\AppServer\log-bak\[year]\[month] 子目录里，并删除原文件。大小未超过8192字节的，
    @ECHO 	则直接移动到 C:\AppServer\log-bak\[year]\[month] 子目录里。
    @ECHO 	如找不到文件，则加上当前年份前缀（如：2016-），再试一次。

    @ECHO log-rar.lst 例子（每日按 yyyy-mm-dd.log 文件名格式保存的日志，已省略年份）：
    @ECHO 	01-01.log
    @ECHO 	01-02.log
    @ECHO 	... ...
    @ECHO 	12-31.log

    @GOTO END
)


@ECHO OFF

REM -- 校验是否已指定目录参数
IF "%1"=="" (SET wd=.) ELSE (SET wd=%1)

REM -- 校验是否存在 rar.exe
IF NOT EXIST %wd%\rar.exe (GOTO MISS_RAR)

REM -- 校验是否已指定日志文件名日期间隔参数，默认为减号(-)
SET sep=-
IF NOT "%2"=="" (SET sep=%2)

REM -- 获取当前年份前缀，结果如: 2016-
FOR /F "usebackq delims=- tokens=1,*" %%i IN (`DATE /T`) DO (
    SET year=%%i
    IF NOT "%%j"=="" (SET datesep=-)
)
FOR /F "delims=/ tokens=1,*" %%i IN ("%year%") DO (
    SET year=%%i
    IF NOT "%%j"=="" (SET datesep=/)
)
FOR /F "delims=. tokens=1,*" %%i IN ("%year%") DO (
    SET year=%%i
    IF NOT "%%j"=="" (SET datesep=.)
)
SET year=%year%%sep%

IF "%datesep%"=="" GOTO UNKNOWN_DATE_SEP

REM -- 获取当天日志文件名，以排除当天日志
FOR /F "usebackq tokens=1" %%D IN (`DATE /T`) DO (
    FOR /F "delims=%datesep% tokens=1,2,3" %%i IN ("%%D") DO (
        SET y=%%i
        SET m=%%j
        SET d=%%k
    )
)
IF /I 1%m% LSS 100 (SET m=0%m%)
IF /I 1%d% LSS 100 (SET d=0%d%)


REM -- *** 在这里修改日志文件名格式todaylog ***
REM -- 例如：
REM SET todaylog=%y%%sep%%m%%sep%%d%.log
REM -- *** 这是华夏动力应用服务器的日志格式 ***
SET todaylog=mawas.log.%m%.%d%.txt


REM -- 单一的需改名的日志文件前缀
SET prefixren=%y%%m%%d%_


REM -- 校验是否存在 log-rar.lst 日志清单文件
IF NOT EXIST %wd%\log-rar.lst (GOTO MISS_LIST)

REM -- 如果不存在，则创建 log-bak 子目录
IF NOT EXIST %wd%\log-bak (mkdir %wd%\log-bak)

REM -- 如果不存在，则创建 log-bak\[year] 子目录
IF NOT EXIST %wd%\log-bak\%y% (mkdir %wd%\log-bak\%y%)

REM -- 如果不存在，则创建 log-bak\[year]\[month] 子目录
IF NOT EXIST %wd%\log-bak\%y%\%m% (mkdir %wd%\log-bak\%y%\%m%)

REM -- 压缩 log-rar.lst 里列出的大小超过 8192 字节的文件到 log-bak\[year]\[month] 子目录里，并删除原文件(-df)，或放入回收站(将-df换成-dr)
REM -- 如找不到文件，则加上年份前缀再试一次
FOR /F "TOKENS=1" %%f IN (%wd%\log-rar.lst) DO  IF EXIST %wd%\%%f  (
        IF NOT "%%f"=="%todaylog%" (%wd%\rar a -df -ep1 -sm8192  %wd%\log-bak\%y%\%m%\%%f.rar  %wd%\%%f)
    ) ELSE IF EXIST %wd%\%year%%%f  (
        IF NOT "%year%%%f"=="%todaylog%" (%wd%\rar a -df -ep1 -sm8192  %wd%\log-bak\%y%\%m%\%year%%%f.rar  %wd%\%year%%%f)
    )

REM -- 移动 log-rar.lst 里列出的文件到 log-bak\[year]\[month] 子目录里，如上一步骤里大小未超过8192字节而未被压缩的
FOR /F "TOKENS=1" %%f IN (%wd%\log-rar.lst) DO  IF EXIST %wd%\%%f  (
        IF NOT "%%f"=="%todaylog%" (move /y  %wd%\%%f  %wd%\log-bak\%y%\%m%\%%f)
    ) ELSE IF EXIST %wd%\%year%%%f  (
        IF NOT "%year%%%f"=="%todaylog%" (move /y  %wd%\%year%%%f  %wd%\log-bak\%y%\%m%\%year%%%f)
    )


:RENAME_LOG
REM -- 处理单一的，不分日期的日志文件
REM -- 支持每天最多压缩次数（版本），由[-verNN]配置，如[-ver48]，可支持每隔半小时压缩一次的频率
REM -- 校验是否存在 log-ren-rar.lst 日志清单文件
IF NOT EXIST %wd%\log-ren-rar.lst (GOTO INIT_LOG)

FOR /F "TOKENS=1" %%f IN (%wd%\log-ren-rar.lst) DO  IF EXIST %wd%\%%f  (
        REM 文件超过一定大小才处理
        IF /I %%~zf GEQ 1048576  (
            rename %wd%\%%f %prefixren%%%f
            REM 请参看后面的 INIT_LOG 说明。这里直接初始化是为避免出现改名后与压缩完成前之间的日志存在丢失风险的问题
            FOR /F "usebackq tokens=1" %%D IN (`DATE /T`) DO FOR /F "usebackq tokens=1" %%T IN (`TIME /T`) DO (
                ECHO -- %%D %%T %logrartitle% >> %wd%\%%f
            )
            %wd%\rar a -df -ep1 -ver100 %wd%\log-bak\%y%\%m%\%prefixren%%%f.rar  %wd%\%prefixren%%%f
        )
    ) ELSE IF EXIST %wd%\%prefixren%%%f  (
            %wd%\rar a -df -ep1 -ver100 %wd%\log-bak\%y%\%m%\%prefixren%%%f.rar  %wd%\%prefixren%%%f
    )


:INIT_LOG
REM -- 某些单一的，不分日期的日志文件删除后需要新建一个空的，否则备份之后需写入的日志会被丢弃，如awmm.log
REM -- 校验是否存在 log-init.lst 日志清单文件
IF NOT EXIST %wd%\log-init.lst (GOTO DONE)

FOR /F "TOKENS=1" %%f IN (%wd%\log-init.lst) DO  IF NOT EXIST %wd%\%%f  (
        FOR /F "usebackq tokens=1" %%D IN (`DATE /T`) DO FOR /F "usebackq tokens=1" %%T IN (`TIME /T`) DO (
            ECHO -- %%D %%T %logrartitle% >> %wd%\%%f
        )
    )


GOTO DONE


:MISS_RAR
ECHO !!! 日志文件压缩备份失败 !!!
ECHO !!! 不存在 RAR :  %wd%\rar.exe
ECHO 提示：这里使用的 rar.exe 为 winrar 的命令行工具，可以在 winrar 的安装目录里找到，请尽量使用最新版本。
GOTO END


:MISS_LIST
IF EXIST %wd%\log-ren-rar.lst (
    ECHO !!! 不存在待处理日志清单文件: %wd%\log-rar.lst
    GOTO RENAME_LOG
)
ECHO !!! 日志文件压缩备份失败 !!!
ECHO !!! 不存在待处理日志清单文件: %wd%\log-rar.lst 或 log-ren-rar.lst
IF EXIST %wd%\log-init.lst (
    rem 只需处理备份后的初始化，不应该直接初始化吧！
    rem GOTO INIT_LOG
)
GOTO END


:UNKNOWN_DATE_SEP
ECHO !!! 日志文件压缩备份失败 !!!
ECHO !!! 不支持的系统日期分隔符，目前支持-/.三种
GOTO END


:DONE
ECHO 完成。

:END
