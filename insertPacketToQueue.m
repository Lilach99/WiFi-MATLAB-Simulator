function [queue] = insertPacketToQueue(queue, pkt)
    %inserts a packet to a FIFO queue (struct)
    
    if(queue.tail == size(queue.fifo, 2) + 1)
       %we have to increase the queue size!
       queue.fifo = [queue.fifo, cell(1, 100)];
       queue.fifo{queue.tail} = pkt;
       queue.tail = queue.tail + 1;
    else
        % we still have free cells in the queue
        queue.fifo{queue.tail} = pkt;
        queue.tail = queue.tail + 1;
    end
   
end