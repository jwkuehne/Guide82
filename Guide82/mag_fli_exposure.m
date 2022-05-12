try
    if mag_stop_exposure==1
        calllib('libfli','FLICancelExposure', fli_dev.value); % Clear pending exposure and data.
        mag_stop_exposure=0;
    end
    mag_fli_return = calllib('libfli','FLIGetDeviceStatus',fli_dev.value,fli_status); % get status
    if (bitand(fli_status.value,3)==0) && (bitand(fli_status.value,-2147483584)~=-2147483584),
        % Camera ready for exposure.
        mag_toc = toc(mag_delay_counter);
        if (mag_exposure_on==1) && (mag_toc>mag_delay_time)
            if mag_m_clear==1 % Change in binning
                mag_m_clear=0;
                clear mag_m0;
                mag_bin = get(mag_handles.bin, 'value');
                fli_row=libpointer('uint16Ptr',uint16(ones(1,fix(mag_ccd_size(2)/mag_bin)))); % create row
                mag_fli_return = mag_fli_return + abs(calllib('libfli','FLISetHBin',fli_dev.value,uint32(mag_bin)));
                mag_fli_return = mag_fli_return + abs(calllib('libfli','FLISetVBin',fli_dev.value,uint32(mag_bin)));
                mag_fli_return = mag_fli_return + abs(calllib('libfli','FLISetImageArea',fli_dev.value,uint32(0),uint32(0),fix(mag_ccd_size(2)/mag_bin),fix(mag_ccd_size(1)/mag_bin)));
            end
            mag_fli_return = mag_fli_return + abs(calllib('libfli','FLISetExposureTime',fli_dev.value,uint32(1000*abs(mag_exposure_time)))); % set the exposure in milliseconds
            mag_fli_return = mag_fli_return + abs(calllib('libfli','FLIExposeFrame',fli_dev.value)); % Expose
            mag_delay_counter=tic;
        end
    end
    if bitand(fli_status.value,-2147483584)==-2147483584
        for row=1:fix(mag_ccd_size(1)/mag_bin),
            mag_fli_return = mag_fli_return + abs(calllib('libfli','FLIGrabRow',fli_dev.value,fli_row,uint32(2*fix(mag_ccd_size(2)/mag_bin))));
            mag_m0(row,:)=double(fli_row.value);
            if rem(row,200)==0
                pause(0.001); % During readout permit user interaction.
            end
        end
        mag_process; % Do everything.
    end
    if mag_fli_return ~= 0
        % Accumulated camera status error. This is bad.
        fprintf(mag_log,['mag_fli_exposure: ' mag_fli_return sprintf('\n')]);
        throw(ME); % create exception for catch
    end
catch ME
   fprintf(mag_log,['FLI Camera error' sprintf('\n')]);
    mag_fli; % reinitialize
end