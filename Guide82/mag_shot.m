function [mag_noise_final, mag_count] = mag_shot(mag_image, ...
    mag_noise_initial, mag_conv)
%
% Detect shot pixels that occur above mag_noise_initial, i.e. single,
% double, or triple pixels. Singles are detected in a sea of zeros, but
% double and triples can be connected corner or edgwise to other pixels.
% Single-shot noise mag_conv is -1, double is -2, triple is -3.
% Returns the peak value, and the number of shots detected.
%
% Copyright John Kuehne, 2010

[row, column] = size(mag_image);

% Convolution kernel for detecting single, double, and triple shot pixels.
k = [ 1  1  1
    1 mag_conv  1
    1  1  1];

% Truth table of 1s and 0s.
mag_truth = double(mag_image > mag_noise_initial);

mag_salt = conv2(mag_truth, k, 'same'); % -1 for singletons.

mag_image_vec = reshape(mag_image, row*column, 1);
mag_salt_vec = reshape(mag_salt, row*column, 1);

mag_locations = find(mag_salt_vec < 0);

mag_count = length(mag_locations);

if (mag_count > 0)
    mag_noise_final = max(mag_image_vec(mag_locations));
else
    mag_noise_final = mag_noise_initial;
end

end
