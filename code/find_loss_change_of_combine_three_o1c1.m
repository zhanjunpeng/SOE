function [loss_after_switch, Branch_after_switch] = find_loss_change_of_combine_three_o1c1( ...
    record_o1c1_loss_dec, type_id, combi, ...
    Bus, Branch0, Branch, substation_node, n_bus, loss_before_switch0)
% two of independent 'open two branches and close two branches' combined together 
% i.e., open four branches and close four branches
% the 3-4 columns of record_o1c1_loss_dec are close connections
% the 5-6 columns of record_o1c1_loss_dec are open connections


% rows1 = zone_involved{combi(1)};
% rows2 = zone_involved{combi(2)};
    rows1 = find(type_id == combi(1));
    rows2 = find(type_id == combi(2));
    rows3 = find(type_id == combi(3));
    loss_after_switch = [];
    cnt1 = 0;
    for i=1:length(rows1)
        for j = 1:length(rows2)
            for k = 1:length(rows3)
                close_connection = record_o1c1_loss_dec([rows1(i), rows2(j), rows3(k)], [3 4]);
                open_connection = record_o1c1_loss_dec([rows1(i), rows2(j), rows3(k)], [5 6]);
    %             [loss_after_switch1, loss_before_switch1, Branch_out] = ...
                [loss_after_switch1, Branch_out] = ...
                    find_loss_change(Bus, Branch0, Branch, ...
                    open_connection, close_connection, substation_node, n_bus);  
                loss_before_switch1 = loss_before_switch0;
    %             is_equal = isequal(loss_before_switch0, loss_before_switch1) % zjp 2018-1-25
                cnt1 = cnt1+1;
                loss_after_switch(cnt1, 1) = loss_after_switch1;
                Branch_after_switch{cnt1} = Branch_out;
        %         loss_before_switch_i1(cnt1, 1) = loss_before_switch1;
            end
        end
    end


end