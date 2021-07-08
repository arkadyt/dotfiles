@echo off

:: Commands

DOSKEY ls=dir /B
DOSKEY ll=dir
DOSKEY vi=nvim $*

DOSKEY gst=git status $*
DOSKEY gog=git log --oneline -10 $*
DOSKEY gel=git log --oneline --graph -25 $*
DOSKEY gdd=git add $*
DOSKEY gcm=git commit $*
DOSKEY gpl=git pull $*
DOSKEY gps=git push $*
DOSKEY gdi=git diff $*
DOSKEY gch=git checkout $*
DOSKEY gbr=git branch $*

:: Common directories

DOSKEY codd=cd "%USERPROFILE%\code\$*"
