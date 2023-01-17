
close all
%load marker field
load 10x10_for_3x3_6x2_10x1.mat
 %load calibration model
load('Instrument_Calibration_Model.mat')

 %load cameara calibration parameter
load calibrationSession.mat
stereoParams=calibrationSession.CameraParameters;

ml=im2double((imread('.\test_image_l.bmp')));
mr=im2double((imread('.\test_image_r.bmp')));

ml = undistortImage(ml,stereoParams.CameraParameters1);
mr = undistortImage(mr,stereoParams.CameraParameters2);

IL=ml;
IR=mr;
%%
%%特征点
expectN = 2*(size(sta,1)+1)*(size(sta,2)+1);
[ptListl,edgel] = read_marker(ml,sta,5,expectN,3);
[ptListr,edger] = read_marker(mr,sta,5,expectN,3);

ptListl(:,3)=ptListl(:,3);
ptListr(:,3)=ptListr(:,3);
%点的特征列表
PTLISTL=ptListl;
PTLISTR=ptListr;
%%
% 显示 display
figure;
imshow(ml);
hold on;
% 绘制边 draw edges
Y = ptListl(:,1);
X = ptListl(:,2);
plot(X(edgel'),Y(edgel'),'LineWidth',3,'Color','r');
% 绘制点 draw dots
scatter(ptListl(:,2),ptListl(:,1),100,'g','filled','o','LineWidth',4);
% 绘制不确定ID的点 draw unsure IDs
pt_uID = ptListl(isnan(ptListl(:,3)),:);
scatter(pt_uID(:,2),pt_uID(:,1),100,'r','x','LineWidth',3);
% 绘制ID draw IDs
pt_ID = ptListl(~isnan(ptListl(:,3)),:);
text(pt_ID(:,2),pt_ID(:,1),num2str(pt_ID(:,3)),'FontSize',30,'Color','g');
%
figure;
imshow(mr);
hold on;
% 绘制边 draw edges
Y = ptListr(:,1);
X = ptListr(:,2);
plot(X(edger'),Y(edger'),'LineWidth',3,'Color','r');
% 绘制点 draw dots
scatter(ptListr(:,2),ptListr(:,1),100,'g','filled','o','LineWidth',4);
% 绘制不确定ID的点 draw unsure IDs
pt_uID = ptListr(isnan(ptListr(:,3)),:);
scatter(pt_uID(:,2),pt_uID(:,1),100,'r','x','LineWidth',3);
% 绘制ID draw IDs
pt_ID = ptListr(~isnan(ptListr(:,3)),:);
text(pt_ID(:,2),pt_ID(:,1),num2str(pt_ID(:,3)),'FontSize',30,'Color','g');
%%
%%剔除NaN  remove NaN
% for c=1:imageNum
A=PTLISTL;
[cx1,cy1]=find(isnan(A));
A(cx1,:)=[];
AA=[A(:,2) A(:,1) A(:,3)];
PTLISTL=AA;

B=PTLISTR;
[cx2,cy2]=find(isnan(B));
B(cx2,:)=[];
BB=[B(:,2) B(:,1) B(:,3)];
PTLISTR=BB;

% for e=1:imageNum
pointL=PTLISTL;
pointR=PTLISTR;
[c,ia1,ib1]=intersect(pointL(:,3),pointR(:,3));

%%计算第一对匹配点的三维值
[p3d,error]=triangulate(pointL(ia1,1:2),pointR(ib1,1:2),stereoParams);
p3did=[p3d pointL(ia1,3)];
point3D=p3did;
%重投影误差
Error=mean(error);

%%
%%3D-2D
[points1, points2, camMatrix1, camMatrix2] = ...
    parseInputs(pointL(ia1,1:2),pointR(ib1,1:2), stereoParams);

%%
[c,ia2,ib2]=intersect(cali(:,4),point3D(:,4));
[r_mat,t_mat] = CalculateRTMatrix(cali(ia2,1:3),point3D(ib2,1:3));
calculatedModel1 = cali(:,1:3)*r_mat+ t_mat;

points1proj1 = projectPoints(calculatedModel1, camMatrix1);
points1proj1=points1proj1';
points1proj1=[points1proj1 cali(:,4)];

%% draw the curve surface
hold off;
imshow(ml);
hold on;
[~,loc] = ismember([1:11,22:11:66,65:-1:56,45:-11:1],points1proj1(:,3));
[~,bjloc] = ismember(300,points1proj1(:,3));

plot(points1proj1(loc,1),points1proj1(loc,2),'Color',[0 0.4470 0.7410],'LineWidth',3);
plot(points1proj1(bjloc,1),points1proj1(bjloc,2),'.','Color','r','MarkerSize',10);







