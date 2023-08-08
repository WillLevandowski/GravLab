function new_res=Inv1100(x,y,res)

xv=x-mean(x);
yv=y-mean(y);
gmat=[xv yv 0*xv+1];
dvec=res;
coeffs=pinv(gmat)*dvec;
pred=gmat*coeffs;
new_res=dvec-pred;