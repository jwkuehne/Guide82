try
    try
        h.Connected=0; % try to disconnect
    end
    h = actxserver('QSICamera.CCDCamera');    % ActiveX handle to QSI.
    h.Connected=1;   % Ask QSI to connect.
    if (h.CameraState == 5)
        throw(ME); % camera error: say goodbye.
    end
    mag_bin=1;
    mag_abort_exposure = 1; % re-enable exposure to prevent deadlock, QSI only.
catch
    fprintf(mag_log,['QSI Camera error' sprintf('\n')]);
    questdlg('QSI Camera error. Power cycle the USB connections and camera, and restart Guide82.','Question','OK','OK');
    quit force
end