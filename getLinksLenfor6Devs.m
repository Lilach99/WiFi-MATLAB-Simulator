function [linkLens] = getLinksLenfor6Devs(h)
%gets a factor and returns the distances matrix of 6 links network, 3 pTp
%links: 1-2; 3-4; 5-6 with distance 10*'h', 20km between 1 to 3, 2 to 4, 
%3 to 5 and 4 to 6
%diagonal distance ("Pitagoras") between 3 to 2 and 4 to 1;
%longer diagonal between 1 to 6 and 2 to 5

diag1 = sqrt(20^2+(10*h)^2);
diag2 = sqrt(40^2+(10*h)^2);
linkLens = [0, 10*h, 20, diag1, 40, diag2;
            10*h, 0, diag1, 20, diag2, 40; 
            20, diag1, 0, 10*h, 20, diag1;
            diag1, 20, 10*h, 0, diag1, 20;
            40, diag2, 20, diag1, 0, 10*h;
            diag2, 40, diag1, 20, 10*h, 0];

end

