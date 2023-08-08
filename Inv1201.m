function new_res=Inv1201(x,y,E,res,output)
E=E-min(E);
xv=x-mean(x);
yv=y-mean(y);
gmat=[xv  yv yv.^2 E 0*xv+1];
dvec=res;
coeffs=pinv(gmat)*dvec;
pred=gmat*coeffs;
new_res=dvec-pred;

if nargin>4 && strcmp(output,'verbose')
drho=1000*coeffs(end-1)/0.04193;
disp(['Density change = ' num2str(round(drho))])
end
    