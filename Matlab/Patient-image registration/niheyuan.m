% IDs=[1,12,23,34,45,56,67,78,89,100,111];
% matchpoint=intersect(XYZpoints(:,4),IDs);
% wqpoints=[];
% for n=1:size(matchpoint,1)
%     wqpoints=[wqpoints;XYZpoints(XYZpoints(:,4)==matchpoint(n),:)];
% end


% p1=wqpoints(1,1:3);p2=wqpoints(6,1:3);p3=wqpoints(11,1:3);p4=wqpoints(11,1:3);
% [center,rad,v1,v2] = circlefit3d(p1,p2,p3);
% plot3(p1(:,1),p1(:,2),p1(:,3),'bo');hold on;plot3(p2(:,1),p2(:,2),p2(:,3),'bo');plot3(p3(:,1),p3(:,2),p3(:,3),'bo');
% for i=1:361
% a = i/180*pi;
% x = center(:,1)+sin(a)*rad.*v1(:,1)+cos(a)*rad.*v2(:,1);
% y = center(:,2)+sin(a)*rad.*v1(:,2)+cos(a)*rad.*v2(:,2);
% z = center(:,3)+sin(a)*rad.*v1(:,3)+cos(a)*rad.*v2(:,3);
% plot3(x,y,z,'r.');
% end
% axis equal;grid on;rotate3d on;

% xxx=[p1(1,1),p2(1,1),p3(1,1)];
% yyy=[p1(1,2),p2(1,2),p3(1,2)];
% zzz=[p1(1,3),p2(1,3),p3(1,3)];
function [C,r]=niheyuan(XYZPOINTS)
wqpoints=[];
for id=1:66
    [m,n]=find(XYZPOINTS(:,4)==id);
    point=XYZPOINTS(m,:);
    wqpoints=[wqpoints;point];
end
M=wqpoints(:,1:3);
[num dim]=size(M);
 
L1=ones(num,1);
A=inv(M'*M)*M'*L1;       % 求解平面法向量
 
B=zeros((num-1)*num/2,3);
 
count=0;
for i=1:num-1
    for j=i+1:num   
        count=count+1;
        B(count,:)=M(j,:)-M(i,:);
    end    
end
 
L2=zeros((num-1)*num/2,1);
count=0;
for i=1:num-1
    for j=i+1:num
        count=count+1;
        L2(count)=(M(j,1)^2+M(j,2)^2+M(j,3)^2-M(i,1)^2-M(i,2)^2-M(i,3)^2)/2;
    end
end
 
D=zeros(4,4);
D(1:3,1:3)=(B'*B);
D(4,1:3)=A';
D(1:3,4)=A;
 
L3=[B'*L2;1];
 
C=inv(D')*(L3);   % 求解空间圆圆心坐标
 
C=C(1:3);
 
radius=0;
for i=1:num
    tmp=M(i,:)-C';
    radius=radius+sqrt(tmp(1)^2+tmp(2)^2+tmp(3)^2);
end
r=radius/num;          %  空间圆拟合半径
 
% % figure;
% % h1=plot3(M(:,1),M(:,2),M(:,3),'*');
%set(gca,'xlim',[11.4 11.7]);
 
 
%%%%   绘制空间圆  %%%%
% % n=A;
% % c=C;
% %  
% % theta=(0:2*pi/100:2*pi)';    %  theta角从0到2*pi
% % a=cross(n,[1 0 0]);          %  n与i叉乘，求取a向量
% % if ~any(a)                   %  如果a为零向量，将n与j叉乘
% %     a=cross(n,[0 1 0]);
% % end
% % b=cross(n,a);      % 求取b向量
% % a=a/norm(a);       % 单位化a向量
% % b=b/norm(b);       % 单位化b向量
% %  
% % c1=c(1)*ones(size(theta,1),1);
% % c2=c(2)*ones(size(theta,1),1);
% % c3=c(3)*ones(size(theta,1),1);
% %  
% % x=c1+r*a(1)*cos(theta)+r*b(1)*sin(theta);  % 圆上各点的x坐标
% % y=c2+r*a(2)*cos(theta)+r*b(2)*sin(theta);  % 圆上各点的y坐标
% % z=c3+r*a(3)*cos(theta)+r*b(3)*sin(theta);  % 圆上各点的z坐标
% %  
% % hold on;
% % h2=plot3(x,y,z,'-r');
% % X1=[XYZPOINTS(78,1),C(1,1)];
% % Y1=[XYZPOINTS(78,2),C(2,1)];
% % Z1=[XYZPOINTS(78,3),C(3,1)];
% % plot3(X1,Y1,Z1,'Color','b','LineWidth',1);
% % xlabel('x轴')
% % ylabel('y轴')
% % zlabel('z轴')
% % legend([h1 h2],'控制点','拟合圆');
% % grid on
end