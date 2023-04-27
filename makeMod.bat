REM //******************************************************************************
REM // Call of Duty 4: Modern Warfare
REM //******************************************************************************
REM // Mod      : The Return of Zombie Ops Project...
REM // Website  : http://sogmods.net/
REM //******************************************************************************

@echo off
set COMPILEDIR=%CD%
set color=0e
color %color%

:START
cls
echo.  __________      __________
echo.  \______   \____ \____    /____
echo.  ^|       _//  _ \ /     / /  _ \
echo.  ^|    ^|   (  (_) )     / (  (_) )
echo.  ^|____^|_  /\____/_______  \____/
echo.         \/              \/
echo. ^===============================================================================
echo. Return of the Zombie Ops - Mod 2012/2013
echo. Modded by Lefti ^& 3aGl3
echo. 
echo. project: Return of Zombie Ops
echo. website: http://sogmods.net/
echo. ^===============================================================================

:MAKEOPTIONS
echo.
echo  Please select an option:
echo    1. Build iwds
echo    2. Build mod.ff
echo.
echo    0. Exit
echo.
set /p make_option=:
set make_option=%make_option:~0,1%
if "%make_option%"=="1" goto CHOOSE_IWD
if "%make_option%"=="2" goto MAKE_MOD_FF
if "%make_option%"=="0" goto FINAL
goto START



:CHOOSE_LANG
echo _________________________________________________________________
echo.
echo  Please choose the language you would like to compile:
echo    1. English
echo.
echo    0. Back
echo.
set /p lang_chosen=:
set lang_chosen=%lang_chosen:~0,1%
REM if "%lang_chosen%"=="1" goto LANGCZ
if "%lang_chosen%"=="1" goto LANGEN
goto CHOOSE_LANG


:LANGEN
set CLANGUAGE=English
set LANG=english
set LTARGET=english
goto COMPILE


:COMPILE
echo.

echo  Checking language directories...
if not exist ..\..\zone\%LTARGET% mkdir ..\..\zone\%LTARGET%
if not exist ..\..\zone_source\%LTARGET% xcopy ..\..\zone_source\english ..\..\zone_source\%LTARGET% /SYI > NUL

echo  ROZO will be created in %CLANGUAGE%!
if "%make_option%"=="1" goto MAKE_OPENWARFARE_IWD
if "%make_option%"=="2" goto MAKE_OPENWARFARE_IWD
if "%make_option%"=="3" goto MAKE_MOD_FF
goto END



:CHOOSE_IWD
echo _________________________________________________________________
echo.
echo  Please select the iwd you want to create
echo     1. create all iwds
echo     2. create zz_images.iwd - script files
echo     3. create zz_radio.iwd - .iwi image files
echo     4. create zz_sounds.iwd - sound files
echo     5. create zz_weapons.iwd - weapon files
echo.
echo     0. Back
echo.
set /p iwd_option=:
set iwd_option=%iwd_option:~0,1%
if "%iwd_option%"=="1" goto BUILD_IMAGES_IWD
if "%iwd_option%"=="2" goto BUILD_IMAGES_IWD
if "%iwd_option%"=="3" goto BUILD_RADIO_IWD
if "%iwd_option%"=="4" goto BUILD_SOUNDS_IWD
if "%iwd_option%"=="5" goto BUILD_WEAPONS_IWD
if "%iwd_option%"=="0" goto MAKEOPTIONS
goto CHOOSE_IWD

:BUILD_IMAGES_IWD
echo _________________________________________________________________
echo.
echo  Building zz_images.iwd
echo  Deleting old zz_images.iwd...
del zz_images.iwd
echo  Adding images...
7za a -r -tzip zz_images.iwd images\*.iwi > NUL
echo  New zz_images.iwd file successfully built!
if "%iwd_option%"=="1" goto BUILD_RADIO_IWD
if "%main_option%"=="1" goto BUILD_RADIO_IWD
goto END

:BUILD_RADIO_IWD
echo _________________________________________________________________
echo.
echo  Building zz_radio.iwd
echo  Deleting old zz_radio.iwd...
del zz_radio.iwd
echo  Adding musics...
7za a -r -tzip zz_radio.iwd sound\music\radio\*.* > NUL
echo  New zz_radio.iwd file successfully built!
if "%iwd_option%"=="1" goto BUILD_SOUNDS_IWD
if "%main_option%"=="1" goto BUILD_SOUNDS_IWD
goto END

