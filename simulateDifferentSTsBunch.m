import mlreportgen.dom.*;

% simulates a bunch of simulations of different STs:
% 6 different values (Standard + 5 APD-based); 10 seconds simulation, 10-100km

% run a bunch of simulations - 30 simulations, 60 seconds each, different
% STs, 10-100 km links, CBR 1460B packets
linkLens = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; % in kms!
simulateDifferentSTsBunchInDataRate(0.1, pktPolicy.CBR, linkLens);
simulateDifferentSTsBunchInDataRate(1, pktPolicy.CBR, linkLens);
simulateDifferentSTsBunchInDataRate(2, pktPolicy.CBR, linkLens);
simulateDifferentSTsBunchInDataRate(3, pktPolicy.CBR, linkLens);
simulateDifferentSTsBunchInDataRate(4, pktPolicy.CBR, linkLens);

% now random sized packets VS the mean packet size:
simulateDifferentSTsBunchInDataRate(1, pktPolicy.RAND, linkLens);
simulateDifferentSTsBunchInDataRate(3, pktPolicy.RAND, linkLens);

% the "limit" distances 100m to 10km (15 values total):
linkLens = [0.1, 0.5, 1, 1.35, 1.5, 2, 2.5, 3, 4, 5, 6, 7, 8, 9, 10];
simulateDifferentSTsBunchInDataRate(1, pktPolicy.CBR, linkLens);
simulateDifferentSTsBunchInDataRate(3, pktPolicy.CBR, linkLens);

% now change "pktLen" in "getPacketLength" function to 1050 (mean) and 
% also change in line 38 in simulateDifferentSTsBunchInDataRate 1460 to 1050 
% and then run:
linkLens = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; % in kms!
simulateDifferentSTsBunchInDataRate(1, pktPolicy.CBR, linkLens);
simulateDifferentSTsBunchInDataRate(3, pktPolicy.CBR, linkLens);

% packet aggregation experiment:
% 1km-3km:
linkLens = [1, 2, 3, 4]; % in kms!
simulateMultOfStandardST(1, pktPolicy.CBR, linkLens, 1); % last parameter is STFactor
% now 10km-30km, cahnge SIFS
linkLens = [10, 20, 30, 40]; % in kms!
simulateMultOfStandardST(1, pktPolicy.CBR, linkLens, 10);


