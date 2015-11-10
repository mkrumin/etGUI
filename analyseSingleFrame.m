function [paramsOut, frameThresh] = analyseSingleFrame(frame, params)

gaussStd = params.gaussStd;
diskR = params.diskR;
sat = params.sat;
th = params.th;

hGauss = fspecial('gaussian', ceil(5*gaussStd), gaussStd);
hDisk = fspecial('disk', diskR);
frameFiltered = imfilter(frame, imfilter(hGauss, hDisk, 0, 'full'), 'replicate');
% frameFiltered = imfilter(frameFiltered, hDisk, 'replicate');

% normalize the frame
% c = class(frameFiltered);
frameFiltered = double(frameFiltered);
% frameFiltered = (frameFiltered-double(intmin(c)))/double(intmax(c));
frameFiltered = frameFiltered - min(frameFiltered(:));
frameFiltered = frameFiltered/max(frameFiltered(:));

% saturate the frame
frameThresh = frameFiltered;
frameThresh(frameThresh>sat)=sat;
% and then normalize once again
frameThresh = frameThresh/sat;

% threshold  = 0.5;
% frameThresh(frameThresh>=threshold) = 1;
% frameThresh(frameThresh<threshold) = 0;
% % frameThresh = logical(frameThresh);

[C] = contourc(frameThresh, [th, th]);
CC = getContours(C);

% picking up the right contour to analyze
% the first attempt was to pick the longest contour, which is sometimes a bad idea
% nPoints = [];
% for i=1:length(CC)
%     nPoints(i) = length(CC(i).xx);
% end
% iMax = find(nPoints==max(nPoints), 1, 'first');
% xx = CC(iMax).xx;
% yy = CC(iMax).yy;

% picking the most central contour in the ROI, usually works better
distance = nan(length(CC), 1);
roiX = size(frame, 2)/2;
roiY = size(frame, 1)/2;
for i=1:length(CC)
    distance(i) = norm([mean(CC(i).xx)-roiX, mean(CC(i).yy)-roiY]);
end
iMin = find(distance==min(distance), 1, 'first');

if ~isempty(CC)
    xx = CC(iMin).xx;
    yy = CC(iMin).yy;
    
    % now let's fit the ellipse
    % we are basically solving an equation for the quadratic curve in 2-D
    % of the form: Ax^2+Bxy+Cy^2+Dx+Ey=1
    params = -pinv([xx.^2, xx.*yy, yy.^2, xx, yy])*ones(size(xx));
    
    f = 1;
    if params(1)<0
        params = -params;
        f = -1;
    end
    a = params(1);
    b = params(2);
    c = params(3);
    d = params(4);
    e = params(5);
    
    % checking if the ellipse is a proper real ellipse (and not e.g.
    % hyperbola or parabola, which also are conic sections)
    
    good = c*det([a, b/2, d/2; b/2, c, e/2; d/2, e/2, f]) < 0;
    
else
    % in case there were no contours detected at all (might happen during a
    % blink, for example) assign nans where applicable
    xx = [];
    yy = [];
    params = NaN(5, 1);
    a = NaN; b = NaN; c = NaN; d = NaN; e = NaN;
    good = false;
end

% let's do a bit of analytical geometry

y0=(2*a*e-b*d)/(-4*a*c+b^2);
x0=-(e+2*c*y0)/b;

ff = a*x0^2+x0*y0*b+c*y0^2;

aAxis=sqrt(1/a)*sqrt(ff-1);
bAxis=sqrt(1/c)*sqrt(ff-1);
abAxis=1/b*(ff-1);
area = pi*aAxis*bAxis;
phi = 1/2*atan(b/(c-a)); % the ellipse tilt angle is currently not used,
% as the estimate is noisy and ambiguous (because of the ambiguity in atan())

paramsOut.x0 = x0;
paramsOut.y0 = y0;
paramsOut.aAxis = aAxis;
paramsOut.bAxis = bAxis;
paramsOut.abAxis = abAxis;
paramsOut.area = area;
paramsOut.good = good;
paramsOut.xx = xx;
paramsOut.yy = yy;
paramsOut.equation = sprintf('(x-%d)^2/%d+(y-%d)^2/%d+(x-%d)*(y-%d)/%d-%d', ...
    x0, aAxis^2, y0, bAxis^2, x0, y0, abAxis, 1);

