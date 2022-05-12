mag_gox = (get(f18,'XData') - get(f12,'XData')) / mag_scale;
mag_goy = (get(f18,'YData') - get(f12,'YData')) / mag_scale;

if (abs(mag_gox) + abs(mag_goy)) > 2*eps
        
    set(mag_handles.autoguide,'value',0); % Turn off autoguiding
    mag_guide_on = 0; % by telling Guide82 about it, and setting the button.
    set(mag_handles.autoguide,'backgroundcolor',[0.9255 0.9137 0.8471]);
    
    try
        % Get rotation from a file. Programs writing to this file
        % should first write to a temp file, then rename.
         load('mag_rotate');
    catch
        mag_rotate = 0;
    end
    mag_matrix = [cos(mag_rotate), -sin(mag_rotate)
                  sin(mag_rotate),  cos(mag_rotate)];  % rotation matrix
    
    mag_twist = mag_matrix * [mag_gox, mag_goy]';
    
    mag_gox = mag_twist(1);
    mag_goy = -1*mag_twist(2);
    
    
    mag_str = [mag_tcs '/stepdec ' num2str(mag_goy)]; % TCS host
    try
        mag_reply = urlread(mag_str);
        set(mag_handles.messages,'string','');
    catch
        set(mag_handles.messages,'string','Track82 not responding. No move.');
    end
    
    mag_str = [mag_tcs '/stepra ' num2str(mag_gox)]; % Prometheus.as.utexas.edu
    try
        mag_reply = urlread(mag_str);
        set(mag_handles.messages,'string','');
    catch
        set(mag_handles.messages,'string','TCS not responding. No move.');
    end
    
    % Move the * into the o to help the observer understand the move.
    set(f18,'XData',get(f12,'XData'));
    set(f18,'YData',get(f12,'YData'));
    set(mag_line,'XData',[get(f12,'XData') get(f12,'XData')], 'YData', ...
        [get(f12,'YData') get(f12,'YData')]); % Zero length line
    
end