function[data_sub1, data_sub2] = load_prep(cfg)              
    % load preprocessed data
    
    fprintf('Load preprocessed data...\n');
    file_path_sub1 = strcat(cfg.srcDir, cfg.currentPair,'_sub1.mat');
    file_path_sub2 = strcat(cfg.srcDir, cfg.currentPair,'_sub2.mat');

    data_sub1=load(file_path_sub1); 
    data_sub2=load(file_path_sub2);
                   

