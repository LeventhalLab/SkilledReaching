function color=getColor(number)
    switch number
        case 1
            color = [1 1 0];
        case 2
            color = [1 0 1];
        case 3
            color = [0 1 1];
        case 4
            color = [1 0 0];
        case 5
            color = [0 1 0];
        case 6
            color = [0 0 1];
        case 7
            color = [1 1 1];
        otherwise
            color = [0 0 0]
    end
end