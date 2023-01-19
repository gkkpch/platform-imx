# platform-hem-var-som-mx8m-mini


tbs

##kernel 4.19.y##
git: https://github.com/varigit/linux-imx.git  
branch: imx_4.19.35_1.1.0_var01  
kernel config patches: platform-hem-var-som-mx8m-mini/linux-imx-4.19-config.patch  
example make file: platform-hem-var-som-mx8m-mini/make-kernel.sh  

##uboot-imx v2019.04##
git: https://github.com/varigit/uboot-imx.git  
branch: imx_v2019.04_4.19.35_1.1.0-var01  
u-boot patches: platform-hem-var-som-mx8m-mini/uboot-imx8mm_var_dart.patch  
example make file: platform-hem-var-som-mx8m-mini/make-uboot.sh  


2020-04.04    
+ spdif modules built-in, now working. 
Connection: SPDIF --> header J18, pin 2, GND --> header J16, pin 19
+ network settings update

2020-03-25   Added to kernel config:  
+ loop devices  
+ armv8 instructions emulation  
+ cifs support  
+ ntf-8 support  

2020-03-31  Added 
+ spdif codec  
+ sdma firmware
+ asound.state/ asound.conf 
 
Open issues  
+ bcmhd firmware may not work  

2020-04.04   
+ corrected spdif, now working. 
Connect: SPDIF --> header J18, pin 2, GND --> header J16, pin 19

2020-04-15  
+ fixed first boot sdma failure  
+ fixed wireless (works)  
+ fixed bluetooth (untested, needs adapted to volumio reqs)  
+ added buildscript for enabling u-boot UMS mode
+ added ready-to-use image for u-boot UMS mode



            

