function [oSharpness] = getImageSharpness(iImage)
%% GETIMAGESHARPNESS 
% Function for calculating sharpness of image.
% 
% * Syntax 
% 
%	[OSHARPNESS] = GETIMAGESHARPNESS(IIMAGE)
% 
% * Input 
% 
% -- iImage - input iImage with different dimension.
% 
% * Output 
% 
% -- oSharpness - calculated sharpnes of iImage.
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
% * Date: 13/12/2018 01:17:39 
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

% Find the gradient Cartesian coordinates of image.
[Gx, Gy] = gradient(double(iImage));

% Calculate intermediate function.
S = sqrt(Gx.*Gx+Gy.*Gy);

% Calculate sharpness of image.
oSharpness = sum(sum(S))./(numel(Gx));

end
