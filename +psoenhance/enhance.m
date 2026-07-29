function [enhancedImage, result] = enhance(inputImage, varargin)
%ENHANCE Enhance grayscale or RGB images with PSO.
%   [ENHANCED, RESULT] = PSOENHANCE.ENHANCE(IMAGE, NAME, VALUE) optimizes a
%   four-parameter adaptive local contrast transform.
%
%   Options:
%     SwarmSize         positive integer, default 24
%     MaxIterations     positive integer, default 50
%     LocalWindowSize   odd integer >= 3, default 3
%     RandomSeed        nonnegative integer, default 42
%     StallIterations   positive integer, default 12
%     ColorMode         'luminance' or 'grayscale', default 'luminance'
%     ObjectiveMode     'weighted' or 'pareto', default 'weighted'
%     ObjectiveWeights  four nonnegative values, default [0.35 0.25 0.20 0.20]
%     ArchiveSize       positive integer, default 40
%     OptimizationScale scalar in (0, 1], default 0.5
%     DisplayProgress   logical scalar, default false

validateattributes(inputImage, {'numeric', 'logical'}, ...
    {'nonempty', 'real', 'nonsparse'}, mfilename, 'inputImage', 1);
options = parseOptions(varargin{:});

[luminance, colorContext] = psoenhance.prepareImage(inputImage, ...
    options.ColorMode);
if options.OptimizationScale < 1
    optimizationLuminance = imresize(luminance, options.OptimizationScale, ...
        'bilinear');
else
    optimizationLuminance = luminance;
end
statistics = psoenhance.precomputeStatistics(optimizationLuminance, ...
    options.LocalWindowSize);
stream = RandStream('mt19937ar', 'Seed', options.RandomSeed);

lowerBounds = [0.50, 0.01, 0.00, 0.50];
upperBounds = [2.00, 0.50, 1.00, 2.00];
parameterRange = upperBounds - lowerBounds;
dimensions = numel(lowerBounds);

positions = bsxfun(@plus, lowerBounds, bsxfun(@times, ...
    rand(stream, options.SwarmSize, dimensions), parameterRange));
velocities = bsxfun(@times, ...
    0.20 .* (2 .* rand(stream, options.SwarmSize, dimensions) - 1), ...
    parameterRange);
maximumVelocity = 0.20 .* parameterRange;

personalBestPositions = positions;
personalBestScores = -inf(options.SwarmSize, 1);
personalBestObjectives = -inf(options.SwarmSize, 4);
archive = emptyArchive();
bestPosition = positions(1, :);
bestScore = -inf;
bestObjectives = -inf(1, 4);
fitnessHistory = nan(options.MaxIterations, 1);
stallCount = 0;

for iteration = 1:options.MaxIterations
    previousBest = bestScore;

    for particle = 1:options.SwarmSize
        candidate = psoenhance.applyTransform(statistics, ...
            positions(particle, :));
        metrics = psoenhance.computeMetrics(candidate, luminance);
        objectives = psoenhance.objectiveVector(metrics);
        score = sum(options.ObjectiveWeights .* objectives);

        if strcmp(options.ObjectiveMode, 'weighted')
            replacePersonal = score > personalBestScores(particle);
        else
            replacePersonal = psoenhance.dominates(objectives, ...
                personalBestObjectives(particle, :));
            if ~replacePersonal && ~psoenhance.dominates( ...
                    personalBestObjectives(particle, :), objectives)
                replacePersonal = rand(stream) < 0.5;
            end
        end

        if replacePersonal
            personalBestPositions(particle, :) = positions(particle, :);
            personalBestScores(particle) = score;
            personalBestObjectives(particle, :) = objectives;
        end

        archive = psoenhance.updateArchive(archive, ...
            positions(particle, :), objectives, score, options.ArchiveSize);

        if score > bestScore
            bestScore = score;
            bestPosition = positions(particle, :);
            bestObjectives = objectives;
        end
    end

    if strcmp(options.ObjectiveMode, 'pareto')
        leaderPosition = selectLeader(archive, stream);
    else
        leaderPosition = bestPosition;
    end

    inertia = 0.90 - 0.50 * (iteration - 1) / ...
        max(options.MaxIterations - 1, 1);
    cognitiveRandom = rand(stream, options.SwarmSize, dimensions);
    socialRandom = rand(stream, options.SwarmSize, dimensions);
    velocities = inertia .* velocities ...
        + 2.05 .* cognitiveRandom .* (personalBestPositions - positions) ...
        + 2.05 .* socialRandom .* ...
          bsxfun(@minus, leaderPosition, positions);
    velocities = bsxfun(@min, bsxfun(@max, velocities, -maximumVelocity), ...
        maximumVelocity);
    positions = positions + velocities;
    positions = bsxfun(@min, bsxfun(@max, positions, lowerBounds), ...
        upperBounds);

    fitnessHistory(iteration) = bestScore;
    if isfinite(previousBest) && bestScore <= previousBest + ...
            eps(max(1, abs(previousBest))) * 10
        stallCount = stallCount + 1;
    else
        stallCount = 0;
    end

    if options.DisplayProgress
        fprintf('Iteration %3d/%3d | compromise score %.6f | archive %d\n', ...
            iteration, options.MaxIterations, bestScore, ...
            size(archive.Positions, 1));
    end
    if stallCount >= options.StallIterations
        break;
    end
