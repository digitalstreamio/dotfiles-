Amiga Setup
===========

# Installation

## Prereq

    PC:apps/prereq/lha.run RAM:
    copy RAM:lha_68020 C:lha

    lha x PC:apps/prereq/#?.lha RAM:
    copy RAM:Installer43_3/Installer C:

    ~install MUI Dest=SYS:System
    ~install ClassAct

## Apps (Tier 1)

### Desktop

    lha x PC:apps/desktop/#?.lha RAM:
    ~install KingCON
    ~install Scalos Dest=SYS:System/Scalos

### Multimedia

    lha x PC:apps/multimedia/#?.lha RAM:
    TODO ~install

### Utilities

    lha x PC:apps/utilities/#?.lha RAM:
    lha x PC:apps/utilities/CygnusEd-4.2.lha SYS:Apps/
    lha x PC:apps/utilities/DiskMaster-2.6.lha SYS:Apps/
    delete SYS:Apps/DiskMaster2/#?.OS4#?
    lha x PC:apps/utilities/Scout-3.6.lha SYS:Apps/
    ~install SysSpeed Dest=SYS:Apps/SysSpeed
    ~install VirusZ
    lha x PC:apps/utilities/Voodoo-X-1.5.lha SYS:Apps/

## Apps (Tier 2)

### Dev

    lha x PC:apps/dev/ASM-One-1.48.lha RAM:Asm-One/
    ~install ASM-One Dest=SYS:Apps/ASM-One
    ~install AMOS Pro Dest=Sys:Apps Opts=Main,Examples

### Games

    lha x PC:apps/games/WHDLoad-18.2.lha RAM:
    ~install WHDLoad
    TODO delete SYS:Locale/Help/WHDLoad
    lha x PC:apps/games/iGame-1.5.lha SYS:Apps/

## System

### Datatypes

    lha x PC:apps/system/datatypes/#?.lha RAM:
    ~install WarpJPEGdt
    ~install akPNGdt
    copy RAM:ilbmdt44/#?.datatype SYS:Classes/DataTypes/

### Drivers

    lha x PC:apps/system/drivers/#?.lha RAM:
    ~install Picasso96 Support_Path=SYS:Storage/Picasso96

### Fonts

    lha x PC:apps/system/fonts/#?.lha FONTS:

### Libs

    lha x PC:apps/system/libs/#?.lha RAM:
    ~install OpenURL
    ~install PopupMenu
    ~install ReqTools
    ~install xad
    ~install xfd
    ~install xvs
    copy RAM:DisLib/Libs/disassembler.library LIBS:
    copy RAM:wizard.library LIBS:
    copy PC:apps/system/libs/guigfx.library LIBS:
    copy PC:apps/system/libs/render.library LIBS:

### MUI

    lha x PC:apps/system/mui/#?.lha RAM:
    copy RAM:MCC_BetterString/Libs/MUI/AmigaOS3/#?.mc? MUI:Libs/mui/
    copy RAM:MCC_Guigfx/Libs/MUI/#?.mc? MUI:Libs/mui/
    copy RAM:MCC_NList/Libs/MUI/AmigaOS3/#?.mc? MUI:Libs/mui/
    copy RAM:MCC_SpeedBar/MUI/#?.mc? MUI:Libs/mui/
    copy RAM:MCC_TextEditor/Libs/MUI/AmigaOS3/#?.mc? MUI:Libs/mui/

### Patches

    lha x PC:apps/system/patches/#?.lha RAM:
    copy RAM:SetPatch43_6b/SetPatch C:

### Startup

    lha x PC:apps/system/startup/#?.lha RAM:
    copy RAM:FreeWheel/FreeWheel_020 SYS:WBStartup/FreeWheel
    copy RAM:FreeWheel/FreeWheel_020.info SYS:WBStartup/FreeWheel.info
    copy RAM:FreeWheel/FreeWheel.cfg SYS:WBStartup/

### Tbd

    copy RAM:MCC_Lamp/Libs/MUI/Lamp020.mcc MUI:Libs/mui/Lamp.mcc
    copy RAM:MCC_Lamp/Libs/MUI/Lamp.mcp MUI:Libs/mui/
    copy RAM:MCC_Textinput/MUI/Textinput.mcc.020 MUI:Libs/mui/Textinput.mcc
    copy RAM:MCC_Textinput/MUI/Textinput.mcp MUI:Libs/mui/
    copy RAM:MCC_Textinput/MUI/Textinputscroll.mcc MUI:Libs/mui/
    copy RAM:MCC_Textinput/Libs/#?.library LIBS:
    copy RAM:MCC_Urltext/MUI/#?.mc? MUI:Libs/mui/
    copy TM30_PopMCCs/Libs/mui/#?.mc? MUI:Libs/mui/

# Configuration

## System

### Preferences

    + ScreenMode
        - Display Mode - UAE: 1280x720 8bit
    + Font
        - Workbench Icon Text - XHelvetica 13
        - System Default Text - XEN 11
        - Screen Text - XHelvetica 13

### MUI

    MUI Prefs > Project > Open > PC:conf/MUI.prefs

### PopupMenu

    TODO

## Apps (Tier 1)

### DiskMaster

    + SYS:S/DiskMaster2.prefs
        - NewScreen ID=1351488259 D=24 W=1280 H=720 F="XHelvetica.font" FS=13
        - Font DIRWIN="XEN.font" 8 DIRGAD="XHelvetica.font" 13 REQTEXT="XHelvetica.font" 13 REQBUTTONS="XHelvetica.font" 13 MENU="XHelvetica.font" 13
        - OpenWindow Path="sys:" Left=0 Top=16 Width=538 Height=704 ZoomL=0 ZoomT=16 ZoomW=100 ZoomH=100
        - OpenWindow Path="ram:" Left=742 Top=16 Width=538 Height=704 ZoomL=612 ZoomT=16 ZoomW=100 ZoomH=100
        - OpenWindow CMD Left=538 Top=16 Width=204 Height=704 ZoomL=408 ZoomT=16 ZoomW=100 ZoomH=100

### KingCon

    + System/System/Shell
        - /Icon/Information/ToolTypes
            - WINDOW=KCON:/100//238/AmigaShell/CLOSE

## Apps (Tier 2)

### ASM-One

    + ENVARC:ASM-ONE.Prefs
        - &XEN.font

# Resources

## A1200

* Amiga Model
    - Amiga Model = A1200
* Hard Disks
    - DH0 = System31.hdf
* ROM & RAM
    - Zorro III Fast Memory = 64MB
* Joystick & Mouse Port
    - Amiga Joystick = No Host Device
* Expansions
    - Graphics Card = UAEGFX
    - UAE bsdsocket.library = Enabled
* Additional Configuration
    - CPU = 68020 or 68040-NOMMU
    - JIT Compiler = Enabled
    - Floppy Drive Speed = Turbo
    - Empty Floppy Drive Volume = 0

## System

    avail flush = 3290040
