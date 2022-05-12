mag_cp_click = get(get(f21,'parent'),'currentpoint');

if (abs(mag_cp_click(1,1)) < mag_window_size) && (abs(mag_cp_click(1,2)) < mag_window_size)
    if strcmp(get(2,'selectiontype'),'alt')
        set(f24,'XData', mag_cp_click(1,1), 'YData', mag_cp_click(1,2));
        mag_target_cen = [mag_cp_click(1,1) mag_cp_click(1,2)];
        
        mag_slit_cen = mag_window_cen + mag_target_cen;
        if ishandle(fh1)
            set(f13,'XData',mag_slit_cen(1),'YData',mag_slit_cen(2));
        end
        
        mag_string = sprintf('%7.2f',mag_slit_cen);
        set(f25,'string',['Target (+) at' mag_string ...
            '   (Right-click to place)']);
    end
end