import mlreportgen.dom.*;

% tests: 

%[output]=simulateNet(9, 30, 2, 0, 0, 10);

for h=1:10
  dists = h*[0, 10; 10, 0];
  ST = 10^-5+calcSTfromNetAPD(dists, 2);
  simulateNet(ST, 30, 2, 0, 0, h);
end



