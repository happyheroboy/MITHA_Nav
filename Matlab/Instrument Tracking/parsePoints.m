%--------------------------------------------------------------------------
function [pts1, pts2] = parsePoints(matchedPoints1, matchedPoints2)

[points1, points2] =  ...
    vision.internal.inputValidation.checkAndConvertMatchedPoints(...
    matchedPoints1, matchedPoints2, mfilename, 'matchedPoints1', ...
    'matchedPoints2');

if isa(points1, 'double')
    pts1 = points1';
    pts2 = points2';
else
    pts1 = single(points1)';
    pts2 = single(points2)';
end


