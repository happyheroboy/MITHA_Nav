% 根据图像"img", 海拉码点矩阵"sta", 组织网格"array"和点列表"ptList", 确认每个点的ID, 并存放在"ptList"中.
% Identify the IDs of the features in "ptList" based on image "img",
% HydraMarker dot matrix "sta" and grid "array".

% - ptList
%   Nx3的矩阵, 每行对应一个特征点, 各列分别为特征点在图像中的亚像素行、列坐标,
%   以及ID(特征点在本海拉码中的索引).
%   ID可能为NaN, 表示不能唯一确定.
%   Nx3 matrix, each row corresponds to a feature, the first two columns
%   represent their subpixel coordinates in "img" (row-column), the last
%   column represents their IDs (indexes in HydraMarker).
%   NaN ID means unsure. 

function ptList = ptIdentify(img,sta,array,ptList)
    
    
    if isempty(array)
        ptList = [ptList,nan(size(ptList,1))];
        if isempty(ptList)
            ptList = [1,1,1];
            ptList(1,:) = [];
        end
        return;
    end
    %% 根据交叉点矩阵"array"进行特定位置采样, 获得"dot"矩阵.
    % Sampling based on cross point matrix "array" to aquire dot matrix
    % "dot".
    matrix_num = size(array,1);
    dot = cell(size(array));
    
    for it = 1 : matrix_num
        [M,N] = size(array{it}); 
        if any([M,N]<2)
            continue;
        end
        dot{it} = zeros([M,N]-[1,1]);
        % 获得交叉点与圆点的坐标
        % aquire the locations of cross points and dots
        array_list = array{it}(:);
        array_list(isnan(array_list)) = 1;
        ptArray = reshape(ptList(array_list,:),M,N,2);
        
        ptDot = imfilter(ptArray,fspecial('average',[2 2]));
        ptDot(:,end,:) = [];
        ptDot(end,:,:) = [];
        % 读圆点
        % read the dots
        for im = 1 : M-1
            for in = 1 : N-1
                if any(any(isnan(array{it}(im:im+1,in:in+1))))
                    dot{it}(im,in) = NaN;
                    continue;
                end
                sample_background = ptArray(im:im+1,in:in+1,:)*0.8+ptDot(im,in,:)*0.2;
                sample_foreground = ptArray(im:im+1,in:in+1,:)*0.2+ptDot(im,in,:)*0.8;
                ind_background = sub2ind(size(img),round(sample_background(1:4)),round(sample_background(5:8)));
                ind_foreground = sub2ind(size(img),round(sample_foreground(1:4)),round(sample_foreground(5:8)));
                if abs(mean(img(ind_background))-mean(img(ind_foreground)))>0.2
                    dot{it}(im,in) = 1;
                end
            end % for in = 1 : N-1
        end % for im = 1 : M-1
        
    end % for it = 1 : matrix_num
    
    %% 对比dot与sta, 确定array的位姿.
    % compare dot with sta to locate the pose of array.
    matchMap = cell(size(dot,1),4);
    match_info = zeros(matrix_num,4);
    % "match_info"每行对应一个连通网格, 各列分别为: 最大匹配度/最佳匹配的旋转姿态/行坐标/列坐标
    % 某行可能全为-1, 表示该连通区域的位姿存在多种解释.
    % 某行可能全为0, 表示该连通区域未构成任何方块(没有点可读).
    % Each row of "match_info" corresponds to a connected grid.
    % The columns are best matching score/best pose/row/column.
    % Some rows might be -1, which means that there might be multiple
    % legal poses.
    % Some rows might be 0, which means that no square is formed by the
    % connected grid (no dot to read).
    for it = 1 : matrix_num
        if isempty(dot{it})
            continue;
        end
        for k = 0 : 3
            dot_rotated = rot90(dot{it},k);
            matchMap{it,k+1} = match(dot_rotated,sta);
        end % for k = 0 : 3
        match_info(it,1) = max([max(matchMap{it,1}(:)),max(matchMap{it,2}(:)),max(matchMap{it,3}(:)),max(matchMap{it,4}(:))]);
        for k = 1 : 4
            [max_m,max_n] = find(matchMap{it,k}==match_info(it,1));
            if isempty(max_m)
                continue;
            elseif size(max_m,1)>1
                match_info(it,2:4) = -ones(1,3);
            else
                if match_info(it,2)~=0
                    match_info(it,2:4) = -ones(1,3);
                else
                    match_info(it,2:4) = [k,max_m(1),max_n(1)];
                end
            end
        end
    end % for it = 1 : matrix_num

    %% 根据匹配结果给"ptList"中的点赋值ID.
    % assign IDs to the points in "ptList" based on the matching
    % results.
    pair = [];
    [staM,staN] = size(sta);
    indMatrix = reshape(1:(staM+1)*(staN+1),[staM+1,staN+1]);
    for it = 1 : matrix_num
        if match_info(it,1) <= 0
            pair = [pair;array{it}(:),nan(size(array{it}(:)))];
            continue;
        end
        match_m = match_info(it,3);
        match_n = match_info(it,4);
        k = match_info(it,2)-1;
        [arrM,arrN] = size(rot90(array{it},k));
        
        matched_ind = indMatrix...
            (max(match_m-arrM+2,1):min(match_m+1,staM+1),...
             max(match_n-arrN+2,1):min(match_n+1,staN+1));
        
        array_ind = nan(arrM,arrN);
        array_ind...
            (max(arrM-match_m,1):min(staM+arrM-match_m,arrM),...
             max(arrN-match_n,1):min(staN+arrN-match_n,arrN))...
             = matched_ind;
        array_ind = rot90(array_ind,-k);

        pair = [pair;array{it}(:),array_ind(:)];
    end
    pair(isnan(pair(:,1)),:) = [];
    pair = sortrows(pair);
    
    % 使用"full_pair"中继以免"ptList"中的某些点不存在于"pair"中(可能发生于网格不标准, 在方向体传递中某些点被顶掉,未出现于"array").
    % Use "full_pair" to prevent the situation that some points might not
    % be included in "pair" (this might happen when the organized grid is
    % illegal, thus some points are replaced by others when delivering the compass, not appear in "array").
    full_pair = nan(size(ptList,1),1);
    full_pair(pair(:,1)) = pair(:,2);
    ptList = [ptList,full_pair];
end

function map = match(A,B)
    
    A(A==0) = -1;
    A(isnan(A)) = 0;
    
    B(B==0) = -1;
    B(isnan(B)) = 0;
    
    map = conv2(rot90(A,2),B);
    
end
