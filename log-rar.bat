@SET  logrartitle=��־�ļ�ѹ�����ݹ��� LOG-RAR 0.3


@REM 0.3, 2017-01-04, same.
@REM   ������������·���Ŀ¼��
@REM   �����������º��ռ�0��˫λ��ʱ������ϵͳ�����ڸ�ʽ�����⡣
@REM   ������δָ��rar·������ָ������Ŀ¼ʱ�Ҳ���rar�����⡣
@REM 0.2, 2016-12-25, same.
@REM   ������֧�ֶԵ�һ�������ڵ���־�ļ�ÿ��ѹ���洢����汾��ĿǰΪ�洢���100����
@REM   ������֧�ֶԵ�һ�������ڵ���־�ļ�������������ʼ�����������ⶪʧ��־�ķ��գ�һ�������Ҳ������� log-init.lst �ˡ�
@REM 0.1, 2016-12-24, same.
@REM   ������֧�ֳ�ʼ����־�ļ��嵥 log-init.lst
@REM 0.0, 2016-12-23, same.
@REM   ��ʼ�汾��


@ECHO %logrartitle%


@IF "%1"=="/?" (
    @ECHO log-rar [path] [sep]
    @ECHO 	path	��ѹ��������־�ļ�����·����Ĭ��Ϊ��ǰĿ¼��
    @ECHO 	sep	��ѹ��������־�ļ����е����ڷָ�����Ĭ��Ϊ���ţ�-����

    @ECHO ���磺
    @ECHO log-rar C:\AppServer

    @ECHO 	�ͻ�ѹ�� C:\AppServer\log-rar.lst ���г��Ĵ�С����8192�ֽڵ��ļ���
    @ECHO 	C:\AppServer\log-bak\[year]\[month] ��Ŀ¼���ɾ��ԭ�ļ�����Сδ����8192�ֽڵģ�
    @ECHO 	��ֱ���ƶ��� C:\AppServer\log-bak\[year]\[month] ��Ŀ¼�
    @ECHO 	���Ҳ����ļ�������ϵ�ǰ���ǰ׺���磺2016-��������һ�Ρ�

    @ECHO log-rar.lst ���ӣ�ÿ�հ� yyyy-mm-dd.log �ļ�����ʽ�������־����ʡ����ݣ���
    @ECHO 	01-01.log
    @ECHO 	01-02.log
    @ECHO 	... ...
    @ECHO 	12-31.log

    @GOTO END
)


@ECHO OFF

REM -- У���Ƿ���ָ��Ŀ¼����
IF "%1"=="" (SET wd=.) ELSE (SET wd=%1)

REM -- У���Ƿ���� rar.exe
IF NOT EXIST %wd%\rar.exe (GOTO MISS_RAR)

REM -- У���Ƿ���ָ����־�ļ������ڼ��������Ĭ��Ϊ����(-)
SET sep=-
IF NOT "%2"=="" (SET sep=%2)

REM -- ��ȡ��ǰ���ǰ׺�������: 2016-
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

REM -- ��ȡ������־�ļ��������ų�������־
FOR /F "usebackq tokens=1" %%D IN (`DATE /T`) DO (
    FOR /F "delims=%datesep% tokens=1,2,3" %%i IN ("%%D") DO (
        SET y=%%i
        SET m=%%j
        SET d=%%k
    )
)
IF /I 1%m% LSS 100 (SET m=0%m%)
IF /I 1%d% LSS 100 (SET d=0%d%)


REM -- *** �������޸���־�ļ�����ʽtodaylog ***
REM -- ���磺
REM SET todaylog=%y%%sep%%m%%sep%%d%.log
REM -- *** ���ǻ��Ķ���Ӧ�÷���������־��ʽ ***
SET todaylog=mawas.log.%m%.%d%.txt


REM -- ��һ�����������־�ļ�ǰ׺
SET prefixren=%y%%m%%d%_


REM -- У���Ƿ���� log-rar.lst ��־�嵥�ļ�
IF NOT EXIST %wd%\log-rar.lst (GOTO MISS_LIST)

REM -- ��������ڣ��򴴽� log-bak ��Ŀ¼
IF NOT EXIST %wd%\log-bak (mkdir %wd%\log-bak)

REM -- ��������ڣ��򴴽� log-bak\[year] ��Ŀ¼
IF NOT EXIST %wd%\log-bak\%y% (mkdir %wd%\log-bak\%y%)

REM -- ��������ڣ��򴴽� log-bak\[year]\[month] ��Ŀ¼
IF NOT EXIST %wd%\log-bak\%y%\%m% (mkdir %wd%\log-bak\%y%\%m%)

