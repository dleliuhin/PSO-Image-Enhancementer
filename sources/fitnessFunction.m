function fitness = fitnessFunction(enhancedImage, varargin)
%FITNESSFUNCTION Score perceptual detail without a reference image.
%   FITNESS = FITNESSFUNCTION(IMAGE) combines entropy, contrast, edge
%   strength, and edge density, while penalizing clipped pixels.
%
%   The legacy FITNESSFUNCTION(IMAGE, M, N) form remains accepted; image
%   dimensions are now derived directly from IMAGE.

validateattributes(enhancedImage, {'numeric', 'logical'}, ...
    {'2d', 'nonempty', 'real', 'finite'}, mfilename, 'enhancedImage', 1);

enhancedImage = im2double(enhancedImage);
gradientMagnitude = imgradient(enhancedImage, 'sobel');
maximumGradient = max(gradientMagnitude(:));

if maximumGradient > 0
    edgeMask = gradientMagnitude > 0.10 * maximumGradient;
else
    edgeMask = false(size(gradientMagnitude));
end

edgeStrength = mean(gradientMagnitude(:));
edgeDensity = nnz(edgeMask) / numel(edgeMask);
imageEntropy = entropy(enhancedImage);
imageContrast = std(enhancedImage(:));
clippedFraction = nnz(enhancedImage <= 0.001 | enhancedImage >= 0.999) ...
    / numel(enhancedImage);

fitness = log1p(100 * edgeStrength) ...
    * (0.5 + edgeDensity) ...
    * (0.5 + imageEntropy / 8) ...
    * (0.5 + imageContrast) ...
    * max(0.05, 1 - clippedFraction);
end
