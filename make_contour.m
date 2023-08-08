function [c,h]=make_contour(X,Y,val,spacing,max_spacing)


        Xdim=max(X)-min(X);
        Ydim=max(Y)-min(Y);
        area=Xdim*Ydim;
        
         if nargin == 3
            point_area=area/1e5;
            spacing=sqrt(point_area);
        end
        
        
        point_area=spacing^2;
        npts=area/point_area;
        if npts>1e6
                warning('Too many points! \n')

            point_area=area/5e5;
            newspacing=sqrt(point_area);
            warning([ num2str(spacing) ' m spacing too fine. Changing to ' num2str(newspacing) ' m '])
            disp([ num2str(spacing) ' m spacing too fine. Changing to ' num2str(newspacing) ' m '])
            spacing=newspacing;
        end
        

        if nargin<5;max_spacing=10*spacing;end
        XGrid=min(X)-spacing/2:spacing:max(X)+spacing/2;
        YGrid=min(Y)-spacing/2:spacing:max(Y)+spacing/2;
        [XGrid,YGrid]=meshgrid(XGrid,YGrid);
        ncontour=ceil(sqrt(length(X))*5)+10;
        
        
        n=100;
        topNaN=[linspace(min(X),max(X),n)' max(Y)*ones(n,1)+range(Y)/5 NaN(n,1)];
        botNaN=[linspace(min(X),max(X),n)' min(Y)*ones(n,1)-range(Y)/5 NaN(n,1)];
        eastNaN=[max(X)*ones(n,1)+range(X)/5 linspace(min(Y),max(Y),n)'  NaN(n,1)];
        westNaN=[min(X)*ones(n,1)-range(X)/5 linspace(min(Y),max(Y),n)' NaN(n,1)];
        
        XYZ=[X Y val;topNaN;botNaN;eastNaN;westNaN];
        
        F=scatteredInterpolant(XYZ(:,1),XYZ(:,2),XYZ(:,3),'natural','none');
        valGrid=F(XGrid,YGrid);
   

      
        
%         linspace( min(valGrid(~isnan(valGrid))), max(valGrid(~isnan(valGrid))), ncontour);
%         min(min(valGrid)),max(max(valGrid)),ncontour);

        for i=1:numel(valGrid)
             d=sqrt( (XGrid(i)-X).^2 + (YGrid(i)-Y).^2);
            if min(d)>max_spacing
%             weights=exp(- d.^2/(2*(2)).^2);
% % %             weights=exp(- d.^2/(2*(1.82*minAnomDepth+4.35)).^2);
%             weights=weights/sum(weights);
%             valGrid(i)=dot(weights,val);
%             else
% %             f=find( abs(XGrid(i)-X)<max_spacing & abs(YGrid(i)-Y)<max_spacing, 1 );
%             if isempty(f)
                valGrid(i)=NaN;
            end
            
%             if isnan(valGrid(i))
%                 pause
%             end
        end
        
         v=val(~isnan(val));
        mv=median(v);
        dv=v-mv;
        
        cmax=quantile(abs(dv),0.95);
        cmaxmax=quantile(abs(dv),0.999);lowcontour=mv-cmaxmax;highcontour=mv+cmaxmax;
        cmin=mv-cmax;
        cmax=mv+cmax;
        if cmin==cmax
            cmin=min(val(~isnan(val)));
            cmax=max(val(~isnan(val)));
        end
        if cmin==cmax
            cmin=cmax-1e-3;
        end
                contours=linspace(lowcontour,highcontour,ncontour)';
                
%                 min(val(~isnan(val))),max(val(~isnan(val))),ncontour);
        valGrid(valGrid>contours(end))=contours(end);
        valGrid(valGrid<contours(1))=contours(1);
        figure;
        [c,h]=contour(XGrid,YGrid,valGrid,	contours,'fill','on');
        
        colormap(jet);
        
        axis equal;axis tight
        xlim([min(X) max(X)])
        ylim([min(Y) max(Y)])
        hold on;
         ratio=(max(X)-min(X))/(max(Y)-min(Y));
        set(gcf,'position',[0 0 600*ratio*1.1 600])
        
        axl=0.04;
        ayb=0.03;
        axr=0.94;
        ayt=0.95;
        set(gca,'units','normalize','position',[axl ayb axr ayt])
       colorbar('position',[1.01 0.03 0.02 0.95])
%         caxis([quantile(v,0.01) quantile(v,0.99)])
        caxis( [cmin cmax]);
        colorbar%('Position',[0.1 0.5 0.025 0.4],'fontsize',12)
        ay=ylim;
        ax=xlim;
        
        xll=0.9;xw=0.01;
        dx_proportion=(xll+xw-1.82*axl)/(axr-axl);
        xp=dx_proportion*(ax(2)-ax(1))+ax(1);
        
   
        yll=0.05;        yw=0.4;

        dy_proportion=(yll-1.5*ayb)/(ayt-ayb);
        yp1=dy_proportion*(ay(2)-ay(1))+ay(1);
        dy_proportion=(yll+yw-1.93*ayb)/(ayt-ayb);
        yp2=dy_proportion*(ay(2)-ay(1))+ay(1);
        
        
        
        
        
% 
%         yb=ay(1)+(yll+ayb)*(ay(2)-ay(1));
%         yt=ay(1)+(yll+yw+ayb)*(ay(2)-ay(1));
%         xl=ax(1)+(xll-axl)*(ax(2)-ax(1));
        
        
%         c=colorbar('position',[xll yll xw yw],'FontSize',16,'fontweight','bold');
        counts=0*contours;
        for i=1:length(counts)-1
            counts(i)=length(find(val>contours(i) & val<=contours(i+1)));
        end
        nsmooth=round(sqrt(ncontour)/2);
        if mod(nsmooth,2)==0;nsmooth=nsmooth-1;end
        counts=smooth(counts,nsmooth);
%         counts=counts/sum(counts);
        ypos=linspace(yp1,yp2,ncontour)';
        xpos=xp+(ax(2)-ax(1))*counts/length(X);

        
        
        
        
        %%%%%% uncomment to display histogram
        %         plot(xpos,ypos,'k','linewidth',2);
        
%         c.Label.String='mGal';
%         c.Label.Position=[0.5 1.03*cmax 0];
%         c.Label.Rotation=0;c.Label.FontSize=18;
%         c.Label.FontWeight='Bold';

      
%      [~,~]=contour(XGrid,YGrid,valGrid,[ median( valGrid(~isnan(valGrid))) median( valGrid(~isnan(valGrid)))],  'fill','off' ,'color',[0.5 0.5 0.5]);
end