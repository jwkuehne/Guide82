% Load targets from directory set in mag_setup

try
    load('mag_window_cen');
end

try
    load('mag_field_cen');
end

try
    load('mag_slit_size');
end

try
    load('mag_slit_cen');
end

mag_target_cen = mag_slit_cen - mag_window_cen;

mag_string = sprintf('\n');
if ishandle(fh1)
    if get(mag_handles.field,'value') == 1
        set(f19,'XData', mag_field_cen(1), 'YData', mag_field_cen(2));
    end
    if get(mag_handles.slit,'value') == 1
        set(f19,'XData', NaN, 'YData', NaN);
    end
    set(f13,'XData', mag_slit_cen(1), 'YData', mag_slit_cen(2));
    set(f14,'string',['Guide box at ' num2str(mag_window_cen) ...
                ' (Shift-click to place)' mag_newline 'Field marker (X) at ' ...
                num2str(mag_field_cen) ' (Alt-click to place while in Field mode)' mag_newline ...
                'Left-click to place FROM *, Right-click to place TO o']);
    mag_box;
    
    
end

if ishandle(fh2)
    set(f24,'XData', mag_target_cen(1), 'YData', mag_target_cen(2));
    mag_string = sprintf('%7.2f',mag_slit_cen);
    set(f25,'string',['Target (+) at' mag_string ...
        '   (Right-click to place)']);
end