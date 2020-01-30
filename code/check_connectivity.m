function [all_connected] = check_connectivity(branch12)
% check connectivity,  all_connected = 1 if all connected
        G_tmp = graph(branch12(:,1)', branch12(:,2)');

        bins = conncomp(G_tmp);
        if length(unique(bins))~=1
            all_connected = 0;
        else
            if unique(bins) ~= 1
                all_connected = 0;
            else
                all_connected = 1;
            end                    
        end
end