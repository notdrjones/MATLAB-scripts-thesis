function plotquiversUsingTheta(currBacFrame, ax)


quiver(ax, currBacFrame(2),currBacFrame(3), cos(currBacFrame(4))*5, sin(currBacFrame(4))*5);
axis equal


end