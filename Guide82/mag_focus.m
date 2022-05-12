% Not ever called - this code is in-line in mag_process
mag_focus_done=0;
mag_focus_previous=0;
mag_focus_data=[NaN NaN NaN];
fh4=figure(4);
set(fh4,'menubar','none','name','Focus82 (waiting for an image)','numbertitle','off','busy','cancel','inter','off','pos',[3 45 560 420]);
set(fh4,'closerequestfcn','mag_focus_done=1;');
esc_string='currentkey'; % Gives you all the key down data
set(fh4,'KeyPressFcn','mag_current_character=get(fh1,esc_string);');
hold on
for mag_a=2:83,
    eval(['f5' num2str(mag_a) '=plot(NaN,NaN,''+'',''markersize'',18,''linewidth'',3,''ButtonDownFcn'',''mag_marker=', num2str(mag_a), ';mag_toggle_marker'',', '''BusyAction'',''cancel'');']); % Create 82 markers
end
f41=title('');
f42=xlabel(['Focus encoder' mag_newline 'Click on the figure to show parabolic solution' mag_newline 'Click on a symbol to add/remove from solution']);
f43=ylabel('FWHM');
f45=plot(NaN); % parabola
set(f45,'hittest','off'); % Get curve out of way of markers
set(get(f45,'parent'),'buttondownfcn','mag_parabola'); % Update solution when click on figure
f46=plot(NaN,NaN,'*','color','red'); % minimum point on parabola
grid on
hold off

