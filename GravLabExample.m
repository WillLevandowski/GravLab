%%  Example script

%%% Inputs
%%%         g: tide- and drift-corrected gravity measurements "g"
%%%         x,y: locations (Lon|x,Lat|y) 
%%%                 use utm2deg to convert UTMx,UTMy to Lon,Lat
%%%                 use deg2utm to convert Lon,Lat to UTMx,UTMy
%%%         ElevInterp elevation interpolant defined over the x/y region

%%%         x, y, and E in meters. Lon and Lat in decimal degrees
%%%         use deg2utm and utm2deg to coinvert back and forth
close all
BougDens=2670; %%% your choice. 
ngridpoints=40000; %%% your choice. 
UTMzone='17 S'; 
E=ElevInterp(x,y); %%% modify script for pre-determined elevations E at each point
    [Lat,Lon]=utm2deg(x,y,repmat(UTMzone,length(x),1));


%% Standard corrections
%% latitude correction
gn=978031.85*(1+0.005278895*sind(Lat).^2+0.000023462*sind(Lat).^4);
LatCorr=gn-mean(gn);
g=g-LatCorr;
g=g-mean(g); % for relative gravity

%% Free Air correction
FACorr=0.3086*E+0.00023*cosd(2*Lat)-0.00000002*E;
FACorr=FACorr-min(FACorr);
gFA=g+FACorr;
gFA=gFA-mean(gFA); % for relative gravity

%% terrain corrections
R=[  0:5:20 25:25:100 150:50:300 400:100:1000]; %%% the radii of terrain correction zones
tic
TCkern=TerrainCorrections(1,R,x,y,E,ElevInterp); %%% "TerrainCorrections.m" is a bit of a hack; consider using something better in mountainous regions
toc
TC=TCkern*BougDens;
CFA=gFA+TC;CFA=CFA-mean(CFA); %%% the rarely used complete free air anomaly

%% Bouguer correction and complete Bouguer anomaly
BougCorr=-0.04193*BougDens/1000.*E;
CBA=CFA+BougCorr;
CBA=CBA-mean(CBA); 

dCBAdE=polyfit(E,CBA,1);dCBAdE=dCBAdE(1);
OptimalBoug_Option1=BougDens - 1000*dCBAdE/0.04193;
disp(['CBA ~ ' num2str(dCBAdE) ' Elevation. Consider changing BougDens to ' num2str(round(OptimalBoug_Option1)) ])


%% Regional fields, works with transects or 2D arrays of stations
%%
res1100=Inv1100(x,y,CBA); % compute residual relative to best-fitting planar regional
dres1100dE=polyfit(E,res1100,1);dres1100dE=dres1100dE(1);
OptimalBoug_Option2=BougDens - 1000*dres1100dE/0.04193;
disp(['Planar residual ~ ' num2str(dres1100dE) ' Elevation. Consider changing BougDens to ' num2str(round(OptimalBoug_Option2)) ])

% compute residual relative to best-fitting planar regional,
% simulataneously solving for optimal Bouger density
res1101=Inv1101(x,y,E,CBA,'verbose'); 
res=Inv1101(x,y,E,CBA,'verbose'); 

%% choose the residual and grid
step=sqrt(range(x)*range(y)/ngridpoints);
res=scatterGauss(x,y,res,step/2); %%% gently smooth the station-by-station residuals 
[xx,yy]=gridxy(x,y,step);  
yy=flipud(yy);
xi=[x;min(x);max(x);max(x);min(x);];
yi=[y;min(y);min(y);max(y);max(y);];
resi=[res;NaN(4,1)];
ResInterp_none=scatteredInterpolant(xi,yi,resi,'natural','none');
ResInterp_nearest=scatteredInterpolant(x,y,res,'natural','nearest');
rr=ResInterp_nearest(xx,yy);rr=gridGauss(rr,step/2,step); %% again, gently smooth residuals
rrn=ResInterp_none(xx,yy);

%%% convert xx and yy grid points to longitude and latitude; change UTM
%%% zone as appropriate
Lons=0*xx;Lats=0*yy;
for i=1:numel(xx)
    [a,b]=utm2deg(xx(i),yy(i),UTMzone);
    Lons(i)=b;Lats(i)=a;
end


%% simple spatial domain filter example
%%%% low-pass filter with 500-meter Gaussian
lp500=gridGauss(rr,500,step);
hp500=rr-lp500; %% high-pass filter = total - low-pass
hp500(isnan(rrn))=NaN; 


%%%% a block of functions to plot and make google earth kmzs
h=hp500; h(isnan(h))=0;
hplot1=h;hplot2=hplot1;
c=quantile(abs(hplot1(~isnan(hplot1))),0.975);
hplot2(hplot2>c)=c;hplot2(hplot2<-c)=-c;
hplot1(isnan(h))=NaN;hplot2(isnan(h))=NaN;

figure;s=surf(Lons,Lats,hplot1,hplot2,'FaceLighting','phong','FaceColor','interp', 'AmbientStrength',0.5,'SpecularStrength',0.5,'EdgeColor','k','EdgeAlpha',0.0);
colormap(flipud(hotcoldbreak));
view(0,90)
p=camlight('infinite');
set(gcf,'Menu','none','Toolbar','none','position',[12 38 1000 1000*range(y)/range(x)]);
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
 
 %% simple spatial horizontal gradients
 dgdx=gradient(rrn,step);
 dgdy=gradient(rrn',step)';
 thg=sqrt(dgdx.^2+dgdy.^2);
 laplacian=del2(rrn,step); 
  contour_plot(Lons,Lats,rrn);plot(Lon,Lat,'ko');title('Residual')
contour_plot(Lons,Lats,thg);plot(Lon,Lat,'ko');title('Horizontal gradient of residual')
%  contour_plot(Lons,Lats,laplacian);plot(Lon,Lat,'ko');title('Laplacian of residual')
 
