import mlreportgen.dom.*;

% simulates a bunch of simulations of different STs:
% 6 different values (Standard + 5 APD-based); 10 seconds simulation, 10-100km

% run a bunch of simulations - 30 simulations, 60 seconds each, different
% STs, 10-100 km links, CBR 1460B packets
simulateDifferentSTsBunchInDataRate(0.1, pktPolicy.CBR);
simulateDifferentSTsBunchInDataRate(1, pktPolicy.CBR);
simulateDifferentSTsBunchInDataRate(2, pktPolicy.CBR);
simulateDifferentSTsBunchInDataRate(3, pktPolicy.CBR);
simulateDifferentSTsBunchInDataRate(4, pktPolicy.CBR);

% now random sized packets VS the mean packet size:
simulateDifferentSTsBunchInDataRate(0.1, pktPolicy.RAND);
simulateDifferentSTsBunchInDataRate(1, pktPolicy.RAND);
simulateDifferentSTsBunchInDataRate(2, pktPolicy.RAND);
simulateDifferentSTsBunchInDataRate(3, pktPolicy.RAND);
simulateDifferentSTsBunchInDataRate(4, pktPolicy.RAND);

% now change "pktLen" in "getPacketLength" function to 1050 (mean) and 
% also change in line 38 in simulateDifferentSTsBunchInDataRate 1460 to 1050 
% and then run:
simulateDifferentSTsBunchInDataRate(0.1, pktPolicy.CBR);
simulateDifferentSTsBunchInDataRate(1, pktPolicy.CBR);
simulateDifferentSTsBunchInDataRate(2, pktPolicy.CBR);
simulateDifferentSTsBunchInDataRate(3, pktPolicy.CBR);
simulateDifferentSTsBunchInDataRate(4, pktPolicy.CBR);









