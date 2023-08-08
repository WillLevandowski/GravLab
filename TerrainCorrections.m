function [TC,TCorr]=TerrainCorrections(ShallowDensity,R,x,y,E,ElevationInterpolant)

    TCorr=zeros(length(x),length(R));
    for j=1:length(R)-1
        for i=1:length(x)
        Router=R(j+1);Rinner=R(j);
        ang=(0:10:350)';
        dy=sind(ang)*(2*Router/3+Rinner/3);
        dx=cosd(ang)*(2*Router/3+Rinner/3);
        
        
        
%         [1 sqrt(3)/2 sqrt(2)/2 0.5 0  ...
%             -0.5 -sqrt(2)/2 -sqrt(3)/2 -1 -sqrt(2)/2 ...
%             0 sqrt(2)/2]*(2*Router/3+Rinner/3);
%         dx=[0 0.5 sqrt(2)/2 sqrt(3)/2 1 ...
%             sqrt(3)/2 sqrt(2)/2 0.5 0 -sqrt(2)/2 ...
%             -1 -sqrt(2)/2]*(2*Router/3+Rinner/3);
        E_=ElevationInterpolant(dx+x(i),dy+y(i));
        E_=E_(~isnan(E_));
        dz=mean(abs(E_-E(i)));if isempty(E_);dz=0;end
        TCorr(i,j)=10^5*6.67408e-11*2*pi*ShallowDensity*(Router-Rinner+sqrt(Rinner.^2+dz.^2)-sqrt(Router.^2+dz.^2));
        end
    end
    TC=sum(TCorr,2);
%      for j=1:length(R)-1
%          TCorr(:,j)=TCorr(:,j)-mean(TCorr(:,j));
%      end
         