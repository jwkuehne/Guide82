%loadlibrary('./SBIGUDrv.dll','./Sbigudrv.h');
% Deployed apps must use pre-made header.
loadlibrary('./SBIGUDrv.dll',@mHeader);
vp=libpointer('voidPtr'); % Make a void pointer
% Open SBIG driver. 17 is the code for CC_OPEN_DRIVER
h=calllib('SBIGUDrv','SBIGUnivDrvCommand',17,vp,vp);
if h~=0
    fprintf(mag_log,['SBIG driver not found' sprintf('\n')]);
    questdlg('SBIG driver not found. Place a copy of SBIGDrv.dll and Sbigudrv.h in the startup directory. Guide82 will Quit.','Question','OK','OK');
    exit
end
s=libstruct('OpenDeviceParams');
s.deviceType=32512; % 0x7F00 is USB
s.lptBaseAddress=0;
s.ipAddress=0;
% Open next USB device;
h=calllib('SBIGUDrv','SBIGUnivDrvCommand',27,s,vp);
if h~=0
    fprintf(mag_log,['SBIG USB camera not found' sprintf('\n')]);
    questdlg('SBIG USB camera not found. Guide82 will Quit.','Question','OK','OK');
    exit
end
sp=libstruct('EstablishLinkParams');
sp.sbigUseOnly=0;
sr=libstruct('EstablishLinkResults');
sr.cameraType=0;
h=calllib('SBIGUDrv','SBIGUnivDrvCommand',9,sp,sr);
if h~=0
    fprintf(mag_log,['SBIG connection not established' sprintf('\n')]);
    questdlg('Unable to establish link to SBIG camera. Guide82 will Quit.','Question','OK','OK');
    exit
end
mag_bin=1;
t=libstruct('StartExposureParams2');
t.ccd=0;
t.exposureTime=100;
t.openShutter=1;
t.abgState=0;
t.readoutMode=0;
t.top=0;
t.left=0;
t.height=mag_ccd_size(1);
t.width=mag_ccd_size(2);
% Make exposure
% calllib('SBIGUDrv','SBIGUnivDrvCommand',50,t,vp)
qp=libstruct('QueryCommandStatusParams');
qp.command=50;
qqr.status=0; % Setup example by creating Matlab struct first
qr=libstruct('QueryCommandStatusResults',qqr); % Initialize here.
%calllib('SBIGUDrv','SBIGUnivDrvCommand',12,qp,qr);
u=libstruct('EndExposureParams');
u.ccd=0;
% calllib('SBIGUDrv','SBIGUnivDrvCommand',2,u,vp)
srp=libstruct('StartReadoutParams');
srp.ccd=0;
srp.readoutMode=0;
srp.top=0;
srp.left=0;
srp.width=mag_ccd_size(2);
srp.height=mag_ccd_size(1);
% calllib('SBIGUDrv','SBIGUnivDrvCommand',35,srp,vp);
rlp=libstruct('ReadoutLineParams');
rlp.ccd=0;
rlp.readoutMode=0;
rlp.pixelStart=0;
rlp.pixelLength=mag_ccd_size(2);
rlr=libpointer('uint16Ptr',uint16(1:mag_ccd_size(2)));
% for row=1:mag_ccd_size(1),
% calllib('SBIGUDrv','SBIGUnivDrvCommand',3,rlp,rlr)
% sbig(row,:)=rlr.value;
% end
er=libstruct('EndReadoutParams');
er.ccd=0;
%calllib('SBIGUDrv','SBIGUnivDrvCommand',25,er,vp);
strp=libstruct('SetTemperatureRegulationParams2');
strp.regulation=0; % Off
strp.ccdSetpoint=0; % 0 degrees C
%calllib('SBIGUDrv','SBIGUnivDrvCommand',51,strp,vp);
stp=libstruct('QueryTemperatureStatusParams');
stp.request=2; % Advanced2
sts=libstruct('QueryTemperatureStatusResults2');
sts.coolingEnabled=0;
sts.fanEnabled=0;
sts.ccdSetpoint=0;
sts.imagingCCDTemperature=0;
sts.trackingCCDTemperature=0;
sts.externalTrackingCCDTemperature=0;
sts.ambientTemperature=0;
sts.imagingCCDPower=0;
sts.trackingCCDPower=0;
sts.externalTrackingCCDPower=0;
sts.heatsinkTemperature=0;
sts.fanPower=0;
sts.fanSpeed=0;
sts.trackingCCDSetpoint=0;
%calllib('SBIGUDrv','SBIGUnivDrvCommand',6,stp,sts);