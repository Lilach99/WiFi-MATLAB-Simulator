function [linkInd] = findLinkInfo(src, dst, linksInfoArr)
    %returns the index of the desired linkInfo in the DS, according to the
    %given source and destination (assume it's a 1t1 mapping)
    
    srcLinks = cell2mat(cellfun(@(l)l.src, linksInfoArr,'uni',0));
    desSrcLinks = (srcLinks == src); % binary rep.
    
    dstLinks = cell2mat(cellfun(@(l)l.dst, linksInfoArr,'uni',0));
    desDstLinks = (dstLinks == dst); % binary rep.
    
    linkInd = find(desSrcLinks & desDstLinks); % this is the desired link index!

end