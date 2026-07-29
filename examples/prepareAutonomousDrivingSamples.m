function prepareAutonomousDrivingSamples(datasetDirectory)
%PREPAREAUTONOMOUSDRIVINGSAMPLES Recreate the committed benchmark inputs.
%   DATASETDIRECTORY must contain extracted CAM_FRONT batch 22 frames from
%   the CC BY 4.0 CARLA-nuScenes dataset.

root = fileparts(fileparts(mfilename('fullpath')));
outputDirectory = fullfile(root, 'examples', 'autonomous-driving');
if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
end

nightName = ...
    'model3-03-23-2023__CAM_FRONT__1679585222925399.jpg';
referenceName = ...
    'model3-03-22-2023__CAM_FRONT__1679496725327888.jpg';

night = resizeToFit(imread(fullfile(datasetDirectory, nightName)), [540, 960]);
imwrite(night, fullfile(outputDirectory, 'urban-dusk-input.jpg'), ...
    'Quality', 92);

reference = resizeToFit( ...
    imread(fullfile(datasetDirectory, referenceName)), [540, 960]);
imwrite(reference, ...
    fullfile(outputDirectory, 'uneven-light-reference.jpg'), 'Quality', 92);

image = im2double(reference);
[height, width, ~] = size(image);
x = linspace(0, 1, width);
y = linspace(0, 1, height)';
illumination = 0.22 + 0.42 .* x;
vignette = min(max(1 - 0.65 .* ((x - 0.5) .^ 2 + ...
    (y - 0.5) .^ 2), 0.45), 1);
mask = illumination .* vignette;
degraded = image .^ 1.75 .* repmat(mask, [1, 1, 3]);
imwrite(degraded, ...
    fullfile(outputDirectory, 'uneven-light-input.jpg'), 'Quality', 92);
end

function output = resizeToFit(image, maximumSize)
scale = min([1, maximumSize(1) / size(image, 1), ...
    maximumSize(2) / size(image, 2)]);
output = imresize(image, scale, 'lanczos3');
end
