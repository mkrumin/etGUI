function [paramsOut, frameThresh] = analyseSingleFrameFake(frame, params)

frame = frame*2;
th = params;

frameThresh = 0.3;

paramsOut.x0 = 1;
paramsOut.y0 = 2;
paramsOut.aAxis = 3;
paramsOut.bAxis = 4;
paramsOut.abAxis = 5;
paramsOut.area = 6;
paramsOut.good = true;
paramsOut.xx = randn(10, 1);
paramsOut.yy = randn(10,1);
paramsOut.equation = sprintf('(x-%d)^2/%d+(y-%d)^2/%d+(x-%d)*(y-%d)/%d-%d', ...
    1, 2, 3, 4, 5, 6, 7, 1);

