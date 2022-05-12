try
    try
        h.ResetSystem(); % try to reset any open connection
    end
    try
        h.Close();       % try to close any open connection
    end
    h = actxserver('Apogee.Camera2');    % ActiveX handle to Alta.
    h.Init('Apn_Interface_USB',0,0,0);   % Ask Alta to initialize.
    mag_bin=1;
    if ~isempty(strfind(h.ImagingStatus,'Error'))
        % Camera error. This is bad.
        fprintf(mag_log,['mag_alta_exposure: ' mag_camera_status sprintf('\n')]);
        throw(ME); % create fatal exception
    end
catch
    fprintf(mag_log,['Alta Camera error' sprintf('\n')]);
    questdlg('Alta Camera error. Power cycle the USB connections and camera, and restart Guide82.','Question','OK','OK');
    quit force
end