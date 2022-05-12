try % See if there's a parabolic solution and plot it
    [row,column]=size(mag_focus_data);
    mag_ls_data=zeros(size(mag_focus_data)); % Zeros initialize least square matrix for missing data
    
    for mag_a=2:row, % Build least squares matrix from + marked data
        eval(['mag_symbol=get(f5' num2str(mag_a) ',''marker'');']);
        if strcmp(mag_symbol,'+')==1
            mag_ls_data(mag_a,1)=1;
            mag_ls_data(mag_a,2)=mag_focus_data(mag_a,1)- mag_ab_min(1); % rescale abscissa starting at one to avoid squaring giant numbers
            mag_ls_data(mag_a,3)=(mag_focus_data(mag_a,1)- mag_ab_min(1))^2; % rescale abscissa starting at one to avoid squaring giant numbers
            mag_ls_data(mag_a,4)=mag_focus_data(mag_a,2)/mag_focus_data(mag_a,3); % average FWHM - when you sit on a value, adds up.
        else
            continue;
        end
    end
    
    mag_solution=mag_ls_data(:,1:3)\mag_ls_data(:,4); % That's Least Squares
    mag_ab = 0:1/82:mag_ab_max(1)-mag_ab_min(1); % rescaled abscissa
    mag_ls_plot=mag_solution(1) + mag_solution(2)*mag_ab + mag_solution(3)*mag_ab.^2;
    set(f45,'xdata',mag_ab+mag_ab_min(1),'ydata',mag_ls_plot); % rescaled abscissa
    mag_opt_x=-mag_solution(2)/mag_solution(3)/2; % That's Calculus
    mag_opt_y=mag_solution(1)+mag_solution(2)*mag_opt_x+mag_solution(3)*mag_opt_x^2;
    set(f46,'xdata',mag_opt_x+mag_ab_min(1),'ydata',mag_opt_y); % rescaled abscissa
    set(f41,'string',['Minimum at ' num2str(round(mag_opt_x+mag_ab_min(1)))]); % rescaled abscissa
end