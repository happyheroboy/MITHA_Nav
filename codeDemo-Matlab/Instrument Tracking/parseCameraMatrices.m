%--------------------------------------------------------------------------
function [cameraMatrix1, cameraMatrix2] = parseCameraMatrices(varargin)
if nargin == 1
    stereoParams = varargin{1};
    validateattributes(stereoParams, {'stereoParameters'}, {}, ...
        mfilename, 'stereoParams');
    cameraMatrix1 = cameraMatrix(stereoParams.CameraParameters1, eye(3), [0 0 0]);
    cameraMatrix2 = cameraMatrix(stereoParams.CameraParameters2, ...
        stereoParams.RotationOfCamera2, stereoParams.TranslationOfCamera2);
else
    narginchk(2, 2);
    cameraMatrix1 = varargin{1};
    cameraMatrix2 = varargin{2};
    validateCameraMatrix(cameraMatrix1, 'cameraMatrix1');
    validateCameraMatrix(cameraMatrix2, 'cameraMatrix2');
end