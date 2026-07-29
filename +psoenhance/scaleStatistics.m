function scaled = scaleStatistics(statistics, scale)
%SCALESTATISTICS Resize cached maps while preserving their physical window.

validateattributes(scale, {'numeric'}, ...
    {'scalar', 'real', 'finite', '>', 0, '<=', 1}, mfilename, 'scale');
if scale == 1
    scaled = statistics;
    return;
end

scaled = statistics;
scaled.Image = imresize(statistics.Image, scale, 'bilinear');
scaled.LocalMean = imresize(statistics.LocalMean, scale, 'bilinear');
scaled.LocalStd = imresize(statistics.LocalStd, scale, 'bilinear');
end
