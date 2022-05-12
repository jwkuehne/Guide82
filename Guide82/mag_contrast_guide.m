mag_prep_max = max(max(mag_image_prep));
set(f21,'cdata',imadjust(mag_image_prep/mag_prep_max,stretchlim(mag_image_prep/mag_prep_max,10^(-1*get(f211,'value')))));
 set(f211,'tooltip',['CONTRAST:' mag_newline '-' sprintf('%0.2f',get(f211,'value')) 'dB']);
pause(0.1);
