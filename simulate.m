import mlreportgen.dom.*;

% tests: 

%[output]=simulateNet(9, 30, 2, 0, 0, 10);

% for h=1:10
tic
for h=1
  dists = getLinksLenfor4Devs(h); % in KMs
  %dists = h*[0, 10; 10, 0];
  ST = 10^-5+calcSTfromNetAPD(dists, 2);
  disp(['Distance Factor: ', int2str(h)]);
  simulateNet(9e-6, 2, 4, 0, 0, h);
end

toc
