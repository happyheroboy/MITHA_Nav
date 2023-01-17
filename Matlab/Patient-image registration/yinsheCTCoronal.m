function [shitu1Cimage,C,shitu1tsdimage,mzhp]=yinsheCTCoronal(zhp,r_x_m,t_x_m)
   if isempty(zhp)
       shitu1Cimage=[];
       C=[];
       shitu1tsdimage=[];
       mzhp=[];
   else
        mzhp=zhp(:,1:3)*r_x_m+t_x_m;
        mzhp=[mzhp,zhp(:,4)];
        [C,r]=niheyuan(mzhp);
        %%%%C（1，1）表示的红色的线，C（2，1）橙色的线，C（3，1）表示绿色的线
        shitu1C=[C(1,1),C(3,1)];
        %shitu1C=[C(1,1),C(2,1)];
        shitu1Cimage=[shitu1C(1,2)*512/379.26,(542.5-shitu1C(1,1))*732/542.5];
        
        shitu1tsd=[mzhp(67,1),mzhp(67,3)];
        shitu1tsdimage=[shitu1tsd(1,2)*512/379.26,(542.5-shitu1tsd(1,1))*732/542.5];
   end
end