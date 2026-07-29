function metrics = computeMetrics(image, reference, includePerceptual)
%COMPUTEMETRICS Compute enhancement, preservation, and IQA measurements.
%   Perceptual no-reference metrics are opt-in because NIQE, BRISQUE, and
%   PIQE are substantially more expensive than the optimization metrics.

if nargin < 2
    reference = [];
end
if nargin < 3
    includePerceptual = false;
end
if ndims(image) == 3
    evaluationImage = rgb2gray(image);
else
    evaluationImage = image;
end
evaluationImage = im2double(evaluationImage);
gradientMagnitude = imgradient(evaluationImage, 'sobel');
maximumGradient = max(gradientMagnitude(:));
if maximumGradient > 0
    edgeDensity = nnz(gradientMagnitude > 0.10 * maximumGradient) ...
        / numel(gradientMagnitude);
else
    edgeDensity = 0;
end

metrics = struct( ...
    'Entropy', entropy(evaluationImage), ...
    'Contrast', std(evaluationImage(:)), ...
    'AverageGradient', mean(gradientMagnitude(:)), ...
    'EdgeDensity', edgeDensity, ...
    'ClippingFraction', nnz(evaluationImage <= 0.001 | ...
        evaluationImage >= 0.999) / numel(evaluationImage), ...
    'MeanBrightness', mean(evaluationImage(:)), ...
    'BrightnessShift', NaN, ...
    'PSNR', NaN, ...
    'SSIM', NaN, ...
    'NIQE', NaN, ...
    'BRISQUE', NaN, ...
    'PIQE', NaN);

if includePerceptual
    metrics.NIQE = optionalMetric('niqe', evaluationImage);
    metrics.BRISQUE = optionalMetric('brisque', evaluationImage);
    metrics.PIQE = optionalMetric('piqe', evaluationImage);
end

if ~isempty(reference)
    if ndims(reference) == 3
        reference = rgb2gray(reference);
    end
    reference = im2double(reference);
    if isequal(size(reference), size(evaluationImage))
        metrics.BrightnessShift = abs(mean(evaluationImage(:)) ...
            - mean(reference(:)));
        if exist('psnr', 'file') == 2
            metrics.PSNR = psnr(evaluationImage, reference);
        end
        if exist('ssim', 'file') == 2
            metrics.SSIM = ssim(evaluationImage, reference);
        end
    end
end
end

function value = optionalMetric(functionName, image)
if exist(functionName, 'file') ~= 2
    value = NaN;
    return;
end
try
    value = feval(functionName, image);
catch
    value = NaN;
end
end
