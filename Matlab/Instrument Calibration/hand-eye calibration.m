close all;

%%思路
% 读取图片上的特征点
%%找到1图片的特征点，然后在2的特征点中寻找
%%triangulate(point 1,point 2,)
load 10x10_for_3x3_6x2_10x1.mat
% load calibrationSession22-01-13.mat
% stereoParams=calibrationSession.CameraParameters;
%% 
IL={};
IR={};
PTLISTL={};
PTLISTR={};

ml=im2double(imread('C:\Users\Lenovo\Desktop\220613\LLL\1.bmp'));
mr=im2double(imread('C:\Users\Lenovo\Desktop\220613\RRR\1.bmp'));

ml = undistortImage(ml,stereoParams.CameraParameters1);
mr = undistortImage(mr,stereoParams.CameraParameters2);

IL{1}=ml;
IR{1}=mr;

expectN = 2*(size(sta,1)+1)*(size(sta,2)+1);
[ptListl,edgel] = read_marker(ml,sta,5,expectN,3);
[ptListr,edger] = read_marker(mr,sta,5,expectN,3);

%点的特征列表
PTLISTL{1}=ptListl;
PTLISTR{1}=ptListr;

% 显示
figure;
imshow(ml);
hold on;
% 绘制边 draw edges
Y = ptListl(:,1);
X = ptListl(:,2);
plot(X(edgel'),Y(edgel'),'LineWidth',3,'Color','g');
% 绘制点 draw dots
scatter(ptListl(:,2),ptListl(:,1),100,'g','filled','o','LineWidth',1);
% 绘制不确定ID的点 draw unsure IDs
pt_uID = ptListl(isnan(ptListl(:,3)),:);
scatter(pt_uID(:,2),pt_uID(:,1),100,'r','x','LineWidth',3);
% 绘制ID draw IDs
pt_ID = ptListl(~isnan(ptListl(:,3)),:);
text(pt_ID(:,2),pt_ID(:,1),num2str(pt_ID(:,3)),'FontSize',15,'Color','y');
%     
%     figure;
%     imshow(mr);
%     hold on;
%     % 绘制边 draw edges
%     Y = ptListr(:,1);
%     X = ptListr(:,2);
%     plot(X(edger'),Y(edger'),'LineWidth',3,'Color','g');
%     % 绘制点 draw dots
%     scatter(ptListr(:,2),ptListr(:,1),100,'g','filled','o','LineWidth',1);
%     % 绘制不确定ID的点 draw unsure IDs
%     pt_uID = ptListr(isnan(ptListr(:,3)),:);
%     scatter(pt_uID(:,2),pt_uID(:,1),100,'r','x','LineWidth',3);
%     % 绘制ID draw IDs
%     pt_ID = ptListr(~isnan(ptListr(:,3)),:);
%     text(pt_ID(:,2),pt_ID(:,1),num2str(pt_ID(:,3)),'FontSize',15,'Color','y');

%% 

%%剔除NaN
for c=1
    A=PTLISTL{c};
    [cx1,cy1]=find(isnan(A));
    A(cx1,:)=[];
    PTLISTL{c}=A;
    
    B=PTLISTR{c};
    [cx2,cy2]=find(isnan(B));
    B(cx2,:)=[];
    PTLISTR{c}=B;
end

%%换x和y坐标
for d=1
    A=PTLISTL{d};
    A1=A(:,1);
    A2=A(:,2);
    AA=[A2 A1 A(:,3)];
    PTLISTLL{d}=AA;
    
    B=PTLISTR{d};
    B1=B(:,1);
    B2=B(:,2);
    BB=[B2 B1 B(:,3)];
    PTLISTRR{d}=BB;
end
%%

%%ID 和坐标
%%%%%剩下的就是计算ID 和ID之间的匹配、求三维坐标
pointgp3D={};
for e=1
    pointL=PTLISTLL{e};
    pointR=PTLISTRR{e};
    [c,ia,ib]=intersect(pointL(:,3),pointR(:,3));
    %%计算第一对匹配点的三维值
    [p3d,error]=triangulate(pointL(ia,1:2),pointR(ib,1:2),stereoParams);
    p3did=[p3d c];
    pointgp3D{e}=p3did;
end


[c,ia,ib]=intersect(XYZpoints(:,4),pointgp3D{1,1}(:,4));
[r_mat,t_mat]  = SVDICPxiugai(pointgp3D{1,1}(ib,1:3),XYZpoints(ia,1:3));

tipPoint=pinPoint(:,1:3)*r_mat+t_mat;
tipPoint=[tipPoint 3000];
cali=[XYZpoints;tipPoint];

figure();
plot3(cali(:,1), cali(:,2), cali(:,3), '.');
text(cali(:,1),cali(:,2),cali(:,3),num2str(cali(:,4)),'FontSize',15,'Color','k');

L=[L(:,2:3) L(:,1)];
R=[R(:,2:3) R(:,1)];
% xlswrite('C:\Users\Lenovo\Desktop\data.xlsx',cali)