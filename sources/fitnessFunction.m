function fitness = fitnessFunction(enhancedImage, varargin)
%FITNESSFUNCTION Score perceptual detail without a reference image.
%   FITNESS = FITNESSFUNCTION(IMAGE) combines entropy, contrast, edge
%   strength, and edge density, while penalizing clipped pixels.
%
%   The legacy FITNESSFUNCTION(IMAGE, M, N) form remains accepted; image
%   dimensions are now derived directly from IMAGE.

validateattributes(enhancedImage, {'numeric', 'logical'}, ...
    {'2d', 'nonempty', 'real', 'finite'}, mfilename, 'enhancedImage', 1);

metrics = psoenhance.computeMetrics(enhancedImage);
objectives = psoenhance.objectiveVector(metrics);
fitness = sum([0.15, 0.15, 0.10, 0.60] .* objectives);
end
