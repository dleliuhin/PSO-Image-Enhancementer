function [runs, summary] = benchmark(samples, varargin)
%BENCHMARK Compare PSO with standard contrast-enhancement baselines.
%   [RUNS, SUMMARY] = PSOENHANCE.BENCHMARK(SAMPLES, NAME, VALUE) evaluates
%   Original, imadjust, gamma correction, histogram equalization, CLAHE,
%   weighted PSO, and Pareto PSO. SAMPLES is a struct array with Name,
%   InputPath, and optional
%   ReferencePath fields.
%
%   Options:
%     Seeds          vector of nonnegative integers, default 1:10
%     SwarmSize      positive integer, default 24
%     MaxIterations  positive integer, default 50
%     OptimizationScale scalar in (0, 1], default 0.35
%     OutputDirectory directory for CSV files, default ''
%     DisplayProgress logical scalar, default true

parser = inputParser;
addParameter(parser, 'Seeds', 1:10, @isSeedVector);
addParameter(parser, 'SwarmSize', 24, @isPositiveInteger);
addParameter(parser, 'MaxIterations', 50, @isPositiveInteger);
addParameter(parser, 'OptimizationScale', 0.35, ...
    @(x) isnumeric(x) && isscalar(x) && isfinite(x) && x > 0 && x <= 1);
addParameter(parser, 'OutputDirectory', '', ...
    @(x) ischar(x) || (isstring(x) && isscalar(x)));
addParameter(parser, 'DisplayProgress', true, ...
    @(x) islogical(x) && isscalar(x));
parse(parser, varargin{:});
options = parser.Results;

requiredFields = {'Name', 'InputPath'};
if ~isstruct(samples) || ~all(isfield(samples, requiredFields))
    error('psoenhance:InvalidSamples', ...
        'Samples must be a struct array containing Name and InputPath.');
end

rows = cell(0, 16);
methods = {'Original', 'imadjust', 'Gamma-0.5', 'histeq', 'CLAHE'};
for sampleIndex = 1:numel(samples)
    inputImage = imread(samples(sampleIndex).InputPath);
    reference = getReference(samples(sampleIndex));

    for methodIndex = 1:numel(methods)
        method = methods{methodIndex};
        timer = tic;
        outputImage = applyBaseline(inputImage, method);
        elapsed = toc(timer);
        metrics = psoenhance.computeMetrics(outputImage, reference, true);
        rows(end + 1, :) = metricRow(samples(sampleIndex).Name, method, ...
            NaN, elapsed, metrics); %#ok<AGROW>
    end

    psoMethods = {'PSO-Weighted', 'PSO-Pareto'};
    modes = {'weighted', 'pareto'};
    for methodIndex = 1:numel(psoMethods)
        for seed = options.Seeds
            if options.DisplayProgress
                fprintf('%s | %s | seed %d\n', samples(sampleIndex).Name, ...
                    psoMethods{methodIndex}, seed);
            end
            timer = tic;
            outputImage = psoenhance.enhance(inputImage, ...
                'ObjectiveMode', modes{methodIndex}, ...
                'RandomSeed', seed, ...
                'SwarmSize', options.SwarmSize, ...
                'MaxIterations', options.MaxIterations, ...
                'OptimizationScale', options.OptimizationScale);
            elapsed = toc(timer);
            metrics = psoenhance.computeMetrics(outputImage, reference, true);
            rows(end + 1, :) = metricRow(samples(sampleIndex).Name, ...
                psoMethods{methodIndex}, seed, elapsed, metrics); %#ok<AGROW>
        end
    end
end

runs = cell2table(rows, 'VariableNames', metricNames());
summary = summarizeRuns(runs);

outputDirectory = char(options.OutputDirectory);
if ~isempty(outputDirectory)
    if ~exist(outputDirectory, 'dir')
        mkdir(outputDirectory);
    end
    writetable(runs, fullfile(outputDirectory, 'benchmark-runs.csv'));
    writetable(summary, fullfile(outputDirectory, 'benchmark-summary.csv'));
end
end

function output = applyBaseline(input, method)
if strcmp(method, 'Original')
    output = im2double(input);
    return;
end
[luminance, context] = psoenhance.prepareImage(input, 'luminance');
switch method
    case 'imadjust'
        luminance = imadjust(luminance);
    case 'Gamma-0.5'
        luminance = imadjust(luminance, [], [], 0.5);
    case 'histeq'
        luminance = histeq(luminance);
    case 'CLAHE'
        luminance = adapthisteq(luminance);
end
output = psoenhance.restoreImage(luminance, context);
end

function reference = getReference(sample)
reference = [];
if isfield(sample, 'ReferencePath') && ~isempty(sample.ReferencePath) ...
        && exist(sample.ReferencePath, 'file')
    reference = imread(sample.ReferencePath);
end
end

function row = metricRow(sample, method, seed, elapsed, metrics)
row = {char(sample), method, seed, elapsed, metrics.Entropy, ...
    metrics.Contrast, metrics.AverageGradient, metrics.EdgeDensity, ...
    metrics.ClippingFraction, metrics.MeanBrightness, ...
    metrics.BrightnessShift, metrics.PSNR, metrics.SSIM, metrics.NIQE, ...
    metrics.BRISQUE, metrics.PIQE};
end

function names = metricNames()
names = {'Sample', 'Method', 'Seed', 'RuntimeSeconds', 'Entropy', ...
    'Contrast', 'AverageGradient', 'EdgeDensity', 'ClippingFraction', ...
    'MeanBrightness', 'BrightnessShift', 'PSNR', 'SSIM', 'NIQE', ...
    'BRISQUE', 'PIQE'};
end

function summary = summarizeRuns(runs)
samples = unique(runs.Sample, 'stable');
methods = unique(runs.Method, 'stable');
metricVariables = runs.Properties.VariableNames(4:16);
rows = cell(0, 3 + 2 * numel(metricVariables));
for sampleIndex = 1:numel(samples)
    for methodIndex = 1:numel(methods)
        selection = strcmp(runs.Sample, samples{sampleIndex}) ...
            & strcmp(runs.Method, methods{methodIndex});
        if ~any(selection)
            continue;
        end
        row = {samples{sampleIndex}, methods{methodIndex}, nnz(selection)};
        for metricIndex = 1:numel(metricVariables)
            values = runs.(metricVariables{metricIndex})(selection);
            values = values(isfinite(values));
            if isempty(values)
                average = NaN;
                deviation = NaN;
            else
                average = mean(values);
                deviation = std(values);
            end
            row = [row, {average, deviation}]; %#ok<AGROW>
        end
        rows(end + 1, :) = row; %#ok<AGROW>
    end
end

names = {'Sample', 'Method', 'RunCount'};
for metricIndex = 1:numel(metricVariables)
    names{end + 1} = [metricVariables{metricIndex}, 'Mean']; %#ok<AGROW>
    names{end + 1} = [metricVariables{metricIndex}, 'Std']; %#ok<AGROW>
end
summary = cell2table(rows, 'VariableNames', names);
end

function valid = isSeedVector(value)
valid = isnumeric(value) && isvector(value) && ~isempty(value) ...
    && all(isfinite(value)) && all(value >= 0) ...
    && all(value == floor(value));
end

function valid = isPositiveInteger(value)
valid = isnumeric(value) && isscalar(value) && isfinite(value) ...
    && value > 0 && value == floor(value);
end
