function out = inverttheta(inp, col)

out = inp;
out(:,col) = -inp(:,col);

end