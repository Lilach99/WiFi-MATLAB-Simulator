function [linksDSCell] = updateLinkDSCell(devState, linksDSCell, pkt, eventType)
    %updates a cell from the linksDS due to a simulation event
    %(transmission/reception/collision)
    %   checks the type of the packet and counts the transmitted bytes
    %   according to it 
    switch eventType
        
        case simEventType.TRAN_END
            switch pkt.type
                case packetType.DATA
                    linksDSCell.dataTranBruto = linksDSCell.dataTranBruto + pkt.length;
                    if(devState.curRet == 0)
                        % it's the first transmission of this packet, so
                        % count it in the neto counter
                        linksDSCell.dataTranNeto = linksDSCell.dataTranNeto + pkt.length;
                        linksDSCell.packetsCnt = linksDSCell.packetsCnt + 1;
                    end
                case packetType.ACK
                    linksDSCell.ctrlTranCtr = linksDSCell.ctrlTranCtr + pkt.length;
                otherwise
                    % do nothing
            end
            
        case simEventType.REC_END
            switch pkt.type
                case packetType.DATA
                    linksDSCell.dataRecBruto = linksDSCell.dataRecBruto + pkt.length;
%                     if(isNewPakcet(pkt, devState) == 1)
%                         % this is the first time we receive the packet
%                     end
                case packetType.ACK
                    linksDSCell.ctrlRecCtr = linksDSCell.ctrlRecCtr + pkt.length;
                otherwise
                    % do nothing
            end
            
            case simEventType.COLL_INC
            % it has been collided rather than received successfully!
            switch pkt.type
                case packetType.DATA
                    linksDSCell.dataCollCtr = linksDSCell.dataCollCtr + pkt.length;
                    linksDSCell.dataRecBruto = linksDSCell.dataRecBruto - pkt.length;
                case packetType.ACK
                    linksDSCell.ctrlCollCtr = linksDSCell.ctrlCollCtr + pkt.length;
                    linksDSCell.ctrlRecBruto = linksDSCell.ctrlRecCtr - pkt.length;                
                otherwise
                    % do nothing
            end
        otherwise
            % do nothing, we should not reach this line
    end    
end