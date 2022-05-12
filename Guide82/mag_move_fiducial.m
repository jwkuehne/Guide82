mag_cp = get(get(f11,'parent'),'currentpoint');

if (mag_cp(1,1) > 1) && (mag_cp(1,1) < mag_raw_size(2)*mag_bin) && ...
        (mag_cp(1,2) > 1) && (mag_cp(1,2) < mag_raw_size(1)*mag_bin)
    try
    set(f15,'string',['Mouse at CCD Pixel ' ...
        num2str(fix(mag_cp(1,1))) ' ' num2str(fix(mag_cp(1,2))) ' (' num2str(mag_m0(fix(mag_cp(1,2)/mag_bin), fix(mag_cp(1,1)/mag_bin))) ' ADU)']);
    catch % fix args to mag_m0 might be off the image e.g. 0,0
    end
else
    mag_current_character = []; % Takes care of the remote possibility that
    % the user held down on the Alt key while bringing up another window,
    % thereby never doing KeyReleaseFcn on figure 1.
end
