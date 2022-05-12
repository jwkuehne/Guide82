if get(mag_handles.slit,'value') == 1
    if ishandle(fh1)
        set(f19,'XData', NaN, 'YData', NaN);
    end
    mag_axis = 1; % Camera is slit view
    mag_scale = mag_slit_scale;
    mag_slit_on = 1; % Resume slit behavior
else
    set(mag_handles.slit,'value',1);
end