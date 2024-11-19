@REM ----------------------------------------------------------------------------
@REM Maven Wrapper Batch Script for Windows Environments
@REM
@REM Required ENV vars:
@REM   JAVA_HOME (optional) - location of a JDK home dir
@REM
@REM Optional ENV vars:
@REM   MAVEN_BATCH_ECHO - set to 'on' to enable batch script echo
@REM   MAVEN_BATCH_PAUSE - set to 'on' to wait for key press before ending
@REM   MAVEN_OPTS - parameters passed to the Java VM when running Maven
@REM   MAVEN_DEBUG_OPTS - additional debug options for Maven
@REM ----------------------------------------------------------------------------

@REM Human Tasks:
@REM 1. Ensure Java 17 or higher is installed and accessible via PATH or JAVA_HOME
@REM 2. If behind a proxy, configure proxy settings in Maven settings.xml
@REM 3. Ensure write permissions in .mvn/wrapper directory for Maven distribution download

@REM Requirement Addressed: Build Tool Standardization
@REM Provides consistent Maven build environment for Windows systems

@echo off
@setlocal enableextensions enabledelayedexpansion

@REM Set Maven project base directory
if "%MAVEN_PROJECTBASEDIR%"=="" (
    set "MAVEN_PROJECTBASEDIR=%~dp0"
    @REM Remove trailing slash
    if "!MAVEN_PROJECTBASEDIR:~-1!"=="\" set "MAVEN_PROJECTBASEDIR=!MAVEN_PROJECTBASEDIR:~0,-1!"
)

@REM Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set "JAVA_EXE=java.exe"
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto execute

echo.
echo ERROR: JAVA_EXE not found in PATH
echo Please ensure Java is installed and added to PATH
echo.
goto error

:findJavaFromJavaHome
set "JAVA_HOME=%JAVA_HOME:"=%"
set "JAVA_EXE=%JAVA_HOME%/bin/java.exe"

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_EXE not found in JAVA_HOME
echo Please ensure JAVA_HOME points to valid JDK installation
echo.
goto error

:execute
@REM Setup the command line arguments
set "CLASSPATH=%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.jar"

@REM Requirement Addressed: Spring Boot 3 Migration
@REM Configure Maven Wrapper properties for Maven 3.9.2 compatibility
set "WRAPPER_JAR=%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.jar"
set "WRAPPER_PROPERTIES=%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.properties"

@REM Default Maven opts if not set
if not defined MAVEN_OPTS (
    set "MAVEN_OPTS=-Xmx1024m"
)

@REM Additional debug options if specified
if defined MAVEN_DEBUG_OPTS (
    set "MAVEN_OPTS=%MAVEN_DEBUG_OPTS% %MAVEN_OPTS%"
)

@REM Execute Maven with provided arguments
"%JAVA_EXE%" ^
  %MAVEN_OPTS% ^
  -classpath "%CLASSPATH%" ^
  "-Dmaven.multiModuleProjectDirectory=%MAVEN_PROJECTBASEDIR%" ^
  org.apache.maven.wrapper.MavenWrapperMain %MAVEN_CMD_LINE_ARGS%

:error
set ERROR_CODE=%ERRORLEVEL%

:end
@endlocal & set ERROR_CODE=%ERROR_CODE%

exit /B %ERROR_CODE%