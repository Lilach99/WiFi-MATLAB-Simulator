function [queue] = createQueue(size)
    %creates an struct, queue, which contains:
    % array which will be maitained in FIFO order
    % index of next empty cell
    
    queue.tail = 1;
    queue.fifo = cell(1, size);
    
end