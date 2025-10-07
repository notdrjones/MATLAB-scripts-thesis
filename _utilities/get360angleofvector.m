function [angle] = get360angleofvector(x1, x2, y1, y2)

angle = atan((x2-x1)/(y2-y1));
if (x2-x1) < 0
    angle = pi + angle;
else
    if (y2-y1)<0
        angle = 2*pi + angle;
    end
end
angle = rad2deg(angle);

end