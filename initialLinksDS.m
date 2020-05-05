function [linksDS] = initialLinksDS(numLinks, linksInfo)
    %creates an initial linksDS cell array
    %   its size is 1*numLinks, each cell contains a linkRes struct:
    %   linkInfo struct;
    %   number of transmitted bytes of the source (control and data seperately);
    %   number of received bytes of the destination (control and data seperately);
    %   number of collisioned bytes (control and data seperately)
    
    linksDS = cell(1, numLinks);
    for l=1:numLinks
        linksDS{l}.linkInfo = linksInfo{l};
        linksDS{l}.dataTranNeto = 0;
        linksDS{l}.dataTranBruto = 0;
        linksDS{l}.dataRecNeto = 0;
        linksDS{l}.dataRecBruto = 0;
        linksDS{l}.dataCollCtr = 0;
        linksDS{l}.ctrlTranCtr = 0;
        linksDS{l}.ctrlRecCtr = 0;
        linksDS{l}.ctrlCollCtr = 0;    
        linksDS{l}.packetsCnt = 0;
        linksDS{l}.generatedPktCnt = 0;
        linksDS{l}.recPktsInds = [];
    end
    
end