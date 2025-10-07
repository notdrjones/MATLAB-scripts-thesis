function straightenCell(medialAx)
%STRAIGHTENCELL Summary of this function goes here
%   Detailed explanation goes here

%%
indexCentre = find(medialAx(:,1) == 0 & medialAx(:,2) == 0);

%%
clf

N = 40;
n = N-1;
iSeg =  flip(floor(linspace(1,indexCentre,N)));
%medialAx(:,1) = smooth(medialAx(:,1));
%medialAx(:,2) = smooth(medialAx(:,2));
hold on

C = jet(n);
prevx = 0; prevy = 0; % for the first segment, the prevx and prevy are always [0 0]
for i=1:n
    currSeg = [medialAx(iSeg(i+1):iSeg(i),1) medialAx(iSeg(i+1):iSeg(i),2)];
    
    % translate currSeg to be at the end of previous segment
    currSeg = currSeg - abs([prevx-currSeg(end,1) prevy-currSeg(end,2)]);
    

    % find what the orientation of currSeg is
    linFitSeg = fit(currSeg(:,1), currSeg(:,2), 'poly1');

    % now rotate currSeg relative to prevx and prevy
    [xR, yR] = rotatePoints(currSeg(:,1),currSeg(:,2),-atan(linFitSeg.p1),prevx,prevy);



    hold on
    plot(medialAx(iSeg(i+1):iSeg(i),1),medialAx(iSeg(i+1):iSeg(i),2),'Color',C(i,:),'LineWidth',2);
    plot(xR,yR,'Color',C(i,:),'LineWidth',2);

    prevx = xR(1);
    prevy = yR(1);
end

%-- now do the same for front side of segment
N = 10;
n = N-1;
iSeg =  (floor(linspace(indexCentre,length(medialAx),N)));
%medialAx(:,1) = smooth(medialAx(:,1));
%medialAx(:,2) = smooth(medialAx(:,2));
hold on

C = jet(n);
prevx = 0; prevy = 0; % for the first segment, the prevx and prevy are always [0 0]
for i=1:n
    currSeg = [medialAx(iSeg(i):iSeg(i+1),1) medialAx(iSeg(i):iSeg(i+1),2)];
    plot(currSeg(:,1), currSeg(:,2),'Color',C(i,:),'LineWidth',2);

    % translate currSeg to be at the end of previous segment
    currSeg = currSeg + ([prevx-currSeg(1,1) prevy-currSeg(1,2)]);
    

    % find what the orientation of currSeg is
    linFitSeg = fit(currSeg(:,1), currSeg(:,2), 'poly1');

    % now rotate currSeg relative to prevx and prevy
    [xR, yR] = rotatePoints(currSeg(:,1),currSeg(:,2),-atan(linFitSeg.p1),prevx,prevy);



    hold on
    plot(medialAx(iSeg(i+1):iSeg(i),1),medialAx(iSeg(i+1):iSeg(i),2),'Color',C(i,:),'LineWidth',2);
    plot(xR,yR,'Color',C(i,:),'LineWidth',2);

    prevx = xR(end);
    prevy = yR(end);
end


end

