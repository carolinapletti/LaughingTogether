function cfg = LT_segment(cfg)
    %this segments continuous .nirs data into different .nirs files contain
    %ing only certain segments of the laughing together task based on
    %triggers. The relevant segments (defined in the cfg file) can be
    %laughter or interaction
    
    
    cfg.desDir = strcat(cfg.srcDir, cfg.currentGroup, '\', cfg.currentSegment, '\');
    
    % Check if all folders exist and create them
    if ~exist(cfg.desDir, 'dir')
        mkdir(cfg.desDir);
    end

    %loop through both participants of a pair
    for i = 1:2
        fileName = strcat(cfg.currentPair, '_sub', int2str(i));
        fprintf('Load raw nirs data of subject...\n');
        fprintf(fileName);
        file_path = strcat(cfg.srcDir, cfg.currentGroup, '\', fileName,'.nirs');
        
        try
            data_in = load(file_path, '-mat');
        catch
            problem = {'file to segment can''t be opened'};
            cfg.problems = [cfg.problems, problem]; 
            continue
        end

        %triggers for participants after pilot phase:
        % 1 - madlips start
        % 2 - madlips end
        % 3 - video start
        % 4 - video end
        % 5 - interaction start
        % 6 - interaction end
        % 7 - castle knights start
        % 8 - castle knights end


        des_dir = strcat(cfg.desDir, fileName, '.nirs');

        if cfg.currentSegment == 'laughter'
            %epochs laughter
            if ~exist(des_dir, 'file')
                    fprintf('\nSegmenting data.\n Processing segment\n');
                    cfg.currentSegment
                try
                    [data_out] = epoch_laughter(data_in); 
                    %save cut data        
                    fprintf('The laughter video data will be saved in'); 
                    fprintf('%s ...\n', des_dir);
                    save(des_dir, 'data_out');
                    fprintf('Data stored!\n\n');
                    clear data_out
                catch
                    fprintf('<strong>laughter epoching did not work and was not saved</strong>\n');
                    fprintf(strcat('check laughter trials of participant ', fileName));
                    problem = {'error in laughter epoching'};
                    cfg.problems = [cfg.problems, problem]; 
                end
            end

        elseif contains( cfg.currentSegment , 'interaction' )
            %epochs interaction
            if ~exist(des_dir, 'file')
                    fprintf('\nSegmenting data.\n Processing segment\n');
                    cfg.currentSegment
                try
                    [data_out] = epoch_interaction(data_in, cfg.divide);
                    %save cut data
                    fprintf('The interaction data will be saved in'); 
                    fprintf('%s ...\n', des_dir);
                    save(des_dir, 'data_out');
                    fprintf('Data stored!\n\n');
                    clear data_out
                catch
                    fprintf('<strong>interaction epoching did not work and was not saved!</strong>\n');
                    fprintf(strcat('check interaction trials of participant ', fileName));                    
                    problem = {'error in interaction epoching'};
                    cfg.problems = [cfg.problems, problem]; 
                end
            end
        end
    end
    cfg.srcDir = cfg.desDir;
    cfg.Steps = [cfg.Steps, {'segmentation'}];
    
end
  
  
