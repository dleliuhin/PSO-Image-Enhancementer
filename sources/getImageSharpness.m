function sharpness = getImageSharpness(image)
%GETIMAGESHARPNESS Return mean gradient magnitude.
%   SHARPNESS = GETIMAGESHARPNESS(IMAGE) accepts grayscale or RGB images.

validateattributes(image, {'numeric', 'logical'}, ...
    {'nonempty', 'real', 'nonsparse'}, mfilename, 'image', 1);

if ndims(image) == 3
    image = rgb2gray(image);
elseif ~ismatrix(image)
    error('getImageSharpness:InvalidDimensions', ...
        'Input must be a 2-D grayscale image or a 3-D RGB image.');
end

[gradientX, gradientY] = gradient(im2double(image));
sharpness = mean(hypot(gradientX(:), gradientY(:)));
end
