function data_sub2 = LT_RPA_prep(cfg) 
    
    %this function loads preprocessed fNIRS data for the experiment Laughing Together.
    %it loads data of one randomly extracted
    %participant
    
    %cfg: structure containing all necessary info on the data (e.g. in which folder to find it, which is the pair number)

    %Output:
	%data_sub_2: structure containing fNIRS data of randomly extracted participant 2
    
    %author: Carolina Pletti (carolina.pletti@gmail.com).
    
    % load preprocessed data
    fprintf('Load preprocessed data...\n');
        
    %randomly determine Subject 2
    working = 0;
    while working == 0
        r=randi(length(cfg.sources));
        randPart = strsplit(cfg.sources{r}, '_');
        file_path_sub2 = strcat(cfg.dataDir, randPart{1},'\', cfg.segment, '\preprocessed\', cfg.sources{r}, '_sub2.mat');
        try
            data_sub2=load(file_path_sub2);
            working = 1;
        catch
            working = 0;
        end
    end        