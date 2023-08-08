function new_res=Inv2210(x,y,res,output)

xv=x-mean(x);
yv=y-mean(y);
gmat=[xv xv.^2 yv yv.^2 xv.*yv  0*xv+1];
dvec=res;
coeffs=pinv(gmat)*dvec;
pred=gmat*coeffs;
new_res=dvec-pred;


if nargin>4 && (strcmp(output,'verbose') || (output>0 && length(output)==1 && ~strcmp(output,'n')))
drho=1000*coeffs(3)/0.04193;
disp(['Density change = ' num2str(round(drho))])
end