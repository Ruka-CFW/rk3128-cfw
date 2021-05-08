
**This document is available in [ [en](install.md) | [es](install_es.md) | [it](install_it.md) ]**

------

# Ruka Custom Firmware Installation Guide

**DISCLAIMER:**
Install it at your own responsibility. **This firmware is ONLY for A12 and A13 all versions (except IPS which is not supported)**, installing in other devices will cause a half brick and you will need to use tools that are not available here.


## Document TOC

* [Windows Installation](#windows-installation)
* [Linux Installation](#linux-installation)
* [Editing existing images to enable hdmi compatibility](#editing-existing-images-to-enable-hdmi-compatibility)
  - [Retroarch.cfg files](#retroarchcfg-files)
* [Changelog](#changelog)

## Windows Installation

* Charge the device, it needs to be at least at 80% battery or 7 hours charged
* Download drivers here [Rockchip repository](https://github.com/rockchip-linux/tools/blob/master/windows/DriverAssitant_v5.0.zip?raw=true)
* Download latest RKDevTool from [RockChip repository](https://github.com/rockchip-linux/tools/blob/master/windows/RKDevTool_Release_v2.79.zip?raw=true)
  * To change the language to English, edit the config.ini file and change the value Selected=1 to Selected=2  
   ![image](https://user-images.githubusercontent.com/67930710/117533430-1509b600-afed-11eb-8424-5f40b15c60bd.png)

* Download latest custom firmware for your Powkiddy A12 / A13 from this repository
  * If you don´t know which version to install, if is an A12 is likely to rev3 and if is an A13 a rev2. **Install an incorrect version will not harm your A12/A13 system!!!**       
* Unzip RKDevTool and click on AndroidTool.exe
* Click on Upgrade Firmware tab and then on firmware. A modal window will open and you will need to select the image
 ![image](https://user-images.githubusercontent.com/67930710/117165619-f07fc500-adc5-11eb-9441-e06df588ec70.png)
 ![image](https://user-images.githubusercontent.com/67930710/117165910-32107000-adc6-11eb-865f-fc88471f2cfb.png)
* Once selected, please connect the usb male A to the top port of the system and plug the usb male to the pc
* Press and hold Vol+,Home and Select. Push power button and keep holding the buttons until the software displays that the device is connected
![image](https://user-images.githubusercontent.com/67930710/117166647-da263900-adc6-11eb-9d1c-29bd802a3d48.png)
* Click on upgrade, the device will restart automatically and you will see this in the right of the software
 ![image](https://user-images.githubusercontent.com/67930710/117166887-135ea900-adc7-11eb-9b39-0c9b830b5968.png)

## Linux Installation

* Download the Linux_Upgrade_Tool from [Rockchip repository](https://github.com/rockchip-linux/tools/blob/master/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.57.zip?raw=true)
* Extract the tool: ```$ unzip Linux_Upgrade_Tool_v1.57.zip```
* Download latest custom firmware for your Powkiddy A12 / A13 from this repository
  * If you don´t know which version to install, if is an A12 is likely to rev3 and if is an A13 a rev2. **Install an incorrect version will not harm your A12/A13 system!!!**       
 * Extract the firmware: ```$ unzip RUKA_a12_v1_v2_3.0_alpha_20210504.img.zip```
 * Set your Powkiddy A12/13 in flash mode (LOADER):
  * Press and hold SELECT + HOME + VOL+ while you power up your device
 * Connect a USB-A to USB-A cable to your computer
 * Flash the firmware with: ```sudo Linux_Upgrade_Tool_v1.57/upgrade_tool uf RUKA_a12_v1_v2_3.0_alpha_20210504.img```
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
* After the ```Upgrade firmware ok.``` message is displayed, the console will restart automatically with the new firmware.

## Editing existing images to enable hdmi compatibility

* All images should have 3 retroarch files on the retroarch.cfg folder (retroarch.cfg,retroarch_hdmi.cfg and retroarch_v3.cfg)
* The sytem will detect which version is needed and boot in the appropiate video mode
* HDMI plug and unplug is not supported. HDMI should be plugged before switching on
* IPS Screens are not supported

### Retroarch.cfg files

* retroarch.cfg
  * video_fullscreen_x = "1024"
  * video_fullscreen_y = "600"
  * video_fullscreen = "true"
* retroarch_v3.cfg
  * video_fullscreen_x = "800"
  * video_fullscreen_y = "480"
  * video_fullscreen = "true"
* retroarch_hdmi.cfg
  * video_fullscreen_x = "1280"
  * video_fullscreen_y = "720"
  * video_fullscreen = "true"

## Changelog

| Modified at | Comments |Contributor |
| ----------- | -------- | ---------- |
| 2021-05-07  | Move document into `doc` folder and format contents according to the template. | alpgarcia |
| 2021-05-06  | Add Linux installation steps, fix typos. | acmeplus |
| 2021-05-06  | Initial version. | fakemaria |
