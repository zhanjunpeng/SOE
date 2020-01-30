% from Zhu  +33bus Optimal reconfiguration of electrical distribution network

nref  = 1;          % n?de referência
vref  = 1.0;        % tensão na subestação (pu)
vbase = 12.66;      % Tensão base (kV)
sbase = 1000;       % Potência base (kVA)
tol   = 10^-8;      % Tolerância do erro permitida
vmin  = 0.9;       % Tensão mínima (pu)
vmax  = 1.00;       % Tensão máxima (pu)

% Base de impedância
% Basis of impedance
zbase = 1000*((vbase^2)/sbase);

%from to R(ohm) X(ohm)
Branch = [
1	2	0.0922	0.0470
2	3	0.4930	0.2512
3	4	0.3661	0.1864
4	5	0.3811	0.1941
5	6	0.8190	0.7070
6	7	0.1872	0.6188
7	8	0.7115	0.2351
8	9	1.0299	0.7400
9	10	1.0440	0.7400
10	11	0.1967	0.0651
11	12	0.3744	0.1298
12	13	1.4680	1.1549
13	14	0.5416	0.7129
14	15	0.5909	0.5260
15	16	0.7462	0.5449
16	17	1.2889	1.7210
17	18	0.7320	0.5739
2	19	0.1640	0.1565
19	20	1.5042	1.3555
20	21	0.4095	0.4784
21	22	0.7089	0.9373
3	23	0.4512	0.3084
23	24	0.8980	0.7091
24	25	0.8959	0.7071
6	26	0.2031	0.1034
26	27	0.2842	0.1447
27	28	1.0589	0.9338
28	29	0.8043	0.7006
29	30	0.5074	0.2585
30	31	0.9745	0.9629
31	32	0.3105	0.3619
32	33	0.3411	0.5302
8	21	2.0000	2.0000
9	15	2.0000	2.0000
12	22	2.0000	2.0000
18	33	0.5000	0.5000
25	29	0.5000	0.5000 ];

% bus Pd(kW) Qd(kW) Qbc(kW)
Bus = [
1   0       0     % substation bus
2	100.0	60.0
3	90.0	40.0
4	120.0	80.0
5	60.0	30.0
6	60.0	20.0
7	200.0	100.0
8	200.0	100.0
9	60.0	20.0
10	60.0	20.0
11	45.0	30.0
12	60.0	35.0
13	60.0	35.0
14	120.0	80.0
15	60.0	10.0
16	60.0	20.0
17	60.0	20.0
18	90.0	40.0
19	90.0	40.0
20	90.0	40.0
21	90.0	40.0
22	90.0	40.0
23	90.0	50.0
24	420.0	200.0
25	420.0	200.0
26	60.0	25.0
27	60.0	25.0
28	60.0	20.0
29	120.0	70.0
30	200.0	600.0 %  originally Q=100.0   zjp 2018-1-22
31	150.0	70.0
32	210.0	100.0
33	60.0	40.0
]; % total Pload=3.715 MW

% op = [
% 7 8
% 9 10
% 14 15
% 25 29
% 32 33
% ]; % Lavorat2012PS(Franco), note that the substation in Fig. 2 is not indexed, so all the number in 33-nodes in Table II should be added by one
% for i = 1:size(op,1)
%     idx(i,1) = find_branch(Branch, op(i,1), op(i,2));
% end
% unique(idx) % 7 9 14 32 37

%% zjp 2018-1-13
branch_always_on = [
1 2];

branches_not_in_loop = branch_always_on;
    idx_not_in_loop = [];
    for i = 1:size(branches_not_in_loop, 1)     
        idx_brch0 = find_branch(Branch, branches_not_in_loop(i,1), ...
            branches_not_in_loop(i,2));
        if idx_brch0
            idx_not_in_loop = [idx_not_in_loop; idx_brch0];  
        else
            i, branches_not_in_loop(i, :)
            fprintf('error at line 1083 of d417_v2.m')
            error
        end
    end  
    idx_all = [1:size(Branch,1)];
    brch_idx_in_loop = idx_all;
    brch_idx_in_loop(idx_not_in_loop) = [];
    