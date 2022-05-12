if get(mag_handles.field,'value') == 1
    if ishandle(fh1)
        set(f19,'XData', mag_field_cen(1), 'YData', mag_field_cen(2));
    end
    mag_axis = -1; % Camera is field view
    mag_scale = mag_field_scale;
    mag_slit_on = 0; % Don't mask slit
else
    set(mag_handles.field,'value',1);
end
