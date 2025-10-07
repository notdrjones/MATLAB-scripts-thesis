function [xrot,yrot] = rotatePoints2(x, y, angle, xC, yC)

xTransl = x - xC;        
yTransl = y - yC;

[theta,rho] = cart2pol(xTransl,yTransl);
theta = theta + angle;
[xRot,yRot] = pol2cart(theta,rho);

xrot = xRot + xC;
yrot = yRot + yC;

end