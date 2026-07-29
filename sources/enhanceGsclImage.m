function enhancedImage = enhanceGsclImage(grayImage, localSize, a, b, c, k)
%ENHANCEGSCLIMAGE Apply a locally adaptive grayscale transformation.
%   ENHANCED = ENHANCEGSCLIMAGE(IMAGE, WINDOW, A, B, C, K) stretches local
%   contrast around the local mean. Output is a double image in [0, 1].

validateattributes(grayImage, {'numeric', 'logical'}, ...
    {'2d', 'nonempty', 'real', 'nonsparse'}, mfilename, 'grayImage', 1);
validateattributes(localSize, {'numeric'}, ...
    {'scalar', 'integer', 'odd', '>=', 3}, mfilename, 'localSize', 2);
validateattributes([a, b, c, k], {'numeric'}, ...
    {'vector', 'numel', 4, 'real', 'finite'}, mfilename, 'parameters');

if b <= 0
    error('enhanceGsclImage:NonpositiveRegularizer', ...
        'Parameter b must be greater than zero.');
end

statistics = psoenhance.precomputeStatistics(im2double(grayImage), localSize);
enhancedImage = psoenhance.applyTransform(statistics, [a, b, c, k]);
end