REM -- ѹ�� log-rar.lst ���г��Ĵ�С���� 8192 �ֽڵ��ļ��� log-bak\[year]\[month] ��Ŀ¼���ɾ��ԭ�ļ�(-df)����������վ(��-df����-dr)
REM -- ���Ҳ����ļ�����������ǰ׺����һ��
FOR /F "TOKENS=1" %%f IN (%wd%\log-rar.lst) DO  IF EXIST %wd%\%%f  (
        IF NOT "%%f"=="%todaylog%" (%wd%\rar a -df -ep1 -sm8192  %wd%\log-bak\%y%\%m%\%%f.rar  %wd%\%%f)
    ) ELSE IF EXIST %wd%\%year%%%f  (
        IF NOT "%year%%%f"=="%todaylog%" (%wd%\rar a -df -ep1 -sm8192  %wd%\log-bak\%y%\%m%\%year%%%f.rar  %wd%\%year%%%f)
    )

REM -- �ƶ� log-rar.lst ���г����ļ��� log-bak\[year]\[month] ��Ŀ¼�����һ�������Сδ����8192�ֽڶ�δ��ѹ����
FOR /F "TOKENS=1" %%f IN (%wd%\log-rar.lst) DO  IF EXIST %wd%\%%f  (
        IF NOT "%%f"=="%todaylog%" (move /y  %wd%\%%f  %wd%\log-bak\%y%\%m%\%%f)
    ) ELSE IF EXIST %wd%\%year%%%f  (
        IF NOT "%year%%%f"=="%todaylog%" (move /y  %wd%\%year%%%f  %wd%\log-bak\%y%\%m%\%year%%%f)
    )


:RENAME_LOG
REM -- ����һ�ģ��������ڵ���־�ļ�
REM -- ֧��ÿ�����ѹ���������汾������[-verNN]���ã���[-ver48]����֧��ÿ����Сʱѹ��һ�ε�Ƶ��
REM -- У���Ƿ���� log-ren-rar.lst ��־�嵥�ļ�
IF NOT EXIST %wd%\log-ren-rar.lst (GOTO INIT_LOG)

FOR /F "TOKENS=1" %%f IN (%wd%\log-ren-rar.lst) DO  IF EXIST %wd%\%%f  (
        REM �ļ�����һ����С�Ŵ���
        IF /I %%~zf GEQ 1048576  (
            rename %wd%\%%f %prefixren%%%f
            REM ��ο������ INIT_LOG ˵��������ֱ�ӳ�ʼ����Ϊ������ָ�������ѹ�����ǰ֮�����־���ڶ�ʧ���յ�����
            FOR /F "usebackq tokens=1" %%D IN (`DATE /T`) DO FOR /F "usebackq tokens=1" %%T IN (`TIME /T`) DO (
                ECHO -- %%D %%T %logrartitle% >> %wd%\%%f
            )
            %wd%\rar a -df -ep1 -ver100 %wd%\log-bak\%y%\%m%\%prefixren%%%f.rar  %wd%\%prefixren%%%f
        )
    ) ELSE IF EXIST %wd%\%prefixren%%%f  (
            %wd%\rar a -df -ep1 -ver100 %wd%\log-bak\%y%\%m%\%prefixren%%%f.rar  %wd%\%prefixren%%%f
    )


:INIT_LOG
REM -- ĳЩ��һ�ģ��������ڵ���־�ļ�ɾ������Ҫ�½�һ���յģ����򱸷�֮����д�����־�ᱻ��������awmm.log
REM -- У���Ƿ���� log-init.lst ��־�嵥�ļ�
IF NOT EXIST %wd%\log-init.lst (GOTO DONE)

FOR /F "TOKENS=1" %%f IN (%wd%\log-init.lst) DO  IF NOT EXIST %wd%\%%f  (
        FOR /F "usebackq tokens=1" %%D IN (`DATE /T`) DO FOR /F "usebackq tokens=1" %%T IN (`TIME /T`) DO (
            ECHO -- %%D %%T %logrartitle% >> %wd%\%%f
        )
    )


GOTO DONE


:MISS_RAR
ECHO !!! ��־�ļ�ѹ������ʧ�� !!!
ECHO !!! ������ RAR :  %wd%\rar.exe
ECHO ��ʾ������ʹ�õ� rar.exe Ϊ winrar �������й��ߣ������� winrar �İ�װĿ¼���ҵ����뾡��ʹ�����°汾��
GOTO END


:MISS_LIST
IF EXIST %wd%\log-ren-rar.lst (
    ECHO !!! �����ڴ�������־�嵥�ļ�: %wd%\log-rar.lst
    GOTO RENAME_LOG
)
ECHO !!! ��־�ļ�ѹ������ʧ�� !!!
ECHO !!! �����ڴ�������־�嵥�ļ�: %wd%\log-rar.lst �� log-ren-rar.lst
IF EXIST %wd%\log-init.lst (
    rem ֻ�账���ݺ�ĳ�ʼ������Ӧ��ֱ�ӳ�ʼ���ɣ�
    rem GOTO INIT_LOG
)
GOTO END


:UNKNOWN_DATE_SEP
ECHO !!! ��־�ļ�ѹ������ʧ�� !!!
ECHO !!! ��֧�ֵ�ϵͳ���ڷָ�����Ŀǰ֧��-/.����
GOTO END


:DONE
ECHO ��ɡ�

:END
