% Save marker locations in directory set in mag_setup

mag_answer = questdlg('Please confirm (Save will overwrite the existing markers file)',...
    'Question','Save','Cancel','Cancel');
if strcmp(mag_answer, 'Save')
    save('mag_window_cen', 'mag_window_cen', '-ascii');
    save('mag_field_cen', 'mag_field_cen', '-ascii');
    save('mag_slit_size', 'mag_slit_size', '-ascii');
    save('mag_slit_cen', 'mag_slit_cen', '-ascii');
end