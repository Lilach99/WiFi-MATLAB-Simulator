import mlreportgen.dom.*;

% p = gcp('nocreate');
% if (isempty(p))
%     parpool(4);
% end

% tests: 

%[output]=simulateNet(9, 30, 2, 0, 0, 10);
simTime = 5;
numDevs = 4;
numDists = 10;
linkLens = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; % in kms!

% DSs for future display of the metrics of the links:
link1InfoStandardST = cell(numDists, 1);
link1InfoAPDST = cell(numDists, 1);
link2InfoStandardST = cell(numDists, 1);
link2InfoAPDST = cell(numDists, 1);
link3InfoStandardST = cell(numDists, 1);
link3InfoAPDST = cell(numDists, 1);
link4InfoStandardST = cell(numDists, 1);
link4InfoAPDST = cell(numDists, 1);
% make directories to save the results:
t = datetime('now');
t = datestr(t);
t = strrep(t,':','-');
experimentResultsPath = ['Results\Experiment_METERS_', int2str(numDevs/2), '_pTp_Links_', int2str(simTime), '_secondes_simulation_', t];
mkdir(experimentResultsPath); % for this experiment
standardSTPath = [experimentResultsPath, '\Standard_ST'];
mkdir(standardSTPath); % standard ST
APDSTPath = [experimentResultsPath, '\2APD_ST'];
mkdir(APDSTPath); % 2APD ST
% output arrays
outputStandard = cell(numDists, 1);
output2APD = cell(numDists, 1);

for h=1:numDists
%tic
%parfor h=1:numDists
  dists = getLinksLenfor4Devs(h); % in KMs
  %dists = (10e-4)*h*[0, 10; 10, 0]; % now it will be 10, 20, 30, ... METERS!
  %dists = getLinksLenfor6Devs(h); % in KMs
  ST = 10^-5+calcSTfromNetAPD(dists, 2);
  disp(['Length of tested link: ', int2str(10*h)]);
  disp('Standard');
  % Standard ST experiment
  resPath = [standardSTPath, '\Length_', int2str(10*h)];
  mkdir(resPath);
  outputStandard{h} = simulateNet(9*10^-6, simTime, numDevs, 0, 0, h, 1, resPath); % the last parameter is dataRate in Mbps!
  link1InfoStandardST{h} = outputStandard{h}.linksRes{1};
  link2InfoStandardST{h} = outputStandard{h}.linksRes{2};
  link3InfoStandardST{h} = outputStandard{h}.linksRes{3};
  link4InfoStandardST{h} = outputStandard{h}.linksRes{4};

  disp('2APD');
  resPath = [APDSTPath, '\Length_', int2str(10*h)];
  mkdir(resPath);
  output2APD{h} = simulateNet(ST, simTime, numDevs, 0, 0, h, 1, resPath);
  link1InfoAPDST{h} = output2APD{h}.linksRes{1};
  link2InfoAPDST{h} = output2APD{h}.linksRes{2};
  link3InfoAPDST{h} = output2APD{h}.linksRes{3};
  link4InfoAPDST{h} = output2APD{h}.linksRes{4};
  
end
%toc

linkInfoStandardST{1} = link1InfoStandardST;
linkInfoStandardST{2} = link2InfoStandardST;
linkInfoStandardST{3} = link3InfoStandardST;
linkInfoStandardST{4} = link4InfoStandardST;

linkInfoAPDST{1} = link1InfoAPDST;
linkInfoAPDST{2} = link2InfoAPDST;
linkInfoAPDST{3} = link3InfoAPDST;
linkInfoAPDST{4} = link4InfoAPDST;
 
%tic
for h=1:numDevs
    resultsPath = [experimentResultsPath, '\Link_', int2str(h)];
    mkdir(resultsPath);
    plotLinkMetrics(linkInfoStandardST{h}, linkInfoAPDST{h}, linkLens, simTime, resultsPath);
end
%toc

save([experimentResultsPath, '\output.mat']);

