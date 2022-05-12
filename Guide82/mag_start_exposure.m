% Event loop
% Copyright John Kuehne, 2012
while (mag_event==1)
    pause(0.1);
    try
        if mag_camera==1
            mag_alta_exposure
        end
        if mag_camera==2
            mag_sbig_exposure
        end
        if mag_camera==3
            mag_qsi_exposure
        end
        if mag_camera==4
            mag_file_exposure
        end
        if mag_camera==5
            mag_fli_exposure
        end
    catch me
        fprintf(mag_log,['mag_start_exposure: ' me.message sprintf('\n')]);
        questdlg('Something is wrong with the camera or its communication link. If Guide82 is controling this camera, power cycle the USB connections and camera, and restart Guide82.','Question','OK','OK');
        quit force
    end
end