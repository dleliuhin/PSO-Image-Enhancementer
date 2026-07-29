function [enhancedImage, result] = psoEnhanceImage(inputImage, varargin)
%PSOENHANCEIMAGE Backward-compatible entry point for PSO Image Enhancement.
%   [ENHANCED, RESULT] = PSOENHANCEIMAGE(IMAGE, NAME, VALUE) delegates to
%   PSOENHANCE.ENHANCE. RGB input is enhanced in perceptual luminance by
%   default and returned as RGB.
%
%   See also PSOENHANCE.ENHANCE, PSOENHANCE.BENCHMARK.

[enhancedImage, result] = psoenhance.enhance(inputImage, varargin{:});
end