end

if strcmp(options.ObjectiveMode, 'pareto') && ~isempty(archive.Scores)
    [bestPosition, bestObjectives, bestScore] = ...
        selectCompromise(archive, options.ObjectiveWeights);
end

outputStatistics = psoenhance.precomputeStatistics(luminance, ...
    options.LocalWindowSize);
enhancedLuminance = psoenhance.applyTransform(outputStatistics, bestPosition);
enhancedImage = psoenhance.restoreImage(enhancedLuminance, colorContext);

result = struct( ...
    'BestParameters', bestPosition, ...
    'BestFitness', bestScore, ...
    'BestObjectives', bestObjectives, ...
    'FitnessHistory', fitnessHistory(1:iteration), ...
    'Iterations', iteration, ...
    'RandomSeed', options.RandomSeed, ...
    'Options', options, ...
    'ParetoFront', archive, ...
    'CachedStatistics', true);
end

function options = parseOptions(varargin)
parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser, 'SwarmSize', 24, @isPositiveInteger);
addParameter(parser, 'MaxIterations', 50, @isPositiveInteger);
addParameter(parser, 'LocalWindowSize', 3, @isOddWindow);
addParameter(parser, 'RandomSeed', 42, @isNonnegativeInteger);
addParameter(parser, 'StallIterations', 12, @isPositiveInteger);
addParameter(parser, 'ColorMode', 'luminance', ...
    @(x) isTextChoice(x, {'luminance', 'grayscale'}));
addParameter(parser, 'ObjectiveMode', 'weighted', ...
    @(x) isTextChoice(x, {'weighted', 'pareto'}));
addParameter(parser, 'ObjectiveWeights', [0.35, 0.25, 0.20, 0.20], ...
    @isValidWeights);
addParameter(parser, 'ArchiveSize', 40, @isPositiveInteger);
addParameter(parser, 'OptimizationScale', 0.5, ...
    @(x) isnumeric(x) && isscalar(x) && isfinite(x) && x > 0 && x <= 1);
addParameter(parser, 'DisplayProgress', false, ...
    @(x) islogical(x) && isscalar(x));
parse(parser, varargin{:});
options = parser.Results;
options.ColorMode = lower(char(options.ColorMode));
options.ObjectiveMode = lower(char(options.ObjectiveMode));
options.ObjectiveWeights = options.ObjectiveWeights(:)' ...
    ./ sum(options.ObjectiveWeights);
end

function archive = emptyArchive()
archive = struct('Positions', zeros(0, 4), 'Objectives', zeros(0, 4), ...
    'Scores', zeros(0, 1), 'CrowdingDistance', zeros(0, 1));
end

function leader = selectLeader(archive, stream)
if size(archive.Positions, 1) == 1
    leader = archive.Positions(1, :);
    return;
end
first = randi(stream, size(archive.Positions, 1));
second = randi(stream, size(archive.Positions, 1));
if archive.CrowdingDistance(first) >= archive.CrowdingDistance(second)
    leader = archive.Positions(first, :);
else
    leader = archive.Positions(second, :);
end
end

function [position, objectives, score] = selectCompromise(archive, weights)
values = archive.Objectives;
ranges = max(values, [], 1) - min(values, [], 1);
ranges(ranges == 0) = 1;
normalized = bsxfun(@rdivide, bsxfun(@minus, values, min(values, [], 1)), ...
    ranges);
compromiseScores = normalized * weights(:);
[~, index] = max(compromiseScores);
position = archive.Positions(index, :);
objectives = archive.Objectives(index, :);
score = archive.Scores(index);
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

function valid = isTextChoice(value, choices)
valid = (ischar(value) || (isstring(value) && isscalar(value))) ...
    && any(strcmpi(char(value), choices));
end

function valid = isValidWeights(value)
valid = isnumeric(value) && isvector(value) && numel(value) == 4 ...
    && all(isfinite(value)) && all(value >= 0) && sum(value) > 0;
end
