Linux bootanimation

1、格式要求： 
  a、与屏幕分辨率一致
  b、jpeg格式
  c、图片名字 从0开始，0.jpg ->n.jpg

2、配置 /mnt/bootanimation/boot.conf
  modeset 开机动画，会读取这个配置文件；
  参考配置:  cnt： 动画图片张数； path：动画图片路径；fps：图片刷新率
  cnt=15    
  path=/mnt/bootanimation/part0
  fps=15
