import mlreportgen.dom.*;

% p = gcp('nocreate');
% if (isempty(p))
%     parpool(4);
% end

% tests: 

%[output]=simulateNet(9, 30, 2, 0, 0, 10);
simTime = 5;
numDevs = 4;
linkLens = [10, 20, 30];%, 40, 50, 60, 70, 80, 90, 100]; % in kms!
% for example, we will always display the metrics of link 1:
link1InfoStandardST = cell(3, 1);
link1InfoAPDST = cell(3, 1);

link2InfoStandardST = cell(3, 1);
link2InfoAPDST = cell(3, 1);

link3InfoStandardST = cell(3, 1);
link3InfoAPDST = cell(3, 1);

link4InfoStandardST = cell(3, 1);
link4InfoAPDST = cell(3, 1);

 for h=1:3
%tic
%parfor h=1:10
  dists = getLinksLenfor4Devs(h); % in KMs
  %dists = h*[0, 10; 10, 0];
  %dists = getLinksLenfor6Devs(h); % in KMs
  ST = 10^-5+calcSTfromNetAPD(dists, 2);
  disp(['Length of tested link: ', int2str(10*h)]);
  
  output = simulateNet(9*10^-6, simTime, numDevs, 0, 1, h, 1, 'Standard'); % the last parameter is dataRate in Mbps!
  link1InfoStandardST{h} = output.linksRes{1};
  link2InfoStandardST{h} = output.linksRes{2};
  link3InfoStandardST{h} = output.linksRes{3};
  link4InfoStandardST{h} = output.linksRes{4};

  output = simulateNet(ST, simTime, numDevs, 0, 1, h, 1, '2APD');
  link1InfoAPDST{h} = output.linksRes{1};
  link2InfoAPDST{h} = output.linksRes{2};
  link3InfoAPDST{h} = output.linksRes{3};
  link4InfoAPDST{h} = output.linksRes{4};
  
end

plotLinkMetrics(link1InfoStandardST, link1InfoAPDST, linkLens, simTime, 1);
plotLinkMetrics(link2InfoStandardST, link2InfoAPDST, linkLens, simTime, 2);
plotLinkMetrics(link3InfoStandardST, link3InfoAPDST, linkLens, simTime, 3);
plotLinkMetrics(link4InfoStandardST, link4InfoAPDST, linkLens, simTime, 4);


%toc