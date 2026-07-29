function enhanced = applyTransform(statistics, parameters)
%APPLYTRANSFORM Apply the four-parameter adaptive contrast transform.

validateattributes(parameters, {'numeric'}, ...
    {'vector', 'numel', 4, 'real', 'finite'}, mfilename, 'parameters');
a = parameters(1);
b = parameters(2);
c = parameters(3);
k = parameters(4);
if b <= 0
    error('psoenhance:NonpositiveRegularizer', ...
        'Transform parameter b must be greater than zero.');
end

gain = (k .* statistics.GlobalMean) ./ (statistics.LocalStd + b);
enhanced = gain .* (statistics.Image - c .* statistics.LocalMean) ...
    + statistics.LocalMean .^ a;
enhanced = min(max(enhanced, 0), 1);
end
