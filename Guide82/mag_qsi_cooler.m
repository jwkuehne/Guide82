fh5=figure(5); % fh4 is reserved for focus
set(fh5,'menubar','none','position',[287   114   360   250],'name','QSI cooler','menubar','none','numbertitle','off');
f51=uicontrol('style','push','string','Cooler Off', 'fontweight','bold','fontsize',12,'position',[30 5 150 30], 'callback','h.CoolerOn=0;','inter','off','busy','queue');

f52=uicontrol('style','push','string','Cooler On/Set', 'fontweight','bold','fontsize',12,'position',[30 40 150 30], 'callback','h.CoolerOn=1; try, h.SetCCDTemperature=str2num(get(f55,''string'')); end','inter','off','busy','queue');

f57=uicontrol('style','text','string','deg C','HorizontalAlignment','left','fontweight','bold','fontsize',12,'position',[280 40 60 30],'inter','off','busy','queue');

mag_cooler_label = ['CoolerOn ' num2str(h.CoolerOn) mag_newline ...
'FanMode ' h.FanMode mag_newline ...
'CCDTemperature ' num2str(h.CCDTemperature) mag_newline ...
'CoolerPower ' num2str(h.CoolerPower) mag_newline ...
'HeatSinkTemperature ' num2str(h.HeatSinkTemperature) mag_newline];

f56=uicontrol('style','text','horizontalAlignment','left','string', mag_cooler_label,'fontweight','bold','fontsize',12,'position',[25 125 315 120],'inter','off','busy','queue');

f55=uicontrol('style','edit','string',num2str(h.SetCCDTemperature),'fontweight','bold','fontsize',12,'position',[200 40 70 30],'inter','off','busy','queue');

f57=uicontrol('style','push','string','Refresh', 'fontweight','bold','fontsize',12,'position',[30 75 150 30], 'callback','close(fh5); mag_qsi_cooler','inter','off','busy','queue');
