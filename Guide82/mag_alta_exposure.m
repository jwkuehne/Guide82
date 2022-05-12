try
    if mag_stop_exposure==1
        h.StopExposure(0);
        mag_stop_exposure=0;
    end
    mag_camera_status=h.ImagingStatus;
    if strcmp(mag_camera_status,'Apn_Status_Flushing')
        % Camera ready for exposure.
        mag_toc = toc(mag_delay_counter);
        if (mag_exposure_on==1) && (mag_toc>mag_delay_time)
            mag_bin = get(mag_handles.bin, 'value');
            h.RoiPixelsV=fix(mag_ccd_size(1)/mag_bin);
            h.RoiPixelsH=fix(mag_ccd_size(2)/mag_bin);
            h.RoiBinningV=mag_bin;
            h.RoiBinningH=mag_bin;
            h.Expose(abs(mag_exposure_time),1); % start exposure.
            mag_delay_counter=tic;
        end
    end
    if strcmp(mag_camera_status,'Apn_Status_ImageReady')
        % Image ready to read and process.
        mag_m0 = double(h.Image); % Read raw image.
        % Get truth table for negative numbers - Matlab thinks the image is
        % signed 2s complement, but Alta data are unsigned.
        mag_neg = mag_m0 < 0;
        mag_m0 = mag_m0 + mag_neg*2^16; % Fix.
        mag_process; % Do everything.
    end
    if ~isempty(strfind(mag_camera_status,'Error'))
        % Camera error. This is bad.
        fprintf(mag_log,['mag_alta_exposure: ' mag_camera_status sprintf('\n')]);
        throw(ME); % create exception for catch
    end
catch
    fprintf(mag_log,['Alta Camera error' sprintf('\n')]);
    mag_apogee_alta; % reinitialize
end