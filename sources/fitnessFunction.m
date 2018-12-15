function [oFit] = fitnessFunction(iE, iM, iN)
%% FITNESSFUNCTION 
% Function to evaluate the fitness value for new position.
% 
% * Syntax 
% 
% [OFIT] = FITNESSFUNCTION(IE, IM, IN)
% 
% * Input 
% 
% -- iE - input enhanced image.
% 
% -- iM - denotes the number of columns.
% 
% -- iN - denotes the number of rows.
% 
% * Output 
% 
% -- oFit - output compted objective function which tells us about 
%           the quality of the input enhanced image.
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
% * Date: 11/12/2018 03:52:24 
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

% Gradient magnitude and direction of an input enhanced image using 
% Sobel gradient operator.
EGrad = imgradient(iE, 'sobel');

% Calculate sum of pixel intensities (number of nonzero matrix elements).
sumIntensities = sum(sum(EGrad));

% Number of pixels, whose intensity value is greater than 
% a threshold in Sobel edge image.
numberEdgels = nnz(EGrad);

% Calculate Entropy of enhanced image.
entropyEnh = entropy(iE);

% Compute objective function which tells us about the quality of 
% the input enhanced image.
oFit = log(log(sumIntensities)).*(numberEdgels./(iM.*iN)).*entropyEnh;

end