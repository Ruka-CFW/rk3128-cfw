**This document is available in [ [en](install_ps5000.md) ]**

# Ruka Custom Firmware Installation Guide for PS5000

**DISCLAIMER:**
Install it at your own responsibility. **This firmware is ONLY for PS5000**, installing in other devices will cause a half brick and you will need to use tools that are not available here.
**Please do a backup before installing the cfw!!!**

## Document TOC

* [Windows Installation](#windows-installation)
* [Linux & Mac Installation](#linux-and-mac-installation)
* [SD Card Installation](#sd-card-installation)
* [General Notes](#general-notes)
  - [Retroarch.cfg files](#retroarchcfg-files)
* [Changelog](#changelog)

## Windows Installation

* Charge the device, it needs to be at least at 80% battery or 7 hours charged
* Download [drivers from Rockchip repository](https://github.com/rockchip-linux/tools/raw/master/windows/DriverAssitant_v5.11.zip)
* Download latest [Android Tool Console from RockChip repository](https://github.com/rockchip-linux/tools/blob/master/windows/AndroidTool_Console_v2.4.zip)
* Download [latest custom firmware](https://github.com/Ruka-CFW/rk3128-cfw/releases/tag/v3.0_beta_1) for your PS5000 from this repository 
  
**BACKUP PROCESS**
* Unzip Android Tools Console into the firmware folder (e.g. ruka_ps5000_cfw_universal_3.0_beta_2_20210831)
* Once selected, please connect the usb to the left usb port of the system and plug the usb male to the pc
* Press and hold SELECT key. Turn on the system and keep holding until windows recognize it or a couple of seconds
* Open Android_Console_Tool.exe as admin
* If its connected as the image, press 1 
* ![image](https://user-images.githubusercontent.com/67930710/122982066-b92b9e80-d39a-11eb-954d-5a37ca561dd7.png)
* Write the following sentence RL 0x0 0xffffffff backup.img 
* ![image](https://user-images.githubusercontent.com/67930710/122982706-7ae2af00-d39b-11eb-9898-4276a9ad0fd9.png)
* It will display an error message, is totally normal. Check that you have a backup.img with a filesize aprox of 100Mb 
* ![image](https://user-images.githubusercontent.com/67930710/122982826-a1084f00-d39b-11eb-829e-717bf4b5fb02.png)
* Now, you can proceed with the next steps. 

**CFW INSTALL**

* Copy the file ```ruka_ps5000_universal_v3.0_beta_2_20210827.img``` and ```ruka_install_ps5000 ``` inside Android Tools Console
* ![image](https://user-images.githubusercontent.com/67930710/131519478-583b6e5f-650d-473a-844c-374d4b075a0e.png)
* Set your PS5000 in flash mode (LOADER)
  * Press and hold SELECT. Turn on the system and keep holding until windows recognize it or a couple of seconds
* Double click on the file ```ruka_install_ps5000.bat```  
* Allow admin privileges when windows ask for it, it will happen twice.
* Once finished, you can switch off the system and enjoy it!

## Linux and Mac Installation

* Linux pre-requirements:
  * You need to install rkflashtool on your linux machine. If you are running ubuntu or debian you can run ```sudo apt install rkflashtool```
* Mac pre-requirements:
  * You need to have brew system installed ([brew](https://brew.sh)):
    ```$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"``` 
  * Once you have brew installed, install rkflashtool with brew:
    ```$ brew install rkflashtool```

* Download [latest custom firmware](https://github.com/Ruka-CFW/rk3128-cfw/releases/tag/v3.0_beta_1) for your PS5000 from this repository
    
* Extract the firmware: ```$ tar xzf ruka_ps5000_cfw_universal_3.0_beta_2_20210831.tgz```

* Set your PS5000 in flash mode (LOADER)
  * Press and hold SELECT. Turn on the system and keep holding until windows recognize it or a couple of seconds
* Connect a USB-B to the top left port and the USB-A cable to your computer
* Open a terminal and run the ```ruka_install_ps5000.sh``` script (you will need to be sudo or root to run it) 
* You should observe a console output similar to this:
 ```
 $ sudo ./rkflashtool w 0x0 0x00030000 < ruka_ps5000_v3.0_beta_all_revs_20210827.img
To flash the firmware you need to put the PS5000 into recovery mode
Connect your PS5000 console USB port 1 to your computer
Press and keep pressed the SELECT key and power the console on
Wait for 5 seconds and then release the SELECT key
The screen wil be black but the blue power led will be on

Press enter to continue
Flashing firmware...
rkflashtool: info: rkflashtool v5.2
rkflashtool: info: Detected RK312X...
rkflashtool: info: interface claimed
rkflashtool: info: writing flash memory at offset 0x0001ea00
[...]
rkflashtool: info: writing flash memory at offset 0x0002ffe0... Done!
DONE!
```

## SD card installation

The sdcard folder contains the folders and files that need to go into the SDCARD.

The following files need to be copied into your SDcard

| File | Description |
| ---- | ----------- |
| .config | Retroarch configuration and asset files |
| rukafs | SDCard Firmware File  |
| configs | General system and emulators configuration folder |
| logs | log folder |
| roms | Roms folder, copy your roms to the specific folder here (e.g. roms/mame) |
| roms/bios | Bios folder, copy your system bios here |

* Copy the contents of those folders/file into your SD.
* You will need to add your roms to roms folder (follow the [batocera systems](https://wiki.batocera.org/systems) structure), e.g. roms/mame)
* Add your bios into the roms/bios folder
* Insert the SDcard back into the PS5000, reboot, and enjoy

## General notes

* The CFW has been designed to be easily upgradeable. Future upgrades will be via SDCard only, so if you have flashed the internal memory, you won't require to flash it again and instead you will just need to drop an update on your SDCard. 
* The system may report a couple of BSOD depending on errors:
  * If your SD card is missing or corrupted the system will report error A
  * If the rukafs firmware is missing from the SDCard it will report error B
* You can use your existing SD images from different systems, but the CFW always looks for a configs/ruka/retroarch_ps5000.cfg for its retroarch configuration

### Retroarch.cfg files

* HDMI compatibility requires at least the following sets to be added to the retroarch.cfg:
  * video_fullscreen_x = "1280"
  * video_fullscreen_y = "720"
  * video_fullscreen = "true"
  * audio_device = "hw:0,1"
  * custom_viewport_height = "600"
  * custom_viewport_width = "1024"
  * aspect_ratio_index = "22"

## Acknowledgements

* All the folks that have been enjoying our releases
* Rutjoni, for initial testing and for being right about this console
* The folks at A12/13 telegram group
* [Bruma](https://www.youtube.com/channel/UCrdNisYjDd7qI1Zv2ZLwBrQ), [Retrolocatis](https://www.youtube.com/watch?v=a9pKh0gti3s&t=3597s), and other youtubers that have reviewed our CFWs
* Everyone at the #ps5000 RG Handhelds discord channel
* And of course, all the rest of the ruka team, you know who you are

## Changelog

| Modified at | Comments |Contributor |
| ----------- | -------- | ---------- |
| 2021-07-21  | Modified version for all revs | fakemaria |
| 2021-07-21  | Initial version. | fakemaria |
| 2021-08-06  | Updated installation steps to match release | acmeplus |
| 2021-08-31  | Updated installation to match beta 2 | fakemaria |
| 2021-08-31  | Updated Linux installation and added Mac installation | acmeplus |

