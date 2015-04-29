function [rse_out] = root_square_error(x, y)
%root_square_error Calculate the root_square_error between 2 arrays
%   x and y are arrays with equal shape
%   returns rse_out, a vector with length equal to the size of the 
%   first dimension of x and y

    rse_out = sqrt(sum((x - y).^2, 2));

end

