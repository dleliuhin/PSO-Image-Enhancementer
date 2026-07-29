function outputFile = buildToolbox(outputDirectory)
%BUILDTOOLBOX Package PSO Image Enhancement as an installable .mltbx file.
%   Requires MATLAB R2023a or newer.

root = fileparts(mfilename('fullpath'));
if nargin < 1
    outputDirectory = fullfile(root, 'dist');
end
if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
end

options = matlab.addons.toolbox.ToolboxOptions(root, ...
    'b2ff0fbd-47a3-4b2d-ad0c-24f647b740c2', ...
    'ToolboxName', 'PSO Image Enhancement', ...
    'ToolboxVersion', '3.1.0', ...
    'AuthorName', 'Dmitrii Leliuhin', ...
    'Summary', 'PSO-based image enhancement and research benchmarks');
outputFile = fullfile(outputDirectory, ...
    'PSO-Image-Enhancement-3.1.0.mltbx');
options.Description = ['Reference-free grayscale and color image ', ...
    'enhancement with weighted and Pareto particle swarm optimization.'];
options.MinimumMatlabRelease = 'R2023a';
options.OutputFile = outputFile;
matlab.addons.toolbox.packageToolbox(options);
end
