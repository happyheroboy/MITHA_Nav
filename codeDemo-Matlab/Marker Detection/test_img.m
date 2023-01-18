reset_toolbox;
close all

%% ���ɺ�����
% generate HydraMarker
% % shape{1,1} = ones(3);
% % shape{2,1} = ones(10,1);
% % shape{3,1} = ones(6,2);
% [sta,img] = build_marker(20,10,200,shape);

%% ���߶�ȡ�ѱ���ĺ�����
% or load a HydraMarker
load 10x10_for_3x3_6x2_10x1.mat

%% ��ȡһ�Ű����������ͼƬ
% read an image containing HydraMarker
img = im2double(imread('.\Data\1.bmp'));
% img=rgb2gray(img);

%% ʶ�������е�������
% identify the features of HydraMarker
expectN =2*(size(sta,1)+1)*(size(sta,2)+1);
[ptList,edge] = read_marker(img,sta,5,expectN,3);

%% ��ʾ
% display
figure;
imshow(img);
hold on;
% ���Ʊ� draw edges
% Y = ptList(:,1);
% X = ptList(:,2);
% plot(X(edge'),Y(edge'),'LineWidth',3,'Color','g');
% % ���Ƶ� draw dots
scatter(ptList(:,2),ptList(:,1),50,'r','filled','o','LineWidth',1);

% points2D=Points2D{1,1};
% scatter(points2D(:,1),points2D(:,2),100,'g','filled','o','LineWidth',1);
% scatter(points2D(:,1),points2D(:,2),100,'b','filled','o','LineWidth',1);

% ���Ʋ�ȷ��ID�ĵ� draw unsure IDs
% pt_uID = ptList(isnan(ptList(:,3)),:);
% scatter(pt_uID(:,2),pt_uID(:,1),100,'g','x','LineWidth',3);
% ����ID draw IDs
pt_ID = ptList(~isnan(ptList(:,3)),:);
text(pt_ID(:,2),pt_ID(:,1),num2str(pt_ID(:,3)),'FontSize',20,'Color','y');
