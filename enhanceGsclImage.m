function [oEnhancedImg] = enhanceGsclImage(iGsclImg, ...
                                           iLocalSize, ...
                                           iA, ...
                                           iB, ...
                                           iC, ...
                                           iK)
%% ENHANCEGSCLIMAGE 
% Transformation function that change the intensity value 
% of a grayscale image pixel.
% 
% * Syntax 
% 
% [OENHANCEDIMG] = ENHANCEGSCLIMAGE(IGSCLIMG, ILOCALSIZE, IA, IB, IC, IK)
% 
% * Input 
% 
% -- iGsclImg - input grayscaled image;
%
% -- iLocalSize - specific local window size.
% 
% -- IA, IB, IC, IK -  are the parameters of the enhancement function 
%                      and the small variation in their value produces a 
%                      large variation in the processed output image and 
%                      thus the value of these parameters should be 
%                      precisely set.
% 
% * Output 
% 
% -- OENHANCEDIMG -  output enhanced image. With the transformation 
%                    contrast of the image can be stretched considering 
%                    local mean as the centre of stretch.
% 
% * Examples: 
% 
% Provide sample usage code here
% 
% * See also: 
% 
% List related files here 
% 
% * Author: *Dmitrii Leliuhin*
% * Email: dleliuhin@mail.ru 
% * Date: 11/12/2018 02:55:41 
% * Version: 2.0 $ 
% * Requirements: PCWIN64, MatLab R2016a 
% 
% * Warning: 
% 
% # Warnings list. 
% 
% * TODO: 
% 
% # TODO list. 
% 

%% Code 

% Converting input grayscaled image to double
doubleGsclImg = im2double(iGsclImg);

% Calculating global mean
gmean = mean2(doubleGsclImg);

% Calculating local std 
lstd = stdfilt(doubleGsclImg);

% Calculating local mean.
% Has brightening & smoothing effect thus smooths the output image 
% and the four parameters introduced in the transformation function.
lmean = conv2(doubleGsclImg, ones(iLocalSize)/9, 'same');

% Calculating enhancement function
kFunc = (iK.*gmean)./(lstd + iB);

% Compute transformation function
oEnhancedImg = kFunc.*(doubleGsclImg - (iC.*lmean)) + (lmean.^iA);

end
