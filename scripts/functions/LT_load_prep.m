function[data_sub1, data_sub2] = LT_load_prep(cfg)

	%this function loads preprocessed fNIRS data for the experiment Laughing Together.
    
    %cfg: structure containing all necessary info on the data (e.g. in which folder to find it, which is the pair number)

    %Output:
	%data_sub_1: structure containing fNIRS data of participant 1
	%data_sub_2: structure containing fNIRS data of participant 2
    
    %author: Carolina Pletti (carolina.pletti@gmail.com).
	
    % load preprocessed data
    
    fprintf('Load preprocessed data...\n');
    file_path_sub1 = strcat(cfg.srcDir, cfg.currentPair,'_sub1.mat');
    file_path_sub2 = strcat(cfg.srcDir, cfg.currentPair,'_sub2.mat');

    data_sub1=load(file_path_sub1); 
    data_sub2=load(file_path_sub2);