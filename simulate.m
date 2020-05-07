import mlreportgen.dom.*;

p = gcp('nocreate');
if (isempty(p))
    parpool(4);
end

% tests: 

%[output]=simulateNet(9, 30, 2, 0, 0, 10);
simTime = 5;
numLinks = 4;
linkLens = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; % in kms!
% for example, we will always display the metrics of link 1:
link1InfoStandardST = cell(10, 1);
link1InfoAPDST = cell(10, 1);

% for h=1:10
tic
parfor h=1:10
  dists = getLinksLenfor4Devs(h); % in KMs
  %dists = h*[0, 10; 10, 0];
  ST = 10^-5+calcSTfromNetAPD(dists, 2);
  disp(['Distance Factor: ', int2str(h)]);
  output = simulateNet(9*10^-6, simTime, numLinks, 0, 0, h);
  link1InfoStandardST{h} = output.linksRes{1};
  output = simulateNet(ST, simTime, numLinks, 0, 0, h);
  link1InfoAPDST{h} = output.linksRes{1};
end

plotLinkMetrics(link1InfoStandardST, link1InfoAPDST, linkLens, simTime);

toc