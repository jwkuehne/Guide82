mag_m0_max = max(max(mag_m0_display));
set(f11,'cdata',imadjust(mag_m0_display/mag_m0_max,stretchlim(mag_m0_display/mag_m0_max,10^(-1*get(f111,'value')))));
 set(f111,'tooltip',['CONTRAST:' mag_newline '-' sprintf('%0.2f',get(f111,'value')) 'dB']);
pause(0.1);
