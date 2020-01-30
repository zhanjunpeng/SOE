function yij = generate_yij_from_Branch(Branch, Branch0)

idx = [];
for i = 1:size(Branch, 1)
    idx_brch = find_branch(Branch0, Branch(i, 1), Branch(i, 2));
    idx = [idx; idx_brch];
end
yij = zeros(size(Branch0,1), 1);
yij(idx) = 1;

end