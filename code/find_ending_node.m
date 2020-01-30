function ending_node = find_ending_node(Branch, substation_node)
    ending_node = [];
    buses12 = Branch(:, [1 2]);
    buses12 = buses12(:);
    buses = unique(buses12);
    for i = 1:length(buses)
        idx = find(buses12==buses(i));
        if (length(idx)==1)
            ending_node = [ending_node; buses(i)];
        end
    end
end