**Este documento está disponible en [ [en](install.md) | [es](install_es.md) | [it](install_it.md) ]**

------

# Guía de instalación del Custom Firmware del Team Ruka 
**DESCARGA DE RESPONSABILIDAD:**

Instálalo bajo tu completa responsabilidad. **Este firmware es SÓLAMENTE para las powkiddys A12 Y A13, todas las revisiones (la rev1, rev2 y rev3) a excepción de las pantallas IPS**. Instalando el firmware en otros dispositivos distinto a los mencionados causará un brick permanente que necesitará de herramientas y ficheros que no están aquí y tampoco tiene el equipo ni da soporte. 


## Índice

* [Instalación en Windows](#instalación-en-windows)
* [Instalación en Linux](#instalación-en-linux)
* [Editando imagenes para añadir compatibilidad con el hdmi](#editando-imagenes-para-añadir-compatibilidad-con-el-hdmi)
  - [Ficheros retroarch.cfg](#ficheros-retroarch.cfg)
* [Changelog](#changelog)

## Instalación en Windows

* El dispositivo debe de estar al 80% de carga o llevar al menos 7 horas cargando
* Descarga los [drivers del repositorio de Rockchip](https://github.com/rockchip-linux/tools/raw/master/windows/DriverAssitant_v5.11.zip)
* Descarga la última versión de la [RKDevTool desde el repositorio de RockChip](https://github.com/rockchip-linux/tools/raw/master/windows/RKDevTool_Release_v2.84.zip)
  * Para cambiar el idioma a inglés edita el fichero config.ini y cambia el valor Selected=1 a Selected=2 tal y como muestra la imagen
  * ![image](https://user-images.githubusercontent.com/67930710/117533473-4bdfcc00-afed-11eb-8f3f-42ff76de7f36.png)
 
* Descarga el último custom firmware para tu Powkiddy A12/A13 desde este repositorio.
* Descomprime el firmware con 7zip
  * Si no sabes que versión instalar: si es una A12 es muy probable que sea la revisión 3 y si es una A12 la revisión 2. La revisión 1 solo se vendió en los primeros meses de lanzamiento. **Instalar una versión incorrecta no dañará tu A12/A13 (por ejemplo instalar la revisión 2 en vez de la revisión 3 en una Powkiddy A12)**   
    
* Descomprime el fichero RKDevTool y haz click en AndroidTool.exe
* Haz click en la pestaña Upgrade Firmware y luego en Firmware. Una ventana modal se abrirá para que selecciones el firmware del team ruka (es un fichero .img)
 ![image](https://user-images.githubusercontent.com/67930710/117165619-f07fc500-adc5-11eb-9441-e06df588ec70.png)
 ![image](https://user-images.githubusercontent.com/67930710/117165910-32107000-adc6-11eb-865f-fc88471f2cfb.png)
* Una vez seleccionado y aceptado, por favor conecta el cable USB macho macho de puntas tipo A al puerto de tu ordenador y la otra punta al usb superior de tu Powkiddy
* Pulsa y deja presionado los botonbes  Vol+,Vol-,Home y Select. Pulsa el botón de encendido mientras dejas presionado el resto de botones. El software te avisará de que está conectado, tal y como aparece en las imágenes.
![image](https://user-images.githubusercontent.com/67930710/117166647-da263900-adc6-11eb-9d1c-29bd802a3d48.png)
* Haz click en upgrade, el dispositivo se reiniciará automáticamente cuando haya terminado
 ![image](https://user-images.githubusercontent.com/67930710/117166887-135ea900-adc7-11eb-9b39-0c9b830b5968.png)

## Instalación en Linux

* Desgarga la utilidad [Linux_Upgrade_Tool desde Rockchip repository](https://github.com/rockchip-linux/tools/raw/master/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool_v1.65.zip)
* Extrae la utilidad: ```$ unzip Linux_Upgrade_Tool_v1.57.zip```
* Descarga el último custom firmware para tu Powkiddy A12/A13 desde este repositorio.
  * Si no sabes que versión instalar: si es una A12 es muy probable que sea la revisión 3 y si es una A12 la revisión 2. La revisión 1 solo se vendió en los primeros meses de lanzamiento. **Instalar una versión incorrecta no dañará tu A12/A13 (por ejemplo instalar la revisión 2 en vez de la revisión 3 en una Powkiddy A12**   
  
* Extrae el firmware: ```$ unzip RUKA_a12_v1_v2_3.0_alpha_20210504.img.zip```
* Conecta el cable USB macho macho de puntas tipo A al puerto de tu ordenador y la otra punta al usb superior de tu Powkiddy
* Pulsa y deja presionado los botonbes  Vol+,Vol-,Home y Select. Pulsa el botón de encendido mientras dejas presionado el resto de botones. 
* Flashea el firmware de esta manera: ```sudo Linux_Upgrade_Tool_v1.57/upgrade_tool uf RUKA_a12_v1_v2_3.0_alpha_20210504.img```
 * El mensaje de salida será como este:
 ```
 $ sudo Linux_Upgrade_Tool_v1.57/upgrade_tool uf RUKA_a12_v1_v2_3.0_alpha_20210504.img
Not found config.ini
Program Data in Linux_Upgrade_Tool_v1.57
Loading firmware...
Support Type:RK312A	FW Ver:8.1.00	FW Time:2021-05-04 13:50:23
Loader ver:2.52	Loader Time:2020-05-26 18:26:07
Upgrade firmware ok.
```
* Después de ver este mensaje en tu consola ```Upgrade firmware ok.```, la consola se reiniciará con el nuevo firmware.

## Editando imagenes para añadir compatibilidad con el hdmi

* Todas las imagenes deben de tener 3 ficheros retroarch.cfg en la carpeta de configuración (retroarch.cfg,retroarch_hdmi.cfg y retroarch_v3.cfg)
* El sistema detectará la versión que se necesita en función de la consola que sea y arrancará en el modo de video apropiado
* La desconexión en caliente del HDMI no está soportada. Para usar el HDMI, hay que conectarlo con la consola apagada.
* Las pantallas IPS no están soportadas

### Ficheros retroarch.cfg 

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
  * audio_device = "hw:0,1"
  * custom_viewport_height = "600"
  * custom_viewport_width = "1024"
  * aspect_ratio_index = "22"

## Changelog

| Modificado el | Comentarios | Colaborador |
| ------------- | ----------- | ----------- |
| 2021-06-05  | Update links to rockchip tools | alpgarcia |
| 2021-05-11  | Added viewport and aspect ratio to core provided in hdmi config | fakemaria |
| 2021-05-10  | Modified button sequence to flash the device. | fakemaria |
| 2021-05-08  | Add audio device configuration for HDMI. | alpgarcia |
| 2021-05-07  | ESP translation. | fakemaria |
| 2021-05-07  | Move document into `doc` folder and format contents according to the template. | alpgarcia |
| 2021-05-06  | Add Linux installation steps, fix typos. | acmeplus |
| 2021-05-06  | Initial version. | fakemaria |
