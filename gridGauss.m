function g_model=gridGauss(gm,sig_r,step)
% 
% for i=1
% gm(:,i)=gm(:,i)*0;
% gm(i,:)=gm(i,:)*0;
% gm(:,end-1+1)=gm(:,end-i+1)*0;
% gm(end-i+1,:)=gm(end-i+1,:)*0;
% end


nwin=10*sig_r/step+10;
dr=[fliplr(0:nwin) 1:nwin]*step;
v=exp(-dr.^2 / (2*sig_r).^2);
vv=v'*v;
nv=vv/sum(vv(:));

g_model=conv2(gm,nv,'same');
% g_model(:,1)=g_model(:,1)*0;
% g_model(:,end)=g_model(:,end)*0;
% g_model(1,:)=g_model(1,:)*0;
% g_model(end,:)=g_model(end,:)*0;
% 
% g_model(:,2)=g_model(:,2)*0;
% g_model(:,end-1)=g_model(:,end-1)*0;
% g_model(2,:)=g_model(2,:)*0;
% g_model(end-1,:)=g_model(end-1,:)*0;

% 
% 
% for j=1:length(gm(1,:))
%     for i=1:length(gm(:,1))
%    
%         corner1=i-nwin; %%% if corner1 =-2, there need to be 3 rows of NaN on top
%         corner2=i+nwin;
%         corner3=j-nwin;
%         corner4=j+nwin;
%         n_NaNrows_top=0;
%         n_NaNrows_bot=0;
%         n_NaNcols_left=0;
%         n_NaNcols_right=0;
%         if corner1<1
%             n_NaNrows_top=-corner1+1;
%             corner1=1;
%         end
%         
%         if corner2>length(gm(:,1))
%             n_NaNrows_bot=corner2-length(gm(:,1));
%             corner2=length(gm(:,1));
%         end
%         if corner3<1
%             n_NaNcols_left=-corner3+1;
%             corner3=1;
%         end
%         
%         if corner4>length(gm(1,:))
%             n_NaNcols_right=corner4-length(gm(1,:));
%             corner4=length(gm(1,:));
%         end
%         
%         n=gm(corner1:corner2,corner3:corner4);
%         len=length(n(1,:));
%         n=[NaN(n_NaNrows_top,len);n];
%         n=[n;NaN(n_NaNrows_bot,len)];
% 
%         
%         len=length(n(:,1));
%         n=[NaN(len,n_NaNcols_left) n];
%         len=length(n(:,1));
%         n=[n NaN(len,n_NaNcols_right) ];
%  
%         n=mat2vec(n);
%         a1=nv(~isnan(n));
%         n1=n(~isnan(n));
%         g_model(i,j)=dot(n1,a1)/sum(a1);
%         if isempty(n1) %|| isnan(gm(i,j))
%             g_model(i,j)=NaN;
%         end
%     end
% end
% 
% % 
% for j=1:length(gm(1,:))
%     for i=1:length(gm(:,1))
%         
%         corner1=i-nwin;if corner1<1;corner1=1;end
%         corner2=i+nwin;if corner2>length(gm(:,1));corner2=length(gm(:,1));end
%         corner3=j-nwin;if corner3<1;corner3=1;end
%         corner4=j+nwin;if corner4>length(gm(1,:));corner4=length(gm(1,:));end
%         
%         n_nodes=(corner2-corner1+1)*(corner4-corner3+1);
% 
%         n=reshape(gm(corner1:corner2,corner3:corner4),n_nodes,1);
%         a1=a(~isnan(n));
%         n1=n(~isnan(n));
%         g_model(i,j)=dot(n1,a1)/sum(a1);
%         if isempty(n1) %|| isnan(gm(i,j))
%             g_model(i,j)=NaN;
%         end
%     end
% end
