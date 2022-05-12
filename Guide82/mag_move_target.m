mag_cp = get(get(f21,'parent'),'currentpoint');
if (abs(mag_cp(1,1)) < mag_window_size) && ...
        (abs(mag_cp(1,2)) < mag_window_size)
    try
    set(f26,'string',['Mouse at CCD Pixel '...
        num2str(round(mag_cp(1,1))+mag_window_cen(1)) ' ' num2str(round(mag_cp(1,2))+mag_window_cen(2)) ' (' num2str(mag_image_prep(round((mag_cp(1,2)+mag_window_size)/mag_bin) , round((mag_cp(1,1)+mag_window_size)/mag_bin))) ' ADU)' ]);
    catch % prevent fix from accessing off-image
    end
end

