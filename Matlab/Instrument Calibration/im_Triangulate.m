close all;
% detect features from images
%triangulate(point 1,point 2,stereoParams)

load sta1.mat
load calibrationSession.mat
stereoParams=calibrationSession.CameraParameters;
sta = sta1;

imageNum=2;
IL=cell(imageNum,1);
IR=cell(imageNum,1);
PTLISTL=cell(imageNum,1);
PTLISTR=cell(imageNum,1);

for b=1:imageNum
    ml=im2double(imread(['.\Data\0\',int2str(b),'.bmp']));
    mr=im2double(imread(['.\Data\1\',int2str(b),'.bmp']));
    
    ml = undistortImage(ml,stereoParams.CameraParameters1);
    mr = undistortImage(mr,stereoParams.CameraParameters2);
    
    IL{b}=ml;
    IR{b}=mr;
    
    %%read marker
    expectN = 2*(size(sta,1)+1)*(size(sta,2)+1);
    [ptListl,edgel] = read_marker(ml,sta,5,expectN,3);    
    [ptListr,edger] = read_marker(mr,sta,5,expectN,3);
    
    ptListl(:,3)=ptListl(:,3);
    ptListr(:,3)=ptListr(:,3);
    %点的特征列表
    PTLISTL{b}=ptListl;
    PTLISTR{b}=ptListr;
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
end
    
%%remove NaN
for c=1:imageNum
    A=PTLISTL{c};
    [cx1,cy1]=find(isnan(A));
    A(cx1,:)=[];
    AA=[A(:,2) A(:,1) A(:,3)];
    PTLISTL{c}=AA;
    
    B=PTLISTR{c};
    [cx2,cy2]=find(isnan(B));
    B(cx2,:)=[];
    BB=[B(:,2) B(:,1) B(:,3)];
    PTLISTR{c}=BB;
end

PTLISTLL=cell(imageNum,1);
PTLISTRR=cell(imageNum,1);

%%Trangulation
Error=[];
point3D=cell(1,imageNum);
for e=1:imageNum
    pointL=PTLISTL{e};
    pointR=PTLISTR{e};
    
    [c,ia,ib]=intersect(pointL(:,3),pointR(:,3));

    [p3d,error]=triangulate(pointL(ia,1:2),pointR(ib,1:2),stereoParams);
    p3did=[p3d pointL(ia,3)];
    point3D{e}=p3did;
    %重投影误差 repro error
    Error=[Error,mean(error)];
end

po=single(eye(3));
pl=single(zeros(1,3));
Orientation={};
Location={};
Orientation{1,imageNum}=po;
Location{1,imageNum}=pl;

for j=2:imageNum
    pre3Did=point3D{j-1};
    pre3D=pre3Did(:,1:3);
    cur3Did=point3D{j};
    cur3D=cur3Did(:,1:3);

    [c,ia,ib]=intersect(pre3Did(:,4),cur3Did(:,4));
    [r_mat,t_mat]  = CalculateRTMatrix(pre3Did(ia,1:3),cur3Did(ib,1:3));

    Orientation{j-1} = r_mat;
    Location{j-1} = t_mat;   
end
%%
vSet = viewSet;
viewId=imageNum;
po=single(eye(3));
pl=single(zeros(1,3));
vSet = addView(vSet,imageNum,'Orientation',eye(3),'Location',[0,0,0]);

for i=imageNum-1:-1:1
   vSet = addView(vSet,i); 
   prevPose = poses(vSet, i+1);
   prevOrientation= prevPose.Orientation{1};
   prevLocation=prevPose.Location{1};
   orientation=double(Orientation{i} * prevOrientation) ;
   location = double(prevLocation + Location{i}*prevOrientation);
   vSet = updateView(vSet, i, 'Orientation', orientation, ...
        'Location', location);
end
%% multi-view reconstruction
last_points3Did={};
for i=imageNum-1:-1:1
    pid=point3D{i};
    p=pid(:,1:3);
    id=pid(:,4);
    prevPose = poses(vSet, i);
    r=prevPose.Orientation{1};
    t=prevPose.Location{1};
    last_point3D=p*r+t;
    last_point3Did=[last_point3D,id];
    last_points3Did{i}=last_point3Did;
end

last_points3Did{imageNum}=point3D{1,imageNum};

%obtain instrument calibration model
XYZpoints=point3D{1,imageNum};
for i=imageNum-1:-1:1
    qp=last_points3Did{i};
    hp=last_points3Did{i+1};
    diffid=setdiff(qp(:,4),hp(:,4));
    xyzpoints=[];
    for j=1:size(diffid,1)
        [row,col]=find(qp(:,4)==diffid(j));
        xyzpoint=qp(row,:);
        xyzpoints=[xyzpoints;xyzpoint];
    end
    XYZpoints=[XYZpoints;xyzpoints];
end

figure();
plot3(XYZpoints(:,1), XYZpoints(:,2), XYZpoints(:,3), '.');
text(XYZpoints(:,1),XYZpoints(:,2),XYZpoints(:,3),num2str(XYZpoints(:,4)),'FontSize',15,'Color','k');
