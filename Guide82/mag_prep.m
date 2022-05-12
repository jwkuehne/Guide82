function [mag_ready,mag_end] = mag_prep(mag_image,mag_patch,mag_aggression)
%
% Prepare mag_image, the guider subset image, for least-squares analysis by
% removing the noise floor. Returns the prepared image and the attained
% noise floor.
%
% Copyright John Kuehne, 2011

% Convert zeros to 2^32 - prevents any patch with zeros from being used.
mag_nz = mag_image + (mag_image==0)*(2^32);

% Select the brightest pixel in the darkest patch. mag_patch should be
% large enough to represent the noise statistics for a mag_window_size
% that is large enough to provide a good patch of sky. 10 seems to work
% well for the Sandiford and 6 pixels/arcsecond and 35 mag_window_size.
%
% Use mag_nz instead of mag_image to avoid selecting patches with zero
% pixels and integrate every patch inside the guider image.
mag_dark = conv2(mag_nz,ones([mag_patch mag_patch]),'valid');

% Get the indexes of the darkest patches.
[mag_dy, mag_dx] = find(mag_dark == min(min(mag_dark)));

% Select the brightest pixel - use just the first patch if there
% are several with the same darkness.
mag_start = max(max(mag_image(mag_dy(1):mag_dy(1)+(mag_patch-1), ...
    mag_dx(1):mag_dx(1)+(mag_patch-1))));

mag_peak_list(1) = mag_start; % Record the first value.
mag_peak = mag_start; % First level.
mag_count= 1; % Enter the loop at least once.
mag_iter = 1; % Iteration count to prevent runaway in while loop.
while (mag_count > 0) && (mag_iter < 50) % Clean up any remaining single shot noise. At
    % each iteration, start from the peak single shot until there's no more shot.
    [mag_peak, mag_count] = mag_shot(mag_image,mag_peak,-mag_aggression);
    mag_iter = mag_iter + 1;
    mag_peak_list(mag_iter) = mag_peak; % Keep track of peak shots.
end

if (mag_iter > 2) % Note last value is duplicated in list, hence 2.
    % Hot pixel rejection: mask out pixels at peak level and recalculate.
    mag_image = mag_image .* ~(mag_image == mag_peak);
    mag_peak = mag_peak_list(mag_iter-2); % Start from penultimate level.
    mag_count= 1; % Enter the loop at least once.
    mag_iter = 1;
    while (mag_count > 0) && (mag_iter < 50) % Clean up any remaining single shot noise. At
        % each iteration, start from the peak single shot until there's no more shot.
        [mag_peak, mag_count] = mag_shot(mag_image,mag_peak,-mag_aggression);
        mag_iter = mag_iter + 1;
    end
end

mag_end = mag_peak;

% Subtract the noise floor from the data and zero-out pixels below the floor.
mag_ready =(mag_image - mag_end) .* double(mag_image>mag_end);


end