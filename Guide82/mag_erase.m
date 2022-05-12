function [ mag_ready ] = mag_erase( mag_ready )
%MAG_ERASE clears single shot pixels, including pixels that are corner
% connected. Copyright John Kuehne 2011

[row column] = size(mag_ready);

% Zero edges to avoid leaving edge shot, which wouldn't be detected.
mag_ready(1,:) = 0;      % Top edge.
mag_ready(row,:) = 0;    % Bottom edge.
mag_ready(:,1) = 0;      % Left Edge;
mag_ready(:,column) = 0; % Right edge;

mag_k = [ 1  1  1
          1 -1  1
          1  1  1];

mag_ready = mag_ready .* ~(conv2(double(mag_ready>0),mag_k,'same')<1);


end

