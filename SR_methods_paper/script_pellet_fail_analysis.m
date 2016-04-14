% script_pellet_fail_analysis
%%
numDays = 12;

tot_vids_per_session = [9	4	2	6	4	12	13	0	0	34	3
                        11	0	2	3	2	25	39	1	7	24	0
                        9	0	11	46	16	65	73	0	0	12	0
                        7	7	7	24	11	86	79	3	3	18	1
                        1	6	2	12	24	31	74	1	5	17	9
                        5	3	0	31	38	17	23	3	6	40	19
                        12	7	0	77	20	49	52	0	0	17	67
                        11	3	0	80	41	50	100	0	19	38	100
                        15	6	23	69	68	42	93	11	18	43	100
                        2	13	33	100	74	44	99	16	37	36	100
                        14	21	31	62	64	64	81	45	75	43	97
                        54	2	67	96	100	77	64	47	76	34	93
                        46	6	65	13	53	77	70	75	92	37	59
                        100	22	71	100	74	54	63	19	92	32	89];

zeros_per_session = [1	0	0	0	0	0	0	0	0	18	0
                     0	0	0	0	0	1	3	0	3	5	0
                     1	0	0	5	0	5	7	0	0	4	0
                     1	0	0	2	1	4	7	1	0	5	0
                     0	1	0	0	1	3	12	0	0	7	3
                     0	3	0	4	3	2	3	1	2	22	3
                     0	0	0	11	0	2	3	0	0	9	11
                     1	1	0	7	7	0	15	0	2	10	3
                     0	1	1	12	6	0	4	1	3	8	20
                     0	0	7	13	2	2	9	5	5	19	10
                     3	7	1	14	7	3	27	5	1	4	34
                     1	0	13	6	3	7	12	6	5	7	9
                     12	0	1	0	3	0	0	3	1	6	0
                     3	1	2	3	5	1	1	10	1	2	61];

tot_vids_per_session = tot_vids_per_session(1:numDays,:);
zeros_per_session = zeros_per_session(1:numDays,:);

zero_rate_per_session = zeros_per_session ./ tot_vids_per_session;
                 
min_trials_per_session = 30;


sessions_for_analysis = tot_vids_per_session > min_trials_per_session;

rate_thresh = 0.05;
zero_rate_below_thresh = zero_rate_per_session(sessions_for_analysis) < rate_thresh;
temp = zero_rate_below_thresh(:);

zero_counts = zeros_per_session(sessions_for_analysis);
zero_rates = zero_rate_per_session(sessions_for_analysis);

all_zeros = zeros_per_session(:);
all_zeros_sort = sort(all_zeros,'descend');
cum_all_zeros = cumsum(all_zeros_sort);
x = linspace(1/length(all_zeros_sort),1,length(all_zeros_sort));