%%  Example script

%%% beginning from drift-corrected gravity measurements "g"
%%% locations (Lon|x,Lat|y), elevation interpolant ElevInterp defined over the x/y region

%%%         x, y, and E in meters. Lon and Lat in decimal degrees
%%%         use deg2utm and utm2deg to coinvert back and forth

BougDens=2670; %%% your choice

E=ElevInterp(x,y);

gn=978031.85*(1+0.005278895*sind(Lat).^2+0.000023462*sind(Lat).^4);
LatCorr=gn-mean(gn);
g=g-LatCorr;
g=g-mean(g);

FACorr=0.3086*E+0.00023*cosd(2*Lat)-0.00000002*E;
FACorr=FACorr-min(FACorr);
gFA=g+FACorr;
gFA=gFA-mean(gFA);

R=[  1:5:21 26:25:101 150:50:500 600:100:1000]; %%% the radii of terrain correction zones
TCkern=TerrainCorrections(1,R,x,y,E,ElevInterp);
TC=TCkern*BougDens;

CFA=gFA+TC;CFA=CFA-mean(CFA);
BougCorr=-0.04193*BougDens/1000.*E;
CBA=CFA+BougCorr;
CBA=CBA-mean(CBA);

res1100=Inv1100(x,y,CBA); % compute residual relative to best-fitting planar regional

% compute residual relative to best-fitting planar regional,
% simulataneously solving for optimal Bouger density
res1101=Inv1101(x,y,E,CBA,'verbose'); 



step=5;
res=scatterGauss(x,y,res,step/2); %%% smooth the station-by-station residuals
[xx,yy]=gridxy(x,y,step);  
yy=flipud(yy);
xi=[x;min(x);max(x);max(x);min(x);];
yi=[y;min(y);min(y);max(y);max(y);];
resi=[res;NaN(4,1)];
Fn=scatteredInterpolant(xi,yi,resi,'natural','none');
F=scatteredInterpolant(x,y,res,'natural','nearest');
rr=F(xx,yy);rr=gridGauss(rr,step/2,step);
rrn=Fn(xx,yy);

%%% convert xx and yy grid points to longitude and latitude
Lons=0*xx;Lats=0*yy;
for i=1:numel(xx)
    [a,b]=utm2deg(xx(i),yy(i),'13 S');
    Lons(i)=b;Lats(i)=a;
end

%%%% low-pass filter with 500-meter Gaussian
lp500=gridGauss(rr,500,step);
hp500=rr-lp500; %% high-pass filter = total - low-pass
hp500(isnan(rrn))=NaN; 


%%%% a convoluted block of plotting functions
h=hp500; h(isnan(h))=0;
hplot1=h;hplot2=hplot1;
c=2*mean(abs(hplot1(~isnan(hplot1))));
hplot2(hplot2>c)=c;hplot2(hplot2<-c)=-c;
hplot1(isnan(h))=NaN;hplot2(isnan(h))=NaN;

figure;s=surf(Lons,Lats,hplot1,hplot2,'FaceLighting','phong','FaceColor','interp', 'AmbientStrength',0.5,'SpecularStrength',0.5,'EdgeColor','k','EdgeAlpha',0.0);
colormap(flipud(hotcoldbreak));
view(0,90)
p=camlight('infinite');
set(gcf,'Menu','none','Toolbar','none','position',[12 38 683 879]);
set(gca,'units','normalize','position',[0 0 1 1],'color','none','TickLength',[0.0;0.0])
caxis([-c c]);
xlim([min(Lons(:)) max(Lons(:))]);
ylim([min(Lats(:)) max(Lats(:))])
 saveas(gcf,'shadeHP500','jpg');
 
 %%%% read back in the figure and then export as a google earth kmz
[img1,~]=imread('shadeHP500.jpg');img=double(img1);
lon=[min(Lons(:)) max(Lons(:)); min(Lons(:)) max(Lons(:))];
lat=[max(Lats(:)) max(Lats(:)); min(Lats(:)) min(Lats(:))];
 makekmz(img,lat,lon,'imname','shade_HP500');
 
