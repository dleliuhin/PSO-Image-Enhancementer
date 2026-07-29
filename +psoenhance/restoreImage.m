function outputImage = restoreImage(luminance, context)
%RESTOREIMAGE Recombine enhanced luminance with the original chroma.

if strcmp(context.Mode, 'lab')
    labImage = context.Lab;
    labImage(:, :, 1) = 100 .* luminance;
    outputImage = lab2rgb(labImage, 'OutputType', 'double');
    outputImage = min(max(outputImage, 0), 1);
else
    outputImage = luminance;
end
end
