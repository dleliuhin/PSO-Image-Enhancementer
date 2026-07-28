function [enhancedImage, result] = mainPso(imagePath)
%MAINPSO Run the PSO image-enhancement demonstration.
%   MAINPSO() enhances the bundled Lena image and displays the result.
%
%   [ENHANCED, RESULT] = MAINPSO(IMAGEPATH) enhances a custom image and
%   returns both the enhanced grayscale image and optimization diagnostics.
%
%   This function is intentionally small: use PSOENHANCEIMAGE directly for
%   programmatic use and additional options.

if nargin < 1
    repositoryRoot = fileparts(mfilename('fullpath'));
    imagePath = fullfile(repositoryRoot, 'images', 'lena.jpg');
else
    repositoryRoot = fileparts(mfilename('fullpath'));
end
addpath(fullfile(repositoryRoot, 'sources'));

inputImage = imread(imagePath);
[enhancedImage, result] = psoEnhanceImage(inputImage, ...
    'SwarmSize', 24, ...
    'MaxIterations', 50, ...
    'RandomSeed', 42, ...
    'DisplayProgress', true);

grayImage = toGrayscale(inputImage);

figure('Name', 'PSO Image Enhancement 3.0');
subplot(1, 3, 1);
imshow(inputImage);
title('Original');

subplot(1, 3, 2);
imshow(grayImage);
title('Grayscale');

subplot(1, 3, 3);
imshow(enhancedImage);
title(sprintf('Enhanced (fitness %.4f)', result.BestFitness));

fprintf('\nPSO Image Enhancement 3.0.0\n');
fprintf('Best parameters [a b c k]: [%.4f %.4f %.4f %.4f]\n', ...
    result.BestParameters);
fprintf('Iterations: %d\n', result.Iterations);
fprintf('Original sharpness: %.4f\n', getImageSharpness(grayImage));
fprintf('Enhanced sharpness: %.4f\n', getImageSharpness(enhancedImage));
fprintf('Original entropy: %.4f\n', entropy(grayImage));
fprintf('Enhanced entropy: %.4f\n', entropy(enhancedImage));
end

function grayImage = toGrayscale(inputImage)
if ndims(inputImage) == 3
    grayImage = rgb2gray(inputImage);
else
    grayImage = inputImage;
end
end
