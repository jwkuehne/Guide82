function [mag_ycen, mag_xcen, mag_fwhm] = mag_cen_s(mag_image)
%
% Semi-constrained least-squares solution for estimating fwhm and centroid
% of a Gaussian psf, possibly cut by an obstruction, e.g. slit.
%
% The method transforms a Gaussian into a paraboloid, which can then be
% fit by linear least squares, semi-contstrained to find the fwhm for a
% circular profile. mag_image must be prepared with mag_prep to remove
% the noise floor, leaving a clean image in a sea of zeros. Slit and bad
% pixels are also zero-masked.
%
% Copyright John Kuehne, 2010

[mag_row, mag_col] = size(mag_image); % row is y, col is x.

% Get ready for inv(A(T)*A)*A(T)*b; put data into vector, and save mask.
mag_im_data = reshape(mag_image,mag_row*mag_col, 1);
mag_mask = double(mag_im_data > 0);

% Transform to paraboloid, keeping zero-masked values real, and re-masking.
mag_ls_data = log(mag_im_data+eps) .* mag_mask;

% Matrices of x and y coordinates.
mag_x_mat = ones([mag_row 1])*(1:mag_col) - (mag_col + 1)/2;
mag_x_vec = reshape(mag_x_mat, mag_row*mag_col, 1);
mag_y_mat = (1:mag_row)'*ones([1 mag_col]) - (mag_row + 1)/2;
mag_y_vec = reshape(mag_y_mat, mag_row*mag_col, 1);

% Form the semi-constrained least squares matrix.
mag_ls_matrix(:,1) = -((mag_x_vec.^2) + (mag_y_vec.^2)) .* mag_mask;
mag_ls_matrix(:,2) = 2*mag_x_vec .* mag_mask;
mag_ls_matrix(:,3) = 2*mag_y_vec .* mag_mask;
mag_ls_matrix(:,4) = ones([mag_row*mag_col 1]) .* mag_mask;

mag_ls_vector = mag_ls_data;

mag_ls_solution = mag_ls_matrix \ mag_ls_vector;

if (mag_ls_solution(1)>eps) % a solution exists.
    % mag_ls_solution(1) = 1/(2s^2).
   mag_fwhm = 2*sqrt(2*log(2))/sqrt(2*mag_ls_solution(1));
   mag_xcen = mag_ls_solution(2)/mag_ls_solution(1);
   mag_ycen = mag_ls_solution(3)/mag_ls_solution(1);
else % Singular -- just give up.
   mag_ycen=NaN; mag_xcen=NaN; mag_fwhm=NaN;
   return;
end

end
