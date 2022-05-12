% Process image
% Copyright John Kuehne, 2010, 2011, 2012, 2013, 2014

try
    switch mag_orientation
        case 1
            % SES is correct N-S and E-W in field mode
            if (mag_axis == 1)
                mag_m0 = fliplr(mag_m0); % and flip E-W if in slit mode
            end
        case 2
            % ES2 Alta is upside down and flipped E-W relative to SES
            mag_m0 = flipud(mag_m0);
            if (mag_axis == -1)
                mag_m0 = fliplr(mag_m0); % and flip E-W if in field mode
            end
        case 3
            mag_m0 = flipud(mag_m0); % flip N-S
        case 4
            % WHT
            mag_m0 = fliplr(mag_m0); % flip E-W
        case 5
            mag_m0=mag_m0'; % transpose
            mag_m0 = flipud(mag_m0);
        case 6
            mag_m0=mag_m0'; % transpose
            mag_m0 = flipud(mag_m0); % flip N-S
            mag_m0 = fliplr(mag_m0); % flip E-W
        case 7
            % ES2 rotated CCW 90 looking skyward, i.e. N => E
            mag_m0=mag_m0'; % transpose
            mag_m0 = fliplr(mag_m0); %
            if (mag_axis == 1)
                mag_m0 = flipud(mag_m0); % flip N-S if in slit mode
            end
        case 8
            mag_m0=mag_m0'; % transpose
            mag_m0 = fliplr(mag_m0); % flip E-W
        case 9
            mag_m0=mag_m0'; % transpose
            % ES2 rotated CCW 270 looking skyward, i.e. N => W
            if (mag_axis == -1)
                mag_m0=flipud(mag_m0); % transpose
            end
    end
    mag_m0_display = mag_m0; % Used to contrast and brightness display, so they don't work on mag_m0 as it is being read and oriented.
    
    try
        mag_window_size_bin = fix(mag_window_size/mag_bin);
        mag_image_prep = mag_m0(round(mag_window_cen(2)/mag_bin)-fix(mag_window_size_bin*mag_aspect):...
            round(mag_window_cen(2)/mag_bin) + fix(mag_window_size_bin*mag_aspect), ...
            round(mag_window_cen(1)/mag_bin)-mag_window_size_bin:...
            round(mag_window_cen(1)/mag_bin)+ mag_window_size_bin);
    catch
        fprintf(mag_log,['Guider box not in image. No guiding.' sprintf('\n')]);
        mag_image_prep=zeros([round(mag_window_size/mag_bin) round(mag_window_size/mag_bin)]); % Bomb next calculations
    end
    
    % Set noise floor to zero -- this is the most critical requirement to
    % get a good least squares solution.
    mag_patch_safe =  min([length(mag_image_prep)-1  mag_patch]);
    [mag_ready, mag_end] = mag_prep(mag_image_prep, mag_patch_safe,mag_aggression);
    
    
    if (mag_axis == -1) % Be more aggressive in field mode, more sensitive in slit
        mag_ready = mag_erase(mag_ready); % Erase single, double,
        mag_ready = mag_erase(mag_ready); % and open triple shot.
        mag_ready = mag_clean(mag_ready); % Erase snug triple and quadruple spots.
    end
    
    mag_peak = max(max(mag_ready));
    mag_pixel_sum = sum(sum(mag_ready));
    
    [mag_ready_row, mag_ready_col] = size(mag_ready);
    mag_marginal_c = (1:mag_ready_col)' - (mag_ready_col+1)/2;
    mag_marginal_r = (1:mag_ready_row)' - (mag_ready_row+1)/2;
    % Marginal centroid for field mode, and as a check against least squares solution.
    if (mag_pixel_sum ~= 0)
        mag_marginal_x = sum(mag_ready);
        mag_marginal_y = sum(mag_ready,2)';
        mag_marginal_xcen = (mag_marginal_x * mag_marginal_c)/mag_pixel_sum * mag_bin;
        mag_marginal_ycen = (mag_marginal_y * mag_marginal_r)/mag_pixel_sum * mag_bin;
    else
        mag_marginal_xcen = NaN;
        mag_marginal_ycen = NaN;
    end
    
    if (mag_axis == 1)
       % Slit mode uses Gaussian PSF via least squares of logarithm so that the slit
       % does not affect the centroid.
       [mag_my,mag_mx,mag_mf] = mag_cen_s(mag_ready); % Least square solution.
       mag_mf = mag_mf / mag_scale * mag_bin; % Scale fwhm in pixel units to arcseconds.
       % Scale to unbinned pixel units.
       mag_mx = mag_mx * mag_bin;
       mag_my = mag_my * mag_bin;
       
       % If marginal centroid is more than a half slit width away, fail.
       if (sqrt((mag_mx-mag_marginal_xcen)^2 + (mag_my-mag_marginal_ycen)^2)...
         > mag_slit_size(1) * mag_scale/2)
          mag_mf = NaN; mag_mx = NaN; mag_my = NaN;
       end
    else
       % Field mode uses center of mass and calculates the FWHM from the integral
       % and mag_peak as the estimate of the the Gaussian height.
       mag_mx = mag_marginal_xcen;
       mag_my = mag_marginal_ycen;
       try
          mag_mf = 2*sqrt(2*log(2)) * sqrt(mag_pixel_sum/mag_peak/2/pi) / mag_scale * mag_bin;
       catch
          mag_mf = NaN;
       end
    end

    if (abs(round(mag_my)) > mag_window_size) || (abs(round(mag_mx)) > mag_window_size) ...
       || (isreal(mag_mf)==0) || (mag_mf<0)
        % Centroid is outside guider box or mag_cen_s failed or crazy FWHM. Abandon.
        mag_mf = NaN; mag_mx = NaN; mag_my = NaN;
    end
    
    mag_raw_size = size(mag_m0); % used in mag_move_fiducial
    
    % Snip out image on which to guide. First see if the user asked for a
    % new window size.
    if fix(str2double(get(mag_handles.width,'string'))/2) ~= mag_window_size
        mag_window_size = fix(str2double(get(mag_handles.width,'string'))/2);
        mag_box; % Macro to set the guider box drawn in raw image.
        mag_window_changed = 1; % for resizing figure below
    end
    
    if ishandle(fh1)==0 % Need to create the figure for the whole image.
        fh1 = figure(1);
        set(fh1,'menubar','none','pos',[60    60   530   568]);
        esc_string='currentkey'; % Gives you all the key down data
        set(fh1,'KeyPressFcn','mag_current_character=get(fh1,esc_string);');
        set(fh1,'KeyReleaseFcn','mag_current_character=[];');
        set(fh1,'name','Entire Image','numbertitle','off','pointer',...
            'cross','busy','queue','inter','off','closerequestfcn','1;');
        f11 = imagesc(ones(mag_ccd_size));
        set(f11,'ButtonDownFcn','mag_fiducial','inter','off','BusyAction','queue');
        set(fh1,'WindowButtonMotionFcn','mag_move_fiducial');
        axis('equal','tight');
        hold on
        f12 = plot(50, 350, 'O', ...
            'markersize', 18,'linewidth',2,'hittest','off','color',...
            'yellow','hittest','off');
        f13 = plot(mag_slit_cen(1), mag_slit_cen(2), '+', 'color', ...
            'red', 'markersize', 18,'linewidth',2,'hittest','off');
        f14 = title(['Guide box at ' num2str(mag_window_cen) ...
            ' (Shift-click to place)' mag_newline 'Field marker (X) at ' ...
            num2str(mag_field_cen) ' (Alt-click to place while in Field mode)' mag_newline ...
            'Left-click to place FROM *, Right-click to place TO o']);
        f15 = xlabel('CCD Pixel');
        f16 = ylabel('CCD Pixel');
        % f17 is defined in the macro mag_box
        f18 = plot(50,250,'*','markersize',24,'hittest','off','linewidth',...
            2,'color','yellow');
        f19 = plot(mag_field_cen(1),mag_field_cen(2),'X','markersize',24,...
            'hittest','off','linewidth', 2,'color','blue');
        mag_box; % Macro to draw box
        mag_graymap=colormap('gray');
        f110=uicontrol('style','push','string','Move * to o', 'fontweight','bold', ...
            'fontsize',12,'position',[30 5 100 30], 'callback','mag_go','inter','off','busy','queue');
        f111=uicontrol('style','slider', 'units','norm', 'position',[0.95 0.1 0.02 0.3], 'value', 2.5, 'max', 5,'min', 1/2,'callback',...
            'mag_contrast_entire','inter','off','busy','cancel');
        f112=uicontrol('style','text','units','norm','position',[.95 .05 0.03 0.03],'string','C');
        f113=uicontrol('style','slider', 'units','norm', 'position',[0.95 0.5 0.02 0.3], 'value', 0, 'max', 1,'min', -1,'callback',...
            'mag_brighten=brighten(mag_graymap,get(f113,''value''));colormap(get(f11,''parent''),mag_brighten);set(f113,''tooltip'',[''BRIGHTNESS:'' mag_newline sprintf(''%0.2f'',get(f113,''value''))])','inter','off','busy','cancel');
        f114=uicontrol('style','text','units','norm','position',[.95 .45 0.03 0.03],'string','B');
        if get(mag_handles.slit,'value') == 1
            set(f19,'XData', NaN, 'YData', NaN);
            mag_axis = 1; % Camera is slit view
        else
            mag_axis = -1; % field view
        end
        mag_line = line([get(f12,'XData') get(f18,'XData')],...
            [get(f12,'YData') get(f18,'YData')],'linewidth',2,'color',...
            'yellow','linestyle','--','hittest','off');
        hold off
    end
    set(f11,'XData',1:mag_ccd_size(2),'YData', 1:mag_ccd_size(1));
    mag_m0_max = max(max(mag_m0)); % Normalize mag_m0
    set(f11,'cdata',imadjust(mag_m0/mag_m0_max,stretchlim(mag_m0/mag_m0_max,10^(-1*get(f111,'value')))));

    
    if ishandle(fh2)==0 % Need to create the figure for the guider image.
        fh2 = figure(2);
        set(fh2,'menubar','none','pos',[120    120   530   568]);
        set(fh2,'name','Guide Box','numbertitle','off','pointer',...
            'cross','busy','queue','inter','off','closerequestfcn','1;');
        f21 = imagesc(mag_marginal_c, mag_marginal_r, ...
                zeros(mag_ready_row, mag_ready_col));
        set(f21,'ButtonDownFcn','mag_target','inter','off','BusyAction','queue');
        set(fh2,'WindowButtonMotionFcn','mag_move_target');
        axis('equal','tight');
        hold on
        f22 = plot(0, 0, 'x', 'color', 'red', 'markersize', 18,...
            'hittest','off','linewidth',2);
        f23 = plot(0, 0, 'o', 'color', 'red', 'markersize', 18,...
            'hittest','off','linewidth',2);
        f24 = plot(mag_target_cen(1), mag_target_cen(2), '+', 'color', ...
            'red', 'markersize', 36,'hittest','off','linewidth',2);
        mag_string = sprintf('%7.2f',mag_slit_cen);
        f25 = title(['Target (+) at' mag_string ...
            '   (Right-click to place)']);
        f26 = xlabel('Relative CCD Pixel');
        f27 = ylabel('Relative CCD Pixel');
        colormap('gray');
        f211=uicontrol('style','slider', 'units','norm', 'position',[0.95 0.1 0.02 0.3], 'value', 2.5, 'max', 5,'min', 1/2,'callback',...
            'mag_contrast_guide','inter','off','busy','cancel');
        f212=uicontrol('style','text','units','norm','position',[.95 .05 0.03 0.03],'string','C');
        f213=uicontrol('style','slider', 'units','norm', 'position',[0.95 0.5 0.02 0.3], 'value', 0, 'max', 1,'min', -1,'callback',...
            'mag_brighten=brighten(mag_graymap,get(f213,''value''));colormap(get(f21,''parent''),mag_brighten);set(f213,''tooltip'',[''BRIGHTNESS:'' mag_newline sprintf(''%0.2f'',get(f213,''value''))])','inter','off','busy','cancel');
        f214=uicontrol('style','text','units','norm','position',[.95 .45 0.03 0.03],'string','B');
        f29 = get(f21,'parent'); % Axes handle
        set(f29,'color',[0 0 .5]); % Set axis background color for Alpha channel transparency
        f30 = plot(0,0,'g+'); set(f30,'hittest','off');
        f31 = uicontrol('style','checkbox', 'units','norm', 'position',[.8, .005 .2 .05], 'string', 'Show Pixel Markers','inter','off','busy','cancel');
        hold off
    end
    set(f21,'XData',mag_marginal_c,'YData', mag_marginal_r);
    mag_prep_max = max(max(mag_image_prep)); % Normalize mag_m0
    set(f21,'cdata',imadjust(mag_image_prep/mag_prep_max,stretchlim(mag_image_prep/mag_prep_max,10^(-1*get(f211,'value')))));
    set(f22,'XData', mag_mx, 'YData', mag_my); % Image centroid,
    set(f23,'XData', mag_mx,'YData',mag_my);   % with a circle around it.
    if get(f31,'value') == 1 % show pixel markers
        [mag_rscatter,mag_cscatter] = find(mag_ready>0); % Highlight/mark pixels used in LS estimate
        set(f30,'hittest','off','xdata',(mag_cscatter-mag_window_size_bin-1)*mag_bin,'ydata',(mag_rscatter-fix(mag_window_size_bin*mag_aspect)-1)*mag_bin);
    else
        set(f30,'xdata',NaN, 'ydata', NaN)
    end
    if mag_window_changed == 1
        set(f24,'XData',NaN,'YData',NaN); % temporarily hide target in case out of bounds
        axes(f29); axis('equal','tight'); % adjust figure
        if abs(mag_target_cen(1))<mag_window_size && abs(mag_target_cen(2))<mag_window_size,
            set(f24,'XData',mag_target_cen(1),'YData',mag_target_cen(2)); % show target if inside window.
        end
        mag_window_changed = 0;
    end
    
    mag_mx = (mag_mx - mag_target_cen(1)) / mag_scale; % scale in arcseconds.
    mag_my = (mag_my - mag_target_cen(2)) / mag_scale;
    
    try
        % Get rotation from a file. Programs writing to this file
        % should first write to a temp file, then rename.
        load('mag_rotate');
    catch % default to 0 in case observer clobbered the file
        mag_rotate = 0;
    end
    mag_matrix = [cos(mag_rotate), -sin(mag_rotate)
        sin(mag_rotate),  cos(mag_rotate)];  % rotation matrix
    
    mag_twist = mag_matrix * [mag_mx, mag_my]';
    
    mag_mx = mag_twist(1);
    mag_my = mag_twist(2);
    
    mag_clock = clock;
    mag_seconds = mag_clock(3)*24*60*60 + mag_clock(4)*60*60 + ...
        mag_clock(5)*60 + mag_clock(6);
    
    fprintf(mag_log,'%12.3f %6.0f %6.0f %6.3f %6.3f %6.3f %6.3f %6.0f\n', ...
        [ mag_seconds mag_end mag_peak mag_pixel_sum mag_mf mag_mx mag_my mag_rotate]);
    
    mag_average_adu = mag_average_adu + 1; % Denominator i.e. count.
    mag_value = get(mag_handles.avpeak, 'value');
    mag_value = mag_value + mag_peak;
    set(mag_handles.avpeak,'value',mag_value);
    set(mag_handles.avpeak,'string',fix(mag_value/mag_average_adu));
    set(mag_handles.peak,'string',fix(mag_peak));
    
    mag_value = get(mag_handles.avfloor, 'value');
    mag_value = mag_value + abs(mag_end);
    set(mag_handles.avfloor,'value',mag_value);
    set(mag_handles.avfloor,'string',fix(mag_value/mag_average_adu));
    set(mag_handles.floor,'string',fix(abs(mag_end)));
    
    if (mag_mf>0)
        mag_average_mf = mag_average_mf + 1; % Denominator i.e. count.
        mag_value = get(mag_handles.avFWHM, 'value');
        mag_value = mag_value + mag_mf;
        set(mag_handles.avFWHM,'value',mag_value);
        set(mag_handles.avFWHM,'string',fix(mag_value/mag_average_mf*100)/100);
        set(mag_handles.FWHM,'string',fix(mag_mf*100)/100); % Funny way to format.
    end
    
    if (toc(mag_guide82_timer) > mag_guide82_expire) && (mag_guide_on == 1)
        % Adjust track rate every turn of the final worm (2 minutes).
        mag_guide82_offset_counter = mag_guide82_offset_counter * toc(mag_guide82_timer); % c.f. denominator below
        try
            if mag_guide82_offset_counter > 0
                % new rate deviation = old rate + required rate (note position
                % loop tends to reduce the estimate of required rate.)
                mag_guide82_rate = mag_guide82_rate + mag_guide82_offset/mag_guide82_offset_counter;
                if abs(mag_guide82_rate) > 0.005 % Keep it reasonable for the 82"
                    mag_guide82_rate = sign(mag_guide82_rate)*0.005;
                end
                mag_str = [mag_tcs '/point_guide82 ' num2str(mag_guide82_rate,'%.4f')]; % Ask TCS to update the track rates.
                mag_reply = urlread(mag_str);
                fprintf(mag_log,[mag_str sprintf('\n')]);
            end
        catch
            fprintf(mag_log,['Error adjusting track rate.' sprintf('\n')]);
            set(mag_handles.messages,'string','Error adjusting track rate.');
        end
        mag_guide82_offset = 0; % Reset for next 2 minute period.
        mag_guide82_offset_counter = 0;
        mag_guide82_timer = tic;
    end
    
    if (mag_mf > 0) % Possibly move the telescope.
        if (mag_guide_on == 1) % Send guide steps
            % to Track82 via HTTP, except for single exposure (time<0).
            set(mag_handles.messages,'string',''); % Clear message
            % Accumuate error for estimating track rate every 2 minutes.
            mag_guide82_offset = mag_guide82_offset + mag_mx;
            % Keep track of how many accumulated for average rate.
            mag_guide82_offset_counter = mag_guide82_offset_counter + 1;
            % Now apply proportional gains for comparisons.
            mag_my = -(mag_my) * mag_py;
            mag_mx = (mag_mx) * mag_px;
            if (abs(mag_my) > mag_hy)
                % Only move when value exceeds deadband and is safe.
                if (abs(mag_my) > mag_max_y)
                    mag_my = sign(mag_my)*mag_max_y; % Maximum safe move
                end
                mag_str = [mag_tcs '/stepdec ' num2str(mag_my,'%.4f')]; % TCS
                try
                    mag_reply = urlread(mag_str);
                catch
                    fprintf(mag_log,['Track82 not responding for stepdec.' sprintf('\n')]);
                    set(mag_handles.messages,'string','Track82 not responding. No guiding.');
                end
                set(f22,'color','red');
            else
                set(f22,'color','green'); % signal observer no move needed.
            end
            if (abs(mag_mx) > mag_hx)
                % Only move when value exceeds deadband and is safe.
                if (abs(mag_mx) > mag_max_x)
                    mag_mx = sign(mag_mx)*mag_max_x; % Maximum safe move
                end
                mag_str = [mag_tcs '/stepra ' num2str(mag_mx,'%.4f')]; % Prometheus.as.utexas.edu
                try
                    mag_reply = urlread(mag_str);
                catch
                    fprintf(mag_log,['Track82 not responding for stepra.' sprintf('\n')]);
                    set(mag_handles.messages,'string','Track82 not responding. No guiding.');
                end
                set(f23,'color','red');
            else
                set(f23,'color','green');
            end
        else
            set(f22,'color','red'); % No guiding occurred - set the markers to
            set(f23,'color','red'); % their default color.
        end
    else
        if (mag_guide_on==1) % Report centroid status.
            set(mag_handles.messages,'string','Centroid not found. No guiding');
        else
            set(mag_handles.messages,'string','');
        end
    end
    
    if (mag_focus_done == 1)
        try % to delete the figure
            delete(fh4); pause(1);
        catch
            fprintf(mag_log,['Focus window cannot be deleted!' sprintf('\n')]);
        end
        mag_focus_done = 0;
    end
    if (ishandle(fh4)==0) && (mag_focus_done==-1)
        % There's no figure and we need one
        mag_focus_done=0;
        mag_focus_previous=0;
        mag_focus_data=[NaN NaN NaN];
        fh4=figure(4);
        set(fh4,'menubar','none','name','Focus82 (waiting for an image)','numbertitle','off','busy','cancel','inter','off');
        set(fh4,'closerequestfcn','mag_focus_done=1;','pos',[3 45 560 420]);
        esc_string='currentkey'; % Gives you all the key down data
        set(fh4,'KeyPressFcn','mag_current_character=get(fh1,esc_string);');
        hold on
        for mag_a=2:83,
            eval(['f5' num2str(mag_a) '=plot(NaN,NaN,''+'',''markersize'',18,''linewidth'',3,''ButtonDownFcn'',''mag_marker=', num2str(mag_a), ';mag_toggle_marker'',', '''inter'',''off'',''BusyAction'',''queue'');']); % Create 82 markers
        end
        f41=title('');
        f42=xlabel(['Focus encoder' mag_newline 'Click on the figure to show parabolic solution' mag_newline 'Click on a symbol to add/remove from solution']);
        f43=ylabel('FWHM');
        f45=plot(NaN); % parabola
        set(f45,'hittest','off'); % Get curve out of way of markers
        set(get(f45,'parent'),'buttondownfcn','mag_parabola'); % Update solution when click on figure
        f46=plot(NaN,NaN,'*','color','red'); % minimum point on parabola
        grid on
        hold off
    end
    
    if (ishandle(fh4)==1); % Focus window is up for processing.
        [mag_row, mag_col]=size(mag_focus_data); % NB starts out [NaN NaN NaN], hence first data index is 2
        if (mag_row<82) % 82 markers pre-allocated in mag_focus
            if (mag_mf>0) % The FWHM (and centroid) calculation succeeded.
                try % Protect main event loop.
                    mag_focus_val=str2double(urlread([mag_tcs '/findfocus'])); % Focus value from Track82
                    if abs(mag_focus_previous-mag_focus_val)<2 % demand it not be changing except for flicker (mag_focus_previous set to 0 at focus button)
                        mag_index=find(mag_focus_data(:,1)==mag_focus_previous);% Attempt to find index for this focus value
                        if isempty(mag_index)==1 % There's no such focus in our list, so make a new entry
                            mag_row=mag_row+1; % Index in which to stuff next unique focus value data
                            mag_focus_data(mag_row,1)=mag_focus_previous; % New focus value
                            mag_focus_data(mag_row,2)=mag_mf; % FWHM at this focus value
                            mag_focus_data(mag_row,3)=1; % Number of FWHM estimates accumulated at this focus
                            eval(['set(f5' num2str(mag_row) ',''xdata'',' num2str(mag_focus_previous) ',''ydata'',' num2str(mag_mf) ')']);
                        else
                            mag_focus_data(mag_index,2)=mag_focus_data(mag_index,2)+mag_mf; % Add focus value for average
                            mag_focus_data(mag_index,3)=mag_focus_data(mag_index,3)+1; % Keep track of count for average
                            eval(['set(f5' num2str(mag_row) ',''xdata'',' num2str(mag_focus_previous) ',''ydata'',' num2str(mag_focus_data(mag_index,2)/mag_focus_data(mag_index,3)) ')']);
                        end
                        mag_ab_min=min(mag_focus_data(2:mag_row,1))-1;
                        mag_ab_max=max(mag_focus_data(2:mag_row,1))+1;
                        mag_ba_max=max(mag_focus_data(2:mag_row,2)./mag_focus_data(2:mag_row,3))+1;
                        set(get(f45,'parent'),'xlim',[mag_ab_min mag_ab_max],'ylim',[0 mag_ba_max]); % Fix limits
                    else
                        mag_focus_previous = mag_focus_val;% set for next iter. Only change when needed, so single count flicker doesn't affect mag_focus_previous
                    end
                catch
                    fprintf(mag_log,['Some bad shit happened acquiring focus data!' sprintf('\n')]);
                end
            end
        else % Stop collecting points and start curve fitting
            set(fh4,'name','Focus82 (Finished at maximum number of points)')
        end
    end
    
catch me
    fprintf(mag_log,['Process Error.' me.message sprintf('\n')]);
    questdlg('Something is wrong with the camera data. Check your setup and restart Guide82.','Question','OK','OK');
    %quit force
end
