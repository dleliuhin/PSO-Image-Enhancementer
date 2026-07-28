function [enhancedImage, result] = psoEnhanceImage(inputImage, varargin)
%PSOENHANCEIMAGE Enhance an image using particle swarm optimization.
%   ENHANCED = PSOENHANCEIMAGE(IMAGE) finds four parameters controlling an
%   adaptive local contrast transform.
%
%   [ENHANCED, RESULT] = PSOENHANCEIMAGE(..., NAME, VALUE) also returns
%   optimization diagnostics. Supported options are:
%     'SwarmSize'       positive integer (default 24)
%     'MaxIterations'   positive integer (default 50)
%     'LocalWindowSize' odd integer >= 3 (default 3)
%     'RandomSeed'      nonnegative integer (default 42)
%     'StallIterations' positive integer (default 12)
%     'DisplayProgress' logical value (default false)
%
%   RESULT contains BestParameters, BestFitness, FitnessHistory,
%   Iterations, RandomSeed, and Options.

validateattributes(inputImage, {'numeric', 'logical'}, ...
    {'nonempty', 'real', 'nonsparse'}, mfilename, 'inputImage', 1);

sourceDirectory = fullfile(fileparts(mfilename('fullpath')), 'sources');
if exist(sourceDirectory, 'dir')
    addpath(sourceDirectory);
end

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser, 'SwarmSize', 24, @isPositiveInteger);
addParameter(parser, 'MaxIterations', 50, @isPositiveInteger);
addParameter(parser, 'LocalWindowSize', 3, @isOddWindow);
addParameter(parser, 'RandomSeed', 42, @isNonnegativeInteger);
addParameter(parser, 'StallIterations', 12, @isPositiveInteger);
addParameter(parser, 'DisplayProgress', false, ...
    @(value) islogical(value) && isscalar(value));
parse(parser, varargin{:});
options = parser.Results;

if ndims(inputImage) == 3
    grayImage = rgb2gray(inputImage);
elseif ismatrix(inputImage)
    grayImage = inputImage;
else
    error('psoEnhanceImage:InvalidDimensions', ...
        'Input must be a 2-D grayscale image or a 3-D RGB image.');
end

rng(options.RandomSeed, 'twister');

% Each row is [a, b, c, k]. These bounds avoid singular transforms while
% retaining the useful search region from the original implementation.
lowerBounds = [0.50, 0.01, 0.00, 0.50];
upperBounds = [2.00, 0.50, 1.00, 2.00];
parameterRange = upperBounds - lowerBounds;
dimensions = numel(lowerBounds);

positions = bsxfun(@plus, lowerBounds, ...
    bsxfun(@times, rand(options.SwarmSize, dimensions), parameterRange));
velocities = bsxfun(@times, ...
    0.20 .* (2 .* rand(options.SwarmSize, dimensions) - 1), parameterRange);
maxVelocity = 0.20 .* parameterRange;

personalBestPositions = positions;
personalBestFitness = -inf(options.SwarmSize, 1);
globalBestPosition = positions(1, :);
globalBestFitness = -inf;
fitnessHistory = nan(options.MaxIterations, 1);
stallCount = 0;

for iteration = 1:options.MaxIterations
    previousBest = globalBestFitness;
    for particle = 1:options.SwarmSize
        candidate = enhanceGsclImage(grayImage, options.LocalWindowSize, ...
            positions(particle, 1), positions(particle, 2), ...
            positions(particle, 3), positions(particle, 4));
        candidateFitness = fitnessFunction(candidate);

        if candidateFitness > personalBestFitness(particle)
            personalBestFitness(particle) = candidateFitness;
            personalBestPositions(particle, :) = positions(particle, :);
        end

        if candidateFitness > globalBestFitness
            globalBestFitness = candidateFitness;
            globalBestPosition = positions(particle, :);
            stallCount = 0;
        end
    end

    fitnessHistory(iteration) = globalBestFitness;

    % Linearly decreasing inertia balances exploration and convergence.
    inertia = 0.90 - (0.90 - 0.40) * (iteration - 1) / ...
        max(options.MaxIterations - 1, 1);
    cognitiveRandom = rand(options.SwarmSize, dimensions);
    socialRandom = rand(options.SwarmSize, dimensions);
    velocities = inertia .* velocities ...
        + 2.05 .* cognitiveRandom .* (personalBestPositions - positions) ...
        + 2.05 .* socialRandom .* ...
          (bsxfun(@minus, globalBestPosition, positions));
    velocities = bsxfun(@min, bsxfun(@max, velocities, -maxVelocity), ...
        maxVelocity);
    positions = positions + velocities;
    positions = bsxfun(@min, bsxfun(@max, positions, lowerBounds), ...
        upperBounds);

    if isfinite(previousBest) && globalBestFitness <= previousBest + ...
            eps(max(1, abs(previousBest))) * 10
        stallCount = stallCount + 1;
    else
        stallCount = 0;
    end

    if options.DisplayProgress
        fprintf('Iteration %3d/%3d | best fitness %.6f\n', ...
            iteration, options.MaxIterations, globalBestFitness);
    end

    if stallCount >= options.StallIterations
        break;
    end
end

enhancedImage = enhanceGsclImage(grayImage, options.LocalWindowSize, ...
    globalBestPosition(1), globalBestPosition(2), ...
    globalBestPosition(3), globalBestPosition(4));

result = struct( ...
    'BestParameters', globalBestPosition, ...
    'BestFitness', globalBestFitness, ...
    'FitnessHistory', fitnessHistory(1:iteration), ...
    'Iterations', iteration, ...
    'RandomSeed', options.RandomSeed, ...
    'Options', options);
end

function valid = isPositiveInteger(value)
valid = isnumeric(value) && isscalar(value) && isfinite(value) ...
    && value > 0 && value == floor(value);
end

function valid = isNonnegativeInteger(value)
valid = isnumeric(value) && isscalar(value) && isfinite(value) ...
    && value >= 0 && value == floor(value);
end

function valid = isOddWindow(value)
valid = isPositiveInteger(value) && value >= 3 && mod(value, 2) == 1;
end
