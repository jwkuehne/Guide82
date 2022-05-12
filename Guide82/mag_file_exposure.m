if mag_stop_exposure==1 % not needed for file, but just to be clean.
    mag_stop_exposure=0;
end

if (toc(mag_delay_counter)>mag_delay_time) && (mag_exposure_on==1)
    try % to read the image data
        [mag_m0] = double(fitsread('Z:\temp.fits')); % image
        mag_bin = get(mag_handles.bin, 'value'); % could get from FITS key
        set(mag_handles.seconds,'string','-'); % could set from FITS key
        mag_process; % Do everything.
        mag_delay_counter=tic;
        try
            delete('Z:\temp.fits'); % delete file tells writer we're ready for next
        catch % horror
            fprintf(mag_log,['FITS file would not delete' sprintf('\n')]);
            mag_file; % try clean start
        end
    catch ME% no file to read or read error
        if (strcmp(ME.identifier,'MATLAB:imagesci:validate:fileOpen'))
            % No file when fitsread tried, but a race condition could mean
            % there is one now, so don't do anything.
        else
            % There was some other error, so clear the file.
            try
                delete('Z:\temp.fits'); % delete file tells writer we're ready for next
            catch % horror
                fprintf(mag_log,['FITS file would not delete' sprintf('\n')]);
                mag_file; % try clean start
            end
        end
    end
end

