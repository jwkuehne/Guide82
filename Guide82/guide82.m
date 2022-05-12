% Initial workspace parameters and variables
%
% By John Kuehne 2014. McDonald Observatory of the University of Texas.

% Guide82 is an autoguider designed to work well even when the image is cut
% by a slit.

% mag_start_exposure is the only polling loop. It checks the status of the
% camera, grabs and processes ready images, and starts new exposures.
%
% mag_process does nearly all the work. It calls a few functions and .m
% files.
%
% Gui buttons and fields, created in Guide, interact through a few
% global variable and the Guide handle facility.
%
% Variables that need setup, like the inital location of the slit target,
% are read from the current directory, one file per variable, into the
% workspace, providing they exist.

try
    clear;
    warning off; % Toss frightening messages about rank matrices.
    
    global mag_camera mag_log h
    global mag_exposure_on mag_exposure_time mag_delay_time % Exposure vars.
    global mag_guide_on % Autoguider switch.
    global mag_average_adu mag_average_mf % Needed by Reset button for stats.
    
    % Display the log file name
    mag_temp_name = tempname;
    mag_log = fopen(mag_temp_name,'wt'); % safe place to log data.
    
    mag_setup; % User defined parameters in uparm directory, starting with
    % mag_camera and mag_instrument.
    
    mag_exposure_on = 0;   % Exposure on/off.
    mag_exposure_time = 1; % Exposure time - negative means single exposure
    mag_delay_time = 5;    % Delay between exposures
    mag_delay_counter = tic; % Accumulated delay time in exposure loop
    mag_guide82_expire = 120;% Compute track rate for 2-minute worm.
    mag_guide82_timer = tic; % Accumulated delay time in process loop for asking point_guide82.
    mag_guide82_offset = 0;% Accumalated centroid error to compute track rate deviation
    mag_guide82_offset_counter = 0; % Count of observations for average
    mag_guide82_rate = 0;  % deviation from track rate
    mag_stop_exposure = 0; % Set to 1 to command event loop.
    mag_guide_on = 0;      % Apply guide corrections to Track82 on/off.
    mag_rotate = 0;        % rotation matrix theta
    
    mag_mx = 0;            % Initialize guide offsets.
    mag_my = 0;
    
    mag_newline = sprintf('\n');
    
    fh1 = 2*asin(1.0); % Initialize figure handles
    mag_current_character = []; % Current character of fh1
    fh2 = fh1;         % irrational value in the hope ishandle returns 0.
    fh4 = fh1;
    mag_focus_done = 0;% Only the main event loop is allowed to close the window,
    mag_m_clear=1;     % Change in binning needs mag_m cleared for SBIG, FLI. Force code on startup in case it got changed before first readout.
    mag_window_changed = 0; % Notify process to resize figure.
    f21 = fh1;         % Guider window image handle.
    f17 = fh1;         % Guider box in raw image.
    f210= fh1;         % Slit box in Guide window
    
    mag_average_adu = 0; % Number of data to average for statistics.
    mag_average_mf  = 0; % Number of data to average for FWHM.
    
    if mag_camera==1 % Apogee Alta
        mag_apogee_alta
    end
    
    if mag_camera==2 % SBIG
        mag_sbig_st1603me
    end
    
    if mag_camera==3 % QSI
        mag_qsi
    end
    
    if mag_camera==4 % FILE
        mag_file
    end
    
    if mag_camera==5 % FLI
        mag_fli
    end
    
    mag=Main; % Create control panel
    set(mag,'name','Guide82','closerequestfcn','eval(''quit force'')');
    %set(mag,'pos',[96.6 38.3846 63.4 38.0769]);
    mag_handles = guihandles(mag); % Get structure of gui handles to set stats.
    set(mag_handles.width,'string',1+2*mag_window_size); % Initialize width of guider box.
    set(mag_handles.delay,'string',mag_delay_time);
    set(mag_handles.seconds,'string',mag_exposure_time);
    set(mag_handles.bin,'value',mag_bin);
    
    if get(mag_handles.slit,'value')==1
        set(f19,'XData',NaN,'YData',NaN);
        mag_axis=1;
        mag_scale = mag_slit_scale;
        mag_slit_on = 1;       % Slit mask on is 1
    else
        mag_axis=-1;
        mag_scale = mag_field_scale;
        mag_slit_on = 0;       % Slit mask on is 1
    end
    
    mag_load;
    
    mag_event=1;
    mag_start_exposure; % Event loop
    
catch ME
    fprintf(mag_log,['Error starting Guide82' sprintf('\n')]);
    questdlg(ME.message,'Question','OK','OK');
    exit
end

