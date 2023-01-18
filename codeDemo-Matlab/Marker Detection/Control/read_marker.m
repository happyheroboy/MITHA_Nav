% ��ͼ��"img"�ж�ȡ������, ������б�"ptList"�����ӹ�ϵ"edge".
% Read HydraMarkers from "img", output feature list "ptList" and adjacency
% list "edge".

% - ptList
%   Nx3�ľ���, ÿ�ж�Ӧһ��������, ���зֱ�Ϊ��������ͼ���е��������С�������,
%   �Լ�ID(�������ڱ��������е�����).
%   Nx3 matrix, each row corresponds to a feature, the first two columns
%   represent their subpixel coordinates in "img" (row-column), the last
%   column represents their IDs (indexes in HydraMarker).

% - edge
%   Nx2�ľ���, ÿ�ж�Ӧһ������, ����������������"ptList"�е�����.
%   һ�������㱻����, ˵��������Ϊ�öԵ��ں�����������.
%   Nx2 matrix, each row corresponds to a connection between two features,
%   containing the indexes of the two connected features in "ptList".
%   A pair of features are connected only if they are identified to be
%   neighbors in HydraMarker.

% - img
%   ����ͼ������ǵ�ͨ��double��.
%   Input image must be single channel, double type.

% - sta
%   ͼ"img"����ʹ�õĺ�����ĵ����.
%   The dot matrix of the HydraMarker used in "img".

% - r, expectN, sigma
%   ����غ���
%   see corresponding functions

function [ptList,edge] = read_marker(img,sta,r,expectN,sigma)

if ~exist('r','var')
    r = 5;
end
if ~exist('expectN','var')
    expectN = 100;
end
if ~exist('sigma','var')
    sigma = 3;
end

ptList = preFilter(img,r,expectN,sigma);
% figure;
% imshow(img);
% hold on;
% % ���Ʊ� draw edges
% % Y = ptList(:,1);
% % X = ptList(:,2);
% % plot(X(edge'),Y(edge'),'LineWidth',3,'Color','g');
% % ���Ƶ� draw dots
% scatter(ptList(:,2),ptList(:,1),100,'r','filled','o','LineWidth',1);

[ptList,ledge] = ptRefine(img,ptList,r);
% figure;
% imshow(img);
% hold on;
% % ���Ʊ� draw edges
% % Y = ptList(:,1);
% % X = ptList(:,2);
% % plot(X(edge'),Y(edge'),'LineWidth',3,'Color','g');
% % ���Ƶ� draw dots
% scatter(ptList(:,2),ptList(:,1),50,'r','filled','o','LineWidth',1);

[array,edge] = ptStruct(ptList,ledge);

% figure;
% imshow(img);
% hold on;
% % ���Ʊ� draw edges
% Y = ptList(:,1);
% X = ptList(:,2);
% plot(X(edge'),Y(edge'),'LineWidth',3,'Color','g');
% % ���Ƶ� draw dots
% scatter(ptList(:,2),ptList(:,1),50,'r','filled','o','LineWidth',1);



ptList = ptIdentify(img,sta,array,ptList);

end

