
close all

load 10x10_for_3x3_6x2_10x1.mat
load calibrationSession.mat
load('Instrument_Calibration_Model.mat')
stereoParams=calibrationSession.CameraParameters;

imageNum=5;
PTLISTL=cell(imageNum,1);
PTLISTR=cell(imageNum,1);
for b=1:imageNum
    ml=im2double((imread(['.\reg\L\',int2str(b),'.bmp'])));
    mr=im2double((imread(['.\reg\R\',int2str(b),'.bmp'])));
    
    ml = undistortImage(ml,stereoParams.CameraParameters1);
    mr = undistortImage(mr,stereoParams.CameraParameters2);
    
    %%read marker
 
    expectN = 2*(size(sta,1)+1)*(size(sta,2)+1);
    [ptListl,edgel] = read_marker(ml,sta,5,expectN,3);    
    [ptListr,edger] = read_marker(mr,sta,5,expectN,3);
    
    %��������б�
    PTLISTL{b}=ptListl;
    PTLISTR{b}=ptListr;
    %% 
% ��ʾ display
%     figure;
%     imshow(ml);
%     hold on;
%     % ���Ʊ� draw edges
%     Y = ptListl(:,1);
%     X = ptListl(:,2);
%     plot(X(edgel'),Y(edgel'),'LineWidth',3,'Color','g');
%     % ���Ƶ� draw dots
%     scatter(ptListl(:,2),ptListl(:,1),100,'g','filled','o','LineWidth',1);
%     % ���Ʋ�ȷ��ID�ĵ� draw unsure IDs
%     pt_uID = ptListl(isnan(ptListl(:,3)),:);
%     scatter(pt_uID(:,2),pt_uID(:,1),100,'r','x','LineWidth',3);
%     % ����ID draw IDs
%     pt_ID = ptListl(~isnan(ptListl(:,3)),:);
%     text(pt_ID(:,2),pt_ID(:,1),num2str(pt_ID(:,3)),'FontSize',15,'Color','y');
    
%     figure;
%     imshow(mr);
%     hold on;
%     % ���Ʊ� draw edges
%     Y = ptListr(:,1);
%     X = ptListr(:,2);
%     plot(X(edger'),Y(edger'),'LineWidth',3,'Color','g');
%     % ���Ƶ� draw dots
%     scatter(ptListr(:,2),ptListr(:,1),100,'g','filled','o','LineWidth',1);
%     % ���Ʋ�ȷ��ID�ĵ� draw unsure IDs
%     pt_uID = ptListr(isnan(ptListr(:,3)),:);
%     scatter(pt_uID(:,2),pt_uID(:,1),100,'r','x','LineWidth',3);
%     % ����ID draw IDs
%     pt_ID = ptListr(~isnan(ptListr(:,3)),:);
%     text(pt_ID(:,2),pt_ID(:,1),num2str(pt_ID(:,3)),'FontSize',15,'Color','y');
end
    
%%�޳�NaN remove NaN
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

%%
%%Triangulation
Error=cell(imageNum,1);
point3D=cell(1,imageNum);
for e=1:imageNum
    pointL=PTLISTL{e};
    pointR=PTLISTR{e};  
    [c,ia,ib]=intersect(pointL(:,3),pointR(:,3));
    
    %%�����һ��ƥ������άֵ
    [p3d,error]=triangulate(pointL(ia,1:2),pointR(ib,1:2),stereoParams);
    p3did=[p3d pointL(ia,3)];
    point3D{e}=p3did;
    %��ͶӰ��� repro error
    Error{e}=mean(error);
end


Orientation=cell(1,imageNum);
Location=cell(1,imageNum);
for j=1:imageNum
    cur3Did=point3D{1,j};
    [c,ia,ib]=intersect(cali(:,4),cur3Did(:,4));

    [r_mat,t_mat]  = CalculateRTMatrix(cali(ia,1:3),cur3Did(ib,1:3));
    Orientation{j}=r_mat;
    Location{j}=t_mat;   
end


touchedBoneSpur=cali(67,:);

worldBoneSpurs=[];
for cc = 1:imageNum
    calculatedWorldBoneSpurs = touchedBoneSpur(:,1:3)*Orientation{1,cc}+Location{1,cc};
    worldBoneSpurs = [worldBoneSpurs;calculatedWorldBoneSpurs];
end
% 
virtualBoneSpurs = [438.20,152.15,115.78,1;429.10,156.60,118.01,2;434.00,170.70,134.34,3;441.00,182.58,127.66,4;450.10,186.29,122.46,5];
[wv_R,wv_T] = CalculateRTMatrix(worldBoneSpurs(:,1:3),virtualBoneSpurs(:,1:3));

    
% calculateWorldBoneSpurs=worldBoneSpurs*wv_R+wv_T;

%%
%projection to CT image
img=imread('.\reg\ctImg.bmp');
fileNameL='.\reg\0.bmp';
fileNameR='.\reg\1.bmp';
k=1;
Error=[];

st1Cimage={};
stu1tsdimage={};

st2Cimage={};
stu2tsdimage={};

st3Cimage={};
stu3tsdimage={};
%%

ml=im2double(imread(fileNameL));
mr=im2double(imread(fileNameR));

  %%
  %����У��
ml = undistortImage(ml,stereoParams.CameraParameters1);
mr = undistortImage(mr,stereoParams.CameraParameters2);

expectN = 2*(size(sta,1)+1)*(size(sta,2)+1);
[ptListl,edgel] = read_marker(ml,sta,5,expectN,3);
[ptListr,edger] = read_marker(mr,sta,5,expectN,3);

%��������б�
PTLISTL{k}=ptListl;
PTLISTR{k}=ptListr;

%%
% ��ʾ
% figure;
% imshow(ml);
% hold on;
% % ���Ʊ� draw edges
% Y = ptListl(:,1);
% X = ptListl(:,2);
% plot(X(edgel'),Y(edgel'),'LineWidth',3,'Color','g');
% % ���Ƶ� draw dots
% scatter(ptListl(:,2),ptListl(:,1),100,'g','filled','o','LineWidth',1);
% % ���Ʋ�ȷ��ID�ĵ� draw unsure IDs
% pt_uID = ptListl(isnan(ptListl(:,3)),:);
% scatter(pt_uID(:,2),pt_uID(:,1),100,'r','x','LineWidth',3);
% % ����ID draw IDs
% pt_ID = ptListl(~isnan(ptListl(:,3)),:);
% text(pt_ID(:,2),pt_ID(:,1),num2str(pt_ID(:,3)),'FontSize',15,'Color','y');
%     
%     figure;
%     imshow(mr);
%     hold on;
%     % ���Ʊ� draw edges
%     Y = ptListr(:,1);
%     X = ptListr(:,2);
%     plot(X(edger'),Y(edger'),'LineWidth',3,'Color','g');
%     % ���Ƶ� draw dots
%     scatter(ptListr(:,2),ptListr(:,1),100,'g','filled','o','LineWidth',1);
%     % ���Ʋ�ȷ��ID�ĵ� draw unsure IDs
%     pt_uID = ptListr(isnan(ptListr(:,3)),:);
%     scatter(pt_uID(:,2),pt_uID(:,1),100,'r','x','LineWidth',3);
%     % ����ID draw IDs
%     pt_ID = ptListr(~isnan(ptListr(:,3)),:);
%     text(pt_ID(:,2),pt_ID(:,1),num2str(pt_ID(:,3)),'FontSize',15,'Color','y');
%%
A=PTLISTL{k};
[cx1,~]=find(isnan(A));
A(cx1,:)=[];
AA=[A(:,2) A(:,1) A(:,3)];
PTLISTL{k}=AA;

B=PTLISTR{k};
[cx2,~]=find(isnan(B));
B(cx2,:)=[];
BB=[B(:,2) B(:,1) B(:,3)];
PTLISTR{k}=BB;
%%  
pointL=PTLISTL{k};
pointR=PTLISTR{k};
[c,ia,ib]=intersect(pointL(:,3),pointR(:,3));
%%�����һ��ƥ������άֵ
[p3d,error]=triangulate(pointL(ia,1:2),pointR(ib,1:2),stereoParams);
p3did=[p3d pointL(ia,3)];
point3D{k}=p3did;
%��ͶӰ���
Error=[Error,mean(error)];
%%
[matchpoint,ia1,ib1]=intersect(cali(:,4),p3did(:,4));
% nid=size(matchpoint,1);
% Matchppoint=[];
% Matchcpoint=[];
% for j=1:nid
%     id=matchpoint(j);
%     matchppoint=cali(cali(:,4)==id,:);
%     matchcpoint=p3did(p3did(:,4)==id,:);
%     Matchppoint=[Matchppoint;matchppoint];
%     Matchcpoint=[Matchcpoint;matchcpoint];
% end


if  isempty(matchpoint)
    zhpoints{k}=[];
    zhpoint=[];
    
    st3Cimage{k}=[];
    stu3tsdimage{k}=[];
    
    st2Cimage{k}=[];
    stu2tsdimage{k}=[];
    
    st1Cimage{k}=[];
    stu1tsdimage{k}=[];
else
    [RR,qr] = CalculateRTMatrix(cali(ia1,1:3),p3did(ib1,1:3));
    hanglieshi(1,k)=det(RR);
    zhpoint=cali(:,1:3)*RR+qr;
    zhpoint=[zhpoint,cali(:,4)];
    zhpoints{k}=zhpoint;
    
    [shitu3Cimage,C3,shitu3tsdimage,mzhp3]=yinsheCT(zhpoint,wv_R,wv_T);
    st3Cimage=[st3Cimage;shitu3Cimage];
    stu3tsdimage=[stu3tsdimage;shitu3tsdimage];
    
    [shitu2Cimage,C2,shitu2tsdimage,mzhp2]=yinsheCTAxial(zhpoint,wv_R,wv_T);
    st2Cimage=[st2Cimage;shitu2Cimage];
    stu2tsdimage=[stu2tsdimage;shitu2tsdimage];
    
    [shitu1Cimage,C1,shitu1tsdimage,mzhp1]=yinsheCTCoronal(zhpoint,wv_R,wv_T);
    st1Cimage=[st1Cimage;shitu1Cimage];
    stu1tsdimage=[stu1tsdimage;shitu1tsdimage];
    
end

% [id,ia2,ib2]=intersect(zhpoint(:,4),p3did(:,4)); 
% distance=norm(zhpoint(ia2,1:3)-p3did(ib2,1:3));
distanceErr=[];
for pNum=1:size(p3did)
    id=p3did(pNum,4);
    finedP=find(zhpoint(:,4)==id);
    distance=norm(zhpoint(finedP,1:3)-p3did(pNum,1:3));
    distanceErr=[distanceErr;distance];
end

hold off;
imshow(img);
hold on;
% if isempty(C)
%     pause(0.01);
%     img_full = frame2im(getframe(fig));
%     writeVideo(vid,img_full);
%     continue;
% else

X=[shitu1Cimage(1,1),shitu1tsdimage(1,1)];
Y=[shitu1Cimage(1,2),shitu1tsdimage(1,2)];
plot(X,Y,'Color','g','LineWidth',2);
plot(X(2),Y(2),'+','Color','r','MarkerSize',20);
