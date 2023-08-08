function [xx,yy]=gridxy(x,y,spacing)
xx=min(x)-spacing/2:spacing:max(x)+spacing/2;
yy=min(y)-spacing/2:spacing:max(y)+spacing/2;
[xx,yy]=meshgrid(xx,yy);