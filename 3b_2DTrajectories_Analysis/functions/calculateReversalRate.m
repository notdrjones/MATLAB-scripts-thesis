function averageReversalRate = calculateReversalRate(track)
% Assumes input of a smoothed track, with at least T X Y

t = track(:,1); x = track(:,2); y = track(:,3);

theta = atan2(diff(y),diff(x)); % This is what direction the flavo is moving at each timestep

T = t(3:end);
omega = abs(diff(theta)); % The difference between direction of motion at T and the same at T-1

% At this point we find where reversals occur
% We consider a reversal the case in which omega > pi/2.

idx = omega>pi/2;

reversalN = nnz(idx);

% -- Also find how far apart reversals are
reversalT = T(idx);

reversalInterval = diff(reversalT);
reversalRate = 1./reversalInterval; % This gives value in Hz

averageReversalRate = mean(reversalRate,'omitnan');
end

