# ruka-cfw
Rockchip RK3128 Custom Firmware for Powkiddy A12/A13

# Supported Consoles:

* Powkiddy A12 rev1 rev2 rev3
* Powkiddy A13 rev1 rev2

# How to Install

**DISCLAIMER:**
Install it at your own responsability. **This firmware is ONLY for A12 and A13 all versions (except IPS which is not supported)**, installing in other devices will cause a half brick
and you will need to use tools that are not available here.
* Charge the device, it needs to be at least at 80% battery or 7 hours charged
* Download drivers here ???
* Download latest RKDevTool from [RockChip repository](https://github.com/rockchip-linux/tools/tree/master/windows)
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

# Editing existing images to enable hdmi compatibility **
* All images should have 3 retroarch files on the retroarch.cfg folder (retroarch.cfg,retroarch_hdmi.cfg and retroarch_v3.cfg)
* The sytem will detect which version is needed and boot in the appropiate video mode
* HDMI plug and unplug is not supported. HDMI should be plugged before switching on
* IPS Screens are not supported 
## Retroarch.cfg files
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
