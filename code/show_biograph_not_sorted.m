function [from_to] = show_biograph_not_sorted(branch, substation_bus, ...
        show_biograph)

num = branch(:, [1 2]);
max_num = max(num(:))
CFT = zeros(max_num, max_num);
for i = 1:size(branch, 1)
    CFT(branch(i, 1), branch(i, 2)) = 1;
end
% view(biograph(CFT))

    
from_to = branch(:, [1 2]);
s = from_to(:,1)';
t = from_to(:,2)';
G = graph(s,t);
CFT0 = CFT;
for i = 1:size(from_to,1)
    if ( length(shortestpath(G,from_to(i,1),substation_bus) ) ...
            > length( shortestpath(G,from_to(i,2),substation_bus) ) )
        CFT(from_to(i,1),from_to(i,2)) = 0;
        CFT(from_to(i,2),from_to(i,1)) = 1;
        from_to(i, [1 2]) = from_to(i, [2 1]);
    end
end
% % load CFT_changed25.mat 

%         CFT(8,28) = 0;
%         CFT(28,8) = 1;
%         CFT(2,13) = 0;
%         CFT(13,2) = 1;
if show_biograph
    h2 = view(biograph(CFT));
%     view(biograph(CFT, '', 'ShowArrows', 'off'));
end

end