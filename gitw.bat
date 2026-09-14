@echo off
REM Portable git finder for TownWave Director skill sync.
REM Locates git.exe across common installs, then forwards all args to it.
SET "GIT="
IF EXIST "%USERPROFILE%\.workbuddy\binaries\PortableGit\versions" (
  FOR /D %%V IN ("%USERPROFILE%\.workbuddy\binaries\PortableGit\versions\*") DO (
    IF EXIST "%%V\cmd\git.exe" IF NOT DEFINED GIT SET "GIT=%%V\cmd\git.exe"
  )
)
IF NOT DEFINED GIT IF EXIST "C:\Program Files\Git\cmd\git.exe" SET "GIT=C:\Program Files\Git\cmd\git.exe"
IF NOT DEFINED GIT IF EXIST "C:\Program Files (x86)\Git\cmd\git.exe" SET "GIT=C:\Program Files (x86)\Git\cmd\git.exe"
IF NOT DEFINED GIT SET "GIT=git"
"%GIT%" %*
