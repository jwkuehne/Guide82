% Interlocks with mag_abort_exposure: unlike Alta, reading the
% camera does not make image unavailable. mag_qsi sets mag_abort_exposure=1.
try
    if mag_stop_exposure==1
        mag_abort_exposure = 1; % Prevent ImageArray, allow StartExposure
        try
            h.AbortExposure;    % Can throw exception if reading, other normal activities
            mag_stop_exposure=0;
        end
    end
    mag_camera_status = h.CameraState;
    if (strcmp(mag_camera_status,'CameraIdle'))
        mag_toc = toc(mag_delay_counter);
        if (mag_exposure_on==1) && (mag_toc > mag_delay_time) && (mag_abort_exposure==1)
            mag_abort_exposure = 0; % allow ImageArray next time through
            mag_bin = get(mag_handles.bin, 'value');
            h.BinX=mag_bin;
            h.BinY=mag_bin;
            h.NumX=fix(mag_ccd_size(1)/mag_bin);
            h.NumY=fix(mag_ccd_size(2)/mag_bin);
            h.StartExposure(abs(mag_exposure_time),1); % start exposure
            mag_delay_counter=tic;
        end
    end
    if (h.ImageReady == 1) && (mag_abort_exposure == 0)% prevents ImageArray upon restarting Exposure
        % Image ready to read and process.
        mag_abort_exposure = 1; % Allow exposure
        mag_m0 = h.ImageArrayDouble; % Read raw image.
        mag_process; % Do everything.
    end
    mag_camera_status = h.CameraState;
    if (mag_camera_status == 5)
        throw(ME); % create exception
    end
catch
    fprintf(mag_log,['QSI Camera error' sprintf('\n')]);
    mag_qsi;   % reinitialize
end


