function feeder = find_feeder(feeder_nodes, input_node)

num_feeders = length(feeder_nodes);
feeder = [];
for i = 1:num_feeders    
    if find(feeder_nodes{i}==input_node)
        feeder = i;
        break;
    end
end
end