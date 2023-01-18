function [R,t] = CalculateRTMatrix(P,X)
    %����㼯��ֵ
    centroidp = mean(P);
    centroidx = mean(X);

    %ȥ���Ļ�/ȥ���Ļ�
    p1=bsxfun(@minus,P,centroidp);
    x1=bsxfun(@minus,X,centroidx);

    %����㼯Э����
    H=p1'*x1;

    [u ,~ ,v] = svd(H);
    R=u*v';
    if det(R)<0
        v = [1,1,-1;1,1,-1;1,1,-1].*v;
%         v=[v(:,1:2) v(:,3)*-1];
        R=u*v';
    end    

    %����ƽ������
    t=centroidx-centroidp*R;
end

