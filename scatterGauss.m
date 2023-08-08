function gauss_vec=scatterGauss(x,y,vec,sig_r)

gauss_vec=0*x;
for i=1:numel(x)
    d=pt2ptDist_vec(x,y,i);
    weight=exp(-d.^2/(2*sig_r).^2);
    weight=weight/sum(weight);
    gauss_vec(i)=sum(weight.*vec);
end