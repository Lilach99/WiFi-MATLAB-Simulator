function [linkLens] = getLinksLenfor4Devs(h)
%gets a factor and returns the distances matrix of 4 links network, 2 pTp
%links: 1-2; 3-4 with distance 10*'h', 20km between 1 to 3 and 2 to 4,
%diagonal distance ("Pitagoras") between 3 to 2 and 4 to 1

% KMs
diag = sqrt((20^2+(10*h)^2));
linkLens = [0, 10*h, 20, diag; 10*h, 0, diag, 20; 20, diag, 0, 10*h; diag, 20, 10*h, 0];

% % Ms
% diag = sqrt(((10e-4)*20)^2+((10e-4)*10*h)^2);
% linkLens = [0, (10e-4)*10*h, (10e-4)*20, diag; (10e-4)*10*h, 0, diag, (10e-4)*20; (10e-4)*20, diag, 0, (10e-4)*10*h; diag, (10e-4)*20, (10e-4)*10*h, 0];

end

