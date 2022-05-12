try
    calllib('libfli','FLIClose',fli_dev.value);
catch
    ['FLI driver did not close']
end
try
    unloadlibrary('libfli');
catch
    ['FLI driver did not unload']
end
try
    loadlibrary('libfli.dll',@fHeader); % load premade library, hacked for cstring to cstringPtr where needed, GetList removed (no triple pointers in matlab), etc
    p=libpointer('cstringPtr',char(ones(1,1024))); % initialize a string for the library version number
    calllib('libfli','FLIGetLibVersion',p,uint32(100)); % Get the library version number
    fli_domain=libpointer('longPtr',uint32(0)); % initialize opaque handle needed for Create
    fli_filename=libpointer('cstringPtr',char(ones(1,100))); % initialize the camera USB name
    fli_name=libpointer('cstringPtr',char(ones(1,100))); % initialize the camera model name
    calllib('libfli','FLICreateList',uint32(258)); % USB+Camera=258
    calllib('libfli','FLIListFirst',fli_domain,fli_filename,uint32(100),fli_name,uint32(100)); % get first camera
    fli_dev=libpointer('longPtr',uint32(0)); % initilize device
    calllib('libfli','FLIOpen',fli_dev,fli_filename.value,uint32(258)); % open the filename and return device
    
    % DANGER: if there's data ready from a previous connection, and you reconnect here, the data will
    % still be ready, but reading the rows won't clear the data ready status, and also doesn't seem to read anything. So always start
    % mag_fli by canceling the exposure to clear the status.
    calllib('libfli','FLICancelExposure', fli_dev.value); % Clear pending exposure and data.
    
    calllib('libfli','FLISetExposureTime',fli_dev.value,uint32(1000)); % set the exposure in milliseconds
    fli_temp=libpointer('doublePtr',uint32(0)); % initialize double for CCD temperatue
    calllib('libfli','FLIGetTemperature',fli_dev.value,fli_temp); % get the temperature
    fli_status=libpointer('longPtr',uint32(0)); % initialize status register
    fli_row=libpointer('uint16Ptr',uint16(ones(1,mag_ccd_size(2)))); % create row
    mag_bin = 1;
    callib('libfli','FLISetHBin',fli_dev.value,uint(mag_bin));
    callib('libfli','FLISetVBin',fli_dev.value,uint(mag_bin));
    calllib('libfli','FLISetImageArea',fli_dev.value,uint32(0),uint32(0),fix(mag_ccd_size(2)/mag_bin),fix(mag_ccd_size(1)/mag_bin));

    
    % Get frame with 1s exposure
    % calllib('libfli','FLIExposeFrame',fli_dev.value); % Expose
    % calllib('libfli','FLIGetDeviceStatus',fli_dev.value,fli_status); % get status
    
    % while (bitand(fli_status.value,3)>0),
    %     pause(0.1); % Not idle
    %     calllib('libfli','FLIGetDeviceStatus',fli_dev.value,fli_status);
    % end
    
    % Should check for 0X80000000 = 2147483648 (data ready) with bitand()
    % calllib('libfli','FLIGetDeviceStatus',fli_dev.value,fli_status);
    % fli_status.value
    % for row=1:mag_ccd_size(1),
    %      calllib('libfli','FLIGrabRow',fli_dev.value,fli_row,uint32(mag_ccd_size(2)*2));
    %      fli_frame(row,:)=fli_row.value;
    %  end
    
    % After reading the rows, the status goes from data ready to idle.
    
    
    calllib('libfli','FLIDeleteList'); % Free list
catch
    ['FLI failed'];
end