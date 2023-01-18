function [points1, points2, camMatrix1, camMatrix2] = ...
    parseInputs(matchedPoints1, matchedPoints2, varargin)

narginchk(3, 4);
[points1, points2] = parsePoints(matchedPoints1, matchedPoints2);
[P1, P2] = parseCameraMatrices(varargin{:});
camMatrix1 = cast(P1, 'like', points1)';
camMatrix2 = cast(P2, 'like', points2)';

