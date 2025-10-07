function plotquiversfromTheta(currBacFrame, ax)

% vecmag = sqrt(currBacFrame(4)^2 + currBacFrame(5)^2);

quiver(ax, currBacFrame(1),currBacFrame(2), currBacFrame(3), currBacFrame(4), '-.b');
axis equal


end