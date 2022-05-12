mag_cp_click = get(get(f11,'parent'),'currentpoint');
mag_loc = fix([mag_cp_click(1,1) mag_cp_click(1,2)]);
mag_switch_case = get(1,'selectiontype'); % read mouse modifier/key
if strcmp(mag_current_character,'alt')
    mag_switch_case = 'alt_key'; % if Alt key down, override
end
switch mag_switch_case
    case 'alt_key'
        if ~isnan(get(f19,'Xdata')) % Field marker is on,update it
            mag_field_cen = mag_loc;
            set(f19,'Xdata',mag_loc(1),'Ydata',mag_loc(2));
            set(f14,'string',['Guide box at ' num2str(mag_window_cen) ...
                ' (Shift-click to place)' mag_newline 'Field marker (X) at ' ...
                num2str(mag_field_cen) ' (Alt-click to place while in Field mode)' mag_newline ...
                'Left-click to place FROM *, Right-click to place TO o']);
        end
        mag_current_key = [];
    case 'alt'
        set(f12,'XData',mag_loc(1),'YData',mag_loc(2));
        mag_xdata = get(mag_line,'XData');
        mag_xdata(1) = mag_loc(1);
        mag_ydata = get(mag_line,'YData');
        mag_ydata(1) = mag_loc(2);
        set(mag_line,'XData',mag_xdata,'YData',mag_ydata);
    case 'extend'
        mag_window_changed = 1; % Update tight axes in case target is no longer in figure.
        mag_window_cen = mag_loc;
        mag_target_cen = mag_slit_cen - mag_window_cen;
        if ishandle(fh2)
            set(f24,'XData', mag_target_cen(1), 'YData', mag_target_cen(2));
        end
        mag_box; % Macro to draw box
        set(f14,'string',['Guide box at ' num2str(mag_window_cen) ...
            ' (Shift-click to place)' mag_newline 'Field marker (X) at ' ...
            num2str(mag_field_cen) ' (Alt-click to place while in Field mode)' mag_newline ...
            'Left-click to place FROM *, Right-click to place TO o']);
    case 'normal'
        mag_from = mag_loc;
        set(f18,'XData',mag_loc(1),'YData',mag_loc(2));
        mag_xdata = get(mag_line,'XData');
        mag_xdata(2) = mag_loc(1);
        mag_ydata = get(mag_line,'YData');
        mag_ydata(2) = mag_loc(2);
        set(mag_line,'XData',mag_xdata,'YData',mag_ydata);
end