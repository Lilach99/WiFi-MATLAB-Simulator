function [pkt, queue] = getPktFromQueue(queue)
    %removes the first packet from the queue and returns it together with
    %the updated queue

   pkt = queue.fifo{1}; % the first packet in the queue
   queue.fifo = queue.fifo(2:size(queue.fifo, 2)); % remove the first packet
   queue.tail = queue.tail - 1; % all of the cells are "shifted left"
    
end