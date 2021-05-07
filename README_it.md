Ruka-cfw
Rockchip RK3128 Custom Firmware per Powkiddy A12/A13

# Consoles supportate:

* Powkiddy A12 rev1 rev2 rev3
* Powkiddy A13 rev1 rev2

# Come installare

**ATTENZIONE:**
l'installazione è sotto la vostra responsabilità. **Questo firmware è SOLO per A12 e A13 (ad eccezione delle versioni con schermo IPS che non sono supportati)**, se si prova ad installarlo su altri device si andrà incontro ad un soft brick, e sarete costretti ad usare strumenti e software non forniti qui.
* Caricate il device in modo da avere la batteria all' 80%, o tenetelo in carica per 7 ore
* Scaricate i drivers da qui [RockChip repository](https://github.com/rockchip-linux/tools/blob/master/windows/DriverAssitant_v5.0.zip?raw=true)
* Scaricate l'ultimo RKDevTool da [RockChip repository](https://github.com/rockchip-linux/tools/tree/master/windows)
* Scaricate l'ultimo custom firmware per il vostro Powkiddy A12 / A13 da questa repository
  * Se non sapete che versione installare, considerate ceh se è un A12 sarà probabilmente una rev3, e se è un A13 sarà una rev2. **Installare una versione errata per il vostro device non rovinerà il vostro A12/A13 !!!**       
* Decomprimete lo zip RKDevTool e cliccate su on AndroidTool.exe
* Cliccate sul menu Upgrade Firmware e successivamente sul tasto firmware. Un popup menù si aprirà chiedendovi dove si trova l'immagine
 ![image](https://user-images.githubusercontent.com/67930710/117165619-f07fc500-adc5-11eb-9441-e06df588ec70.png)
 ![image](https://user-images.githubusercontent.com/67930710/117165910-32107000-adc6-11eb-865f-fc88471f2cfb.png)
* Once selected, please connect the usb male A to the top port of the system and plug the usb male to the pc
* Press and hold Vol+,Home and Select. Push power button and keep holding the buttons until the software displays that the device is connected
* Una volta selezionata, connettete il cavo usb nella porta superiore del device e connettete l'altro capo al pc
* Premete e tenete premuto i tasti Vol+,Home e Select. Premete il tasto power e continuate a tenere premuto fino a che sul programma non appare il messaggio di device connesso in loader mode
![image](https://user-images.githubusercontent.com/67930710/117166647-da263900-adc6-11eb-9d1c-29bd802a3d48.png)
* Click on upgrade, the device will restart automatically and you will see this in the right of the software
* Cliccate sul tasto upgrade, il device farà un restart automatico e apparirà sul lato destro del software una serie di messaggi di sistema
 ![image](https://user-images.githubusercontent.com/67930710/117166887-135ea900-adc7-11eb-9b39-0c9b830b5968.png)

# Modificare le configurazioni esistenti per abilitare la modalità HDMI **
* Tutte le immagini dovrebbero avere 3 file di configurazione retroarch nella cartella di configurazione retroarch.cfg (retroarch.cfg,retroarch_hdmi.cfg e retroarch_v3.cfg)
* Il sistema configurerà automaticamente la versione necessaria e faraà il boot nella modalità video più consona 
* Connettere e disconnettere il cavo HDMI non è possibile. Per avere l'HDMI funzionante bisogna connetterlo prima di accedere il device
* Gli schermi IPS non sono ufficialmente supportati
## Files Retroarch.cfg
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
