h(1:4)=0; % Clear calllib return values for error checking.
if mag_stop_exposure==1
    h(1)=calllib('SBIGUDrv','SBIGUnivDrvCommand',2,u,vp);
    mag_stop_exposure=0;
end
% Get StartExposureParams2 status
h(2)=calllib('SBIGUDrv','SBIGUnivDrvCommand',12,qp,qr);
if qr.status==0
    % Camera ready for exposure.
    mag_toc = toc(mag_delay_counter);
    if (mag_exposure_on==1) && (mag_toc>mag_delay_time)
        mag_bin = get(mag_handles.bin, 'value');
        if mag_bin > 3
            mag_bin = 3; % only 1,2,3 are supported.
        end
        if mag_m_clear==1 % Change in binning
            mag_m_clear=0;
            clear mag_m0; % Redimension for row reads below
            rlp.pixelLength=fix(mag_ccd_size(2)/(mag_bin));
            rlp.readoutMode=mag_bin-1;
            rlr=libpointer('uint16Ptr',uint16(1:fix(mag_ccd_size(2)/(mag_bin))));
            t.readoutMode=mag_bin-1;
            t.height=fix(mag_ccd_size(1)/(mag_bin));
            t.width=fix(mag_ccd_size(2)/(mag_bin));
            srp.readoutMode=mag_bin-1;
            srp.width=fix(mag_ccd_size(2)/(mag_bin));
            srp.height=fix(mag_ccd_size(1)/(mag_bin));
            mag_m0 = zeros(srp.height, srp.width);
        end
        t.exposureTime = mag_exposure_time*100;
        h(3)=calllib('SBIGUDrv','SBIGUnivDrvCommand',50,t,vp);
        mag_delay_counter=tic;
    end
end
if qr.status==3
    % Image ready to read and process.
    % End Exposure
    h(1)=calllib('SBIGUDrv','SBIGUnivDrvCommand',2,u,vp);
    % Start Readout
    calllib('SBIGUDrv','SBIGUnivDrvCommand',35,srp,vp);
    for row=1:fix(mag_ccd_size(1)/(mag_bin)),
        h(4)=h(4)+calllib('SBIGUDrv','SBIGUnivDrvCommand',3,rlp,rlr);
        mag_m0(row,:)=double(rlr.value);
        if rem(row,200)==0
            pause(0.001); % During readout permit user interaction.
        end
    end
    % End Readout
    calllib('SBIGUDrv','SBIGUnivDrvCommand',25,er,vp);
    mag_process; % Do everything.
end
if sum(h)>0
    % Camera error. This is bad.
    fprintf(mag_log,['mag_sbig_exposure: ' mag_camera_status sprintf('\n')]);
    questdlg('Something is wrong with the SBIG camera or its communication link. Power cycle the USB connections and camera, and restart Guide82.','Question','OK','OK');
    quit force
end