function new_res=Inv1110(x,y,res)

xv=x-mean(x);
yv=y-mean(y);
xy=xv.*yv;
gmat=[xv yv xy 0*xv+1];
dvec=res;
coeffs=pinv(gmat)*dvec;
pred=gmat*coeffs;
new_res=dvec-pred;