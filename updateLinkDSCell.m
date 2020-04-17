function [linksDSCell] = updateLinkDSCell(linksDSCell, pkt, eventType)
    %updates a cell from the linksDS due to a simulation event
    %(transmission/reception/collision)
    %   checks the type of the packet and counts the transmitted bytes
    %   according to it 
    switch eventType
        
        case simEventType.TRAN_END
            switch pkt.type
                case packetType.DATA
                    linksDSCell.dataTranCtr = linksDSCell.dataTranCtr + pkt.length;
                case packetType.ACK
                    linksDSCell.ctrlTranCtr = linksDSCell.ctrlTranCtr + pkt.length;
                otherwise
                    % do nothing
            end
            
        case simEventType.REC_END
            switch pkt.type
                case packetType.DATA
                    linksDSCell.dataRecCtr = linksDSCell.dataRecCtr + pkt.length;
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
                    linksDSCell.dataRecCtr = linksDSCell.dataRecCtr - pkt.length;
                case packetType.ACK
                    linksDSCell.ctrlCollCtr = linksDSCell.ctrlCollCtr + pkt.length;
                    linksDSCell.ctrlRecCtr = linksDSCell.ctrlRecCtr - pkt.length;                
                otherwise
                    % do nothing
            end
        otherwise
            % do nothing, we should not reach this line
    end    
end