% Setup workspace parameters.
%
% Copyright John Kuehne, 2010, 2012, 2014

% Must set all mag_ defaults

userpath('reset'); % Creates Documents/Matlab folder in Windows, saves path.
eval(['cd ' userpath]); % and goes there

% mag_orientation = 1;  % SES is default
% mag_slit_scale = 5.7; % changes with zoom adjustment
% mag_field_scale = 5.7;  % field is same as slit
% mag_camera = 1; % Apogee Alta 512x512
% mag_ccd_size = [512,512];

%mag_orientation = 1;  % CQUEAN - parameters unknown
%mag_slit_scale = 5.7; % changes with zoom adjustment
%mag_field_scale=5.7;  % field is same as slit
%mag_camera = 3; % QSI
%mag_ccd_size=[3326, 2504];

%mag_orientation = 9;   % ES2
%mag_slit_scale = 6.5; % ES2 changes with camera adjustment
%mag_field_scale = mag_slit_scale/4.65; % Average of H and V scale in ES2
%mag_camera = 1; % Apogee Alta 512x512
%mag_ccd_size=[512,512];

%mag_orientation = 4; %WHT
%mag_slit_scale = 15.361; % Cassegrain plate scale is 7.23 arcsec/mm
%mag_field_scale = 15.361;% and camera is 9 micron pixels.
%mag_camera = 2; % SBIG ST-1603ME 1020x1530
%mag_ccd_size = [1020 1530];

%mag_orientation = 10; % ProEM File camera is 1024x1024 13 micron pixels
%mag_camera = 4; % File camera
%mag_slit_scale=10.6394;
%mag_field_scale=10.6394;
%mag_ccd_size = [1024,1024];

mag_orientation = 10; % ETSI Marana-4BV11 needs no orientation.
mag_camera = 4; % File camera
mag_slit_scale=1/0.18;
mag_field_scale=1/0.18;
mag_ccd_size = [2052, 2048];

%mag_orientation = 4; % Unknown
%mag_slit_scale = 2.584; % 43 arcsec/mm
%mag_field_scale = 2.584; % 9 micron pixels
%mag_camera = 5; % MicroLine ML11002
%mag_ccd_size=[2672,4008];

try
    load('mag_orientation');
end

try
    load('mag_camera');
end

try
    load('mag_ccd_size');
end

try
    load('mag_slit_scale');
end

try
    load('mag_field_scale');
end

try
    load('mag_colormap');
end

mag_tcs = 'http://192.168.30.14:22401'; % Track28 MacMini in dome
try
    load('mag_tcs');
end

mag_patch=5; % brightest pixel in darkest patch for initial sky level.
try
    load('mag_patch');
end

mag_aggression=1; % single, double, or triple shot reduction
try
    load('mag_aggression');
end

mag_mf_max = 5; % Maximum trusted FWHM in arcseconds (unused)
try
    load('mag_mf_max');
end

mag_slit_cen = [285 225]; % Changes when Alta is mounted. In pixels.
try
    load('mag_slit_cen');
end

mag_slit_size = [1.1 2.2];  % This changes with ES2, SES. In arcseconds y,x.
try
    load('mag_slit_size');
end

% next 3 depend on the instrument, but these work well for SES in 2012.
mag_field_cen = [293 250]; % Location of star marker in field mode, in pixels.
try
    load('mag_field_cen');
end

mag_window_size = 35; % Half of box size about slit center, in pixels.
try
    load('mag_window_size');
end

mag_aspect = 0.5; % Test value for ETSI. Normally set to 1 and adjusted in the parameter directory
try
    load('mag_aspect');
end

mag_window_cen = mag_slit_cen; % Start with window and slit centered, pixels.
try
    load('mag_window_cen');
end

mag_target_cen = mag_slit_cen - mag_window_cen;

mag_px = 0.5;  % RA proportional gain.
try
    load('mag_px');
end

mag_py = 0.5;  % DEC proportional gain.
try
    load('mag_py');
end

% deadband - no guide when magnitude is less than this limit,
% arcseconds.
mag_hx = 0;
try
    load('mag_hx');
end

mag_hy = 0;
try
    load('mag_hy');
end

mag_max_x = 5;  % maximum safe move in x (RA)
try
    load('mag_max_x');
end

mag_max_y = 5;  % maximum safe move in y (DEC)
try
    load('mag_max_y');
end