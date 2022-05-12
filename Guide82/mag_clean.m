function [mag_ready] = mag_clean(mag_ready)
%
% Final cleanup of double, triple, and quadruple shot noise remaining after
% mag_prep finds the single shot noise floor. This can help suppress cosmic
% ray and radioactive decay illuminated pixels, and faint stars in the
% field that are just above the noise floor.
%
%
% Copyright John Kuehne, 2010.

% Kernel catches all single, double, triple, and quadruple shot in a 2x2
% box surounded by zeros.
mag_k = [ 4  4  4  4
          4 -1 -1  4
          4 -1 -1  4
          4  4  4  4]; % Zero the whole 2x2 block for all detections.

[row column] = size(mag_ready);

% Zero edges to avoid leaving edge shot, which wouldn't be detected.
mag_ready(1,:) = 0;      % Top edge.
mag_ready(row,:) = 0;    % Bottom edge.
mag_ready(:,1) = 0;      % Left Edge;
mag_ready(:,column) = 0; % Right edge;

mag_truth = double(mag_ready > 0); % 0-1 map.

% Valid convolution has no zero padding.
mag_salt = conv2(mag_truth, mag_k, 'valid');

[mag_row, mag_col] = find((mag_salt < 0)); % Detects shot in sea of zeros.

% Laboriously clear out each 2x2 region that contains shot. Fortunately,
% remaining shot is uncommon.
for a=1:length(mag_row),
    mag_ready(mag_row(a)+1:mag_row(a)+2,mag_col(a)+1:mag_col(a)+2) = 0;
end