:BUILD_SOUNDS_IWD
echo _________________________________________________________________
echo.
echo  Building zz_sounds.iwd
echo  Deleting old zz_sounds.iwd...
del zz_sounds.iwd
echo  Adding sounds...
REM //7za a -r -tzip zz_sounds.iwd sound\*.* > NUL
7za a -r -tzip zz_sounds.iwd sound\hardpoints\*.* > NUL
7za a -r -tzip zz_sounds.iwd sound\misc\*.* > NUL
7za a -r -tzip zz_sounds.iwd sound\mp\*.* > NUL
7za a -r -tzip zz_sounds.iwd sound\music\HGW_Airlift_Deploy_v1.mp3 > NUL
7za a -r -tzip zz_sounds.iwd sound\music\HGW_Gameshell_v10.mp3 > NUL
7za a -r -tzip zz_sounds.iwd sound\music\mx_stag_push_00.wav > NUL
7za a -r -tzip zz_sounds.iwd sound\music\mx_underscore_ber2.wav > NUL
7za a -r -tzip zz_sounds.iwd sound\music\zmb_defeat.mp3 > NUL
7za a -r -tzip zz_sounds.iwd sound\music\zmb_victory.mp3 > NUL
7za a -r -tzip zz_sounds.iwd sound\tesla\*.* > NUL
7za a -r -tzip zz_sounds.iwd sound\vehicles\*.* > NUL
7za a -r -tzip zz_sounds.iwd sound\weapons\*.* > NUL
7za a -r -tzip zz_sounds.iwd sound\weps\*.* > NUL
7za a -r -tzip zz_sounds.iwd sound\zmb\*.* > NUL
echo  New zz_sounds.iwd file successfully built!
if "%iwd_option%"=="1" goto BUILD_WEAPONS_IWD
if "%main_option%"=="1" goto BUILD_WEAPONS_IWD
goto END

:BUILD_WEAPONS_IWD
echo _________________________________________________________________
echo.
echo  Building zz_weapons.iwd
echo  Deleting old zz_weapons.iwd...
del zz_weapons.iwd
echo  Adding weapons folder...
7za a -r -tzip zz_weapons.iwd weapons\mp\* > NUL
echo  Adding custombuttons.cfg...
7za a -r -tzip zz_weapons.iwd custombuttons.cfg > NUL
echo  New zz_weapons.iwd file successfully built!
if "%main_option%"=="1" goto MAKE_MOD_FF
goto END


:MAKE_MOD_FF
set CLANGUAGE=English
set LANG=english
set LTARGET=english
echo _________________________________________________________________
echo.
echo  Building mod.ff:
echo    Deleting old mod.ff file...
del mod.ff

echo    Copying localized strings...
xcopy %LANG% ..\..\raw\%LTARGET% /SYI > NUL

echo    Copying game resources...
xcopy animtrees ..\..\raw\animtrees /SYI > NUL
xcopy character ..\..\raw\character /SYI > NUL
xcopy config ..\..\raw\config /SYI > NUL
xcopy images ..\..\raw\images /SYI > NUL
xcopy fx ..\..\raw\fx /SYI > NUL
xcopy maps ..\..\raw\maps /SYI > NUL
xcopy material_properties ..\..\raw\material_properties /SYI > NUL
xcopy materials ..\..\raw\materials /SYI > NUL
xcopy mp ..\..\raw\mp /SYI > NUL
xcopy shock ..\..\raw\shock /SYI > NUL
xcopy rumble ..\..\raw\rumble /SYI > NUL
xcopy sound ..\..\raw\sound /SYI > NUL
xcopy soundaliases ..\..\raw\soundaliases /SYI > NUL
xcopy ui_mp ..\..\raw\ui_mp /SYI > NUL
xcopy vision ..\..\raw\vision /SYI > NUL
xcopy weapons\mp ..\..\raw\weapons\mp /SYI > NUL
xcopy xanim ..\..\raw\xanim /SYI > NUL
xcopy xmodel ..\..\raw\xmodel /SYI > NUL
xcopy xmodelparts ..\..\raw\xmodelparts /SYI > NUL
xcopy xmodelsurfs ..\..\raw\xmodelsurfs /SYI > NUL

echo    Copying Rozo source code...
xcopy scripts ..\..\raw\scripts /SYI > NUL
copy /Y mod.csv ..\..\zone_source > NUL
copy /Y mod_ignore.csv ..\..\zone_source\%LTARGET%\assetlist > NUL
cd ..\..\bin > NUL


echo    Compiling mod...
linker_pc.exe -language %LTARGET% -compress -cleanup mod 
cd %COMPILEDIR% > NUL
copy ..\..\zone\%LTARGET%\mod.ff > NUL
echo  New mod.ff file successfully built!
goto END

:END
pause
goto FINAL

:FINAL