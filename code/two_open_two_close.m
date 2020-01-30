function [record_o2c2_loss_dec, loss_after_switch_combine_two_o2c2, Branch_loss] = ...
    two_open_two_close(nodes_focused, Bus, Branch0, Branch, from_to, ...
    substation_node, n_bus, loss_before_switch0)
%% two open and two close
record_o2c2 = [];
cnt = 0; Branch_o2c2 = []; loss_o2c2 = [];
for i = 1:length(nodes_focused)
    for j = 1:length(nodes_focused)
        fprintf('i=%d/%d, j=%d/%d\n', i,length(nodes_focused), j, length(nodes_focused));
        if i~=j
            input_node = nodes_focused(i);
            [current_connection_i, other_possible_connections_i] = ...
                find_all_switch(Branch0, Branch, from_to, input_node);
            input_node = nodes_focused(j);
            [current_connection_j, other_possible_connections_j] = ...
                find_all_switch(Branch0, Branch, from_to, input_node);
            
            open_connection = [ current_connection_i(1,:); 
                                current_connection_j(1,:); ];
            li = size(other_possible_connections_i,1);
            lj = size(other_possible_connections_j,1);
            for ki = 1:li
                for kj = 1:lj
                    close_connection = [ other_possible_connections_i(ki,:); 
                                         other_possible_connections_j(kj,:) ];                                     
                    is_radial = 1;
                    if is_radial
                        [loss_after_switch, Branch_out] = ...
                            find_loss_change(Bus, Branch0, Branch, ...
                            open_connection, close_connection, ...
                            substation_node, n_bus); 
                        loss_before_switch = loss_before_switch0;
%                         is_equal = isequal(loss_before_switch0, loss_before_switch) % zjp 2018-1-25
                        if loss_after_switch <= loss_before_switch
                            loss_not_inc = 1;
                        else
                            loss_not_inc = 0;
                        end
                        cnt = cnt+1;
                        record_o2c2 = [ record_o2c2; [loss_after_switch, loss_before_switch, ...
                            close_connection(1,:), close_connection(2,:), ...
                            open_connection(1,:), open_connection(2,:), loss_not_inc] ];
                        Branch_o2c2{cnt} = Branch_out;
                        loss_o2c2(cnt,1) = loss_after_switch;
                    end
                end
            end
                
        end
    end
end


%% obtain rows of record_o2c2 that are radial and has lower losses
[isconnected, duplicate_edge_close, duplicate_edge_open] ...
    = check_radiality(Branch0, Branch, record_o2c2, substation_node);

% idx = find(record_o2c2(:,end)==1); % switch loss not increasing
idx_status = (record_o2c2(:,end)==1)&(isconnected==1);
idx = find(idx_status);
record_o2c2_loss_dec = record_o2c2(idx,:);

Branch_o2c2_dec = Branch_o2c2{idx};
loss_o2c2_dec = loss_o2c2(idx);

% record Branch and loss
Branch_loss.Branch_o2c2_dec = Branch_o2c2_dec;
Branch_loss.loss_o2c2_dec = loss_o2c2_dec;

%% post processing for the two open and two close

%% add zone information for each row of record_mat
[first_downstream_node] = find_downstream(from_to, substation_node);

num_feeders = length(first_downstream_node);
for i = 1:num_feeders
    [first_downstream_node_temp, all_downstream_node] = ...
        find_downstream(from_to, first_downstream_node(i));
    feeder_nodes{i} = [first_downstream_node(i); all_downstream_node];
end

in_feeder3 = [];
for i = 1:size(record_o2c2_loss_dec)
    in_feeder3(i,1) = find_feeder(feeder_nodes, record_o2c2_loss_dec(i,3));
    in_feeder3(i,2) = find_feeder(feeder_nodes, record_o2c2_loss_dec(i,4));
    in_feeder3(i,3) = find_feeder(feeder_nodes, record_o2c2_loss_dec(i,5));
    in_feeder3(i,4) = find_feeder(feeder_nodes, record_o2c2_loss_dec(i,6));
end

% last four columns: which feeders are involved
record_o2c2_loss_dec(:, end+1:end+4) = in_feeder3;


%% according to the feeder type i.e., record_o2c2_loss_dec(i, end-3:end), 
% assign zone_type_o2c2 to each row of record_o2c2_loss_dec
zone_involved_o2c2 = [];
zone_type_o2c2 = [];
type_cnt = 1;
for i = 1:size(record_o2c2_loss_dec,1)
    record_o2c2_loss_dec(i, end-3:end) = sort(record_o2c2_loss_dec(i, end-3:end));    
    if i==1
        zone_involved_o2c2{1} = unique(record_o2c2_loss_dec(i, end-3:end));
        zone_type_o2c2(i,1) = type_cnt;
    else
        temp0 = unique(record_o2c2_loss_dec(i, end-3:end));
        flag =0;
        for j = 1:length(zone_involved_o2c2)
            if isequal(zone_involved_o2c2{j}, temp0)
                zone_type_o2c2(i,1) = j;
                flag = 1;
                break;
            end
        end
        if flag==0
            type_cnt = type_cnt+1;
            zone_involved_o2c2{type_cnt} = temp0;
            zone_type_o2c2(i,1) = type_cnt;
        end
    end
            
end

% output the zone_involved_o2c2
for i = 1:length(zone_involved_o2c2)
    zone_involved_o2c2{i}
end

% Example
% zone_involved_o2c2 = 
%1      1     2     5     8
%2      2     3     8
%3      2     3     7     8
%4      2     8
%5      2     7     8
%6      2     5     8
%7      3     7     8
%8      3     7
%9      7     8
%10     5     8
%11     3     5     7     8
% combination:
% 1+8
% 4+8
% 6+8
% 8+10
% 
% record_o2c2_loss_dec


%% combine two 'open two close two' together to see whether loss can be reduced

% put type i of 'open two close two' and type j of 'open two close two'
% together in combis if they can be combined together
combis = [];
for i = 1:length(zone_involved_o2c2)
    for j = (i+1):length(zone_involved_o2c2)
%         if i~=j
        l1 = length(unique([zone_involved_o2c2{i}, zone_involved_o2c2{j}]));
        l2 = length(unique([zone_involved_o2c2{i}]));
        l3 = length(unique([zone_involved_o2c2{j}]));
        if l1==(l2+l3)
            combis = [combis; [i j]];
        end
    end
end

loss_after_switch_combine_two_o2c2 = [];
for i = 1:size(combis,1)
    combi = combis(i,:);
    [loss_after_switch, Branch_out] = find_loss_change_of_combine_two_o2c2( ...
        record_o2c2_loss_dec, zone_type_o2c2, combi, ...
        Bus, Branch0, Branch, substation_node, n_bus, loss_before_switch0);
    Branch_after_switch_combine_two_o2c2{i} = Branch_out;
    loss_after_switch_combine_two_o2c2{i} = loss_after_switch;
    min(loss_after_switch);
end

% record Branch and loss
Branch_loss.Branch_after_switch_combine_two_o2c2 = ...
    Branch_after_switch_combine_two_o2c2;
Branch_loss.loss_after_switch_combine_two_o2c2 = ...
    loss_after_switch_combine_two_o2c2;

