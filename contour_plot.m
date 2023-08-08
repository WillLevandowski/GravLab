function contour_plot(xgrid, ygrid, valgrid, ncontour)
   
    
    if nargin<4
        ncontour=100;
    end
    medianval=median(valgrid(~isnan(valgrid)));
    valgrid=valgrid-medianval;
%     cmax=quantile(abs(valgrid(~isnan(valgrid))),0.99);
%     cmax=quantile(abs(valgrid(~isnan(valgrid))),0.99999);
    cmax=quantile(abs(valgrid(~isnan(valgrid))),0.9999);
    valgrid(valgrid>cmax)=cmax;
    valgrid(valgrid<-cmax)=-cmax;
    contours=linspace(-cmax,cmax,ncontour)+medianval;
         figure
         [~,~]=contour(xgrid,ygrid,valgrid+medianval,contours,'fill','on');
         cmax=quantile(abs(valgrid(~isnan(valgrid))),0.99);
% 
%          caxis([medianval-cmax medianval+cmax]);
         hold on
%         colorbar('Position',[0.9 0.05 0.025 0.15])
        dx=max(xgrid(~isnan(xgrid)))-min(xgrid(~isnan(xgrid)));
        dy=max(ygrid(~isnan(ygrid)))-min(ygrid(~isnan(ygrid)));

       ratio=abs(dx/dy);

          set(gcf,'position',[0 0 600*ratio*1.5 600])
        set(gca,'units','normalize','position',[0.04 0.03 0.94 0.95])

         colormap(jet)
%          axis equal
%          colorbar('Position',[0.1 0.05 0.025 0.25],'fontsize',12,'fontweight','bold')
end
