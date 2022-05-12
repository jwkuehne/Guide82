% Set/reset the box drawn in raw image, showing the guide box.
mag_linex = [mag_window_cen(1)-mag_window_size mag_window_cen(1)+...
    mag_window_size mag_window_cen(1)+mag_window_size ...
    mag_window_cen(1)-mag_window_size]';
mag_linex(5) = mag_linex(1);
mag_liney = [mag_window_cen(2)+mag_window_size*mag_aspect mag_window_cen(2)+...
    mag_window_size*mag_aspect mag_window_cen(2)-mag_window_size*mag_aspect ...
    mag_window_cen(2)-mag_window_size*mag_aspect]';
mag_liney(5) = mag_liney(1);
if ishandle(f17)
    set(f17,'xdata',mag_linex,'ydata',mag_liney);
else
    if ishandle(fh1)
        figure(fh1);
        f17 = line(mag_linex,mag_liney);
        set(f17,'linewidth',2,'color','green','hittest','off');
    end
end