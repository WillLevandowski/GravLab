function new_res=Inv1200(x,y,res)
xv=x-mean(x);
yv=y-mean(y);
gmat=[xv  yv yv.^2  0*xv+1];
dvec=res;
coeffs=pinv(gmat)*dvec;
pred=gmat*coeffs;
new_res=dvec-pred;


    