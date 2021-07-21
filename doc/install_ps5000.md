**This document is available in [ [en](install_ps5000.md) | [es](install_es_ps5000.md) | [it](install_it_ps5000.md) ]**

# Ruka Custom Firmware Installation Guide for PS5000

**DISCLAIMER:**
Install it at your own responsibility. **This firmware is ONLY for PS5000**, installing in other devices will cause a half brick and you will need to use tools that are not available here.
**Please do a backup before installing the cfw!!!**

## Document TOC

* [Windows Installation](#windows-installation)
* [Linux Installation](#linux-installation)
* [Editing existing images to enable hdmi compatibility](#editing-existing-images-to-enable-hdmi-compatibility)
  - [Retroarch.cfg files](#retroarchcfg-files)
* [Changelog](#changelog)

## Windows Installation

* Charge the device, it needs to be at least at 80% battery or 7 hours charged
* Download [drivers from Rockchip repository](https://github.com/rockchip-linux/tools/raw/master/windows/DriverAssitant_v5.11.zip)
* Download latest [Android Tool Console from RockChip repository](https://github.com/rockchip-linux/tools/blob/master/windows/AndroidTool_Console_v2.4.zip)
* Download latest custom firmware for your PS5000 from this repository
  
**BACKUP PROCESS**
* Unzip Android Tools Console 
* Once selected, please connect the usb to the left usb port of the system and plug the usb male to the pc
* Press and hold Select, Start and Vol+. Turn on the system and keep holding until windows recognize it or a couple of seconds
* Open Android_Console_Tool.exe as admin
* If its connected as the image, press 1 
* ![image](https://user-images.githubusercontent.com/67930710/122982066-b92b9e80-d39a-11eb-954d-5a37ca561dd7.png)
* Write the following sentence RL 0x0 0xffffffff backup.img 
* ![image](https://user-images.githubusercontent.com/67930710/122982706-7ae2af00-d39b-11eb-9898-4276a9ad0fd9.png)
* It will display an error message, is totally normal. Check that you have a backup.img with a filesize aprox of 100Mb 
* ![image](https://user-images.githubusercontent.com/67930710/122982826-a1084f00-d39b-11eb-829e-717bf4b5fb02.png)
* Now, you can proceed with the next steps. 

**CFW INSTALL**

* Copy the content of the folder ```Ruka 3.0 RC1 for PS5000``` inside Android Tools Console
* ![image](https://user-images.githubusercontent.com/67930710/126566257-a81893eb-aa70-45fe-9bb7-ecc26473f2ed.png)
* Set your PS5000 in flash mode (LOADER)
 * Press and hold Select, Start and Vol+. Turn on the system and keep holding until windows recognize it or a couple of seconds
* Double click on the file ```ps5000 ruka flash.bat```  
* Allow admin privileges when windows ask for it, it will happen twice.
* Once finished, you can switch off the system and enjoy it!

## Linux Installation

* Download the [Linux_Upgrade_Tool from Rockchip repository](https://github.com/rockchip-linux/tools/raw/master/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65.zip)
* Extract the tool: ```$ unzip Linux_Upgrade_Tool_v1.65.zip```
* Download latest custom firmware for your PS5000 from this repository
    
 * Extract the firmware: ```$ unzip RUKA_a12_v1_v2_3.0_alpha_20210504.img.zip```

* Set your PS5000 in flash mode (LOADER)
 * Press and hold Select, Start and Vol+. Turn on the system and keep holding until windows recognize it or a couple of seconds
 * Connect a USB-B to the top left port and the USB-A cable to your computer
 * Flash the firmware with: ```sudo Linux_Upgrade_Tool_v1.57/upgrade_tool uf RUKA_a12_v1_v2_3.0_alpha_20210504.img```
 * Flash each file with: 
  * ```sudo Linux_Upgrade_Tool_v1.57/upgrade_tool WL 0x00003800 boot.img```
  * ```sudo Linux_Upgrade_Tool_v1.57/upgrade_tool WL 0x00008000 rootfs.img``` 
 * You should observe a console output similar to this:
 ```
 $ sudo Linux_Upgrade_Tool_v1.57/upgrade_tool uf RUKA_a12_v1_v2_3.0_alpha_20210504.img
Not found config.ini
Program Data in Linux_Upgrade_Tool_v1.57
Loading firmware...
Support Type:RK312A	FW Ver:8.1.00	FW Time:2021-05-04 13:50:23
Loader ver:2.52	Loader Time:2020-05-26 18:26:07
Upgrade firmware ok.
```

## Editing existing images to enable hdmi compatibility

* TBF

### Retroarch.cfg files


* retroarch_hdmi.cfg
  * video_fullscreen_x = "1280"
  * video_fullscreen_y = "720"
  * video_fullscreen = "true"
  * audio_device = "hw:0,1"
  * custom_viewport_height = "600"
  * custom_viewport_width = "1024"
  * aspect_ratio_index = "22"

## Changelog

| Modified at | Comments |Contributor |
| ----------- | -------- | ---------- |
| 2021-07-21  | Initial version. | fakemaria |
