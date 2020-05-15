function [] = displayDevsMap(numDevs, dists)
%plots the devices positions in a (x,y) plane - a network map

    switch numDevs

        case 2
            X = [0, dists(1, 2)];
            Y = [1, 1];
            textCell = {'Device 1', 'Device 2'}; %arrayfun(@(x,y) sprintf('(%3.2f, %3.2f)', x, y), X, Y, 'un', 0);

        case 4
            X = [0, 0, dists(1, 3), dists(2, 4)];
            Y = [0, dists(1, 2), 0, dists(3, 4)];
            textCell = {'Device 1', 'Device 2', 'Device 3', 'Device 4'};

        case 6
            X = [0, 0, dists(1, 3), dists(2, 4), dists(1, 5), dists(2, 6)];
            Y = [0, dists(1, 2), 0, dists(3, 4), 0, dists(5, 6)];
            textCell = {'Device 1', 'Device 2', 'Device 3', 'Device 4', 'Device 5', 'Device 6'};
            
        otherwise
            fprintf('Number of devices can be 2, 4 or 6 only!');

    end
    
    scatter(X, Y, 'filled');
    for i=1:numDevs
        text(X(i)+.02, Y(i)+.02, textCell{i}, 'FontSize', 8);
    end
    title("Network Map (kms)");

end

