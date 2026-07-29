function [luminance, context] = prepareImage(inputImage, colorMode)
%PREPAREIMAGE Extract normalized luminance and color reconstruction data.

inputImage = im2double(inputImage);
if ismatrix(inputImage)
    luminance = inputImage;
    context = struct('Mode', 'grayscale', 'Lab', []);
elseif ndims(inputImage) == 3 && size(inputImage, 3) == 3
    if strcmpi(colorMode, 'grayscale')
        luminance = rgb2gray(inputImage);
        context = struct('Mode', 'grayscale', 'Lab', []);
    else
        labImage = rgb2lab(inputImage);
        luminance = labImage(:, :, 1) ./ 100;
        context = struct('Mode', 'lab', 'Lab', labImage);
    end
else
    error('psoenhance:InvalidDimensions', ...
        'Input must be a 2-D grayscale image or an M-by-N-by-3 RGB image.');
end
luminance = min(max(luminance, 0), 1);
end
