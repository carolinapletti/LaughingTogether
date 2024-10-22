function cfg = LT_segment(cfg)
    %this function calls subfunctions to segment continuous .nirs data into different .nirs files containing
	%only certain segments of the laughing together task based on
    %triggers. The relevant segments (defined in the cfg file) can be
    %laughter, interaction or interaction_long
	
	%cfg: structure containing all necessary info on where to find the data and where to save them
    
    %Output: updated cfg containing all necessary info on where to find segmented data
    
    %author: Carolina Pletti (carolina.pletti@gmail.com).
    
    cfg.desDir = strcat(cfg.srcDir, cfg.currentSegment, '\');
    
    % Check if all folders exist and create them
    if ~exist(cfg.desDir, 'dir')
        mkdir(cfg.desDir);
    end

    %loop through both participants of a pair
    for i = 1:2
        fileName = strcat(cfg.currentPair, '_sub', int2str(i));
        fprintf('Load raw nirs data of subject ')
        fprintf(fileName)
        fprintf('\n');
        file_path = strcat(cfg.srcDir, fileName, '.nirs');
        

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

        if string(cfg.currentSegment) == 'laughter'
            %epochs laughter
            if ~exist(des_dir, 'file')
                    try
                        data_in = load(file_path, '-mat');
                    catch
                        problem = {'file to segment can''t be opened'};
                        cfg.problems = [cfg.problems, problem];
                        continue
                    end
                    fprintf('\nSegmenting data.\n Processing segment ')
                    fprintf(cfg.currentSegment)
                    fprintf('\n');
                try
                    data_out = LT_epoch_laughter(data_in);
                    %save cut data
                    fprintf('The laughter video data of participant ')
                    fprintf(fileName)
                    fprintf(' will be saved in');
                    fprintf('%s ...\n', des_dir);
                    save(des_dir, 'data_out');
                    fprintf('Data stored!\n\n');
                    clear data_out
                catch
                    fprintf('<strong>laughter epoching did not work and was not saved</strong>\n');
                    fprintf('check laughter trials of participant ')
                    fprintf(fileName);
                    problem = {'error in laughter epoching'};
                    cfg.problems = [cfg.problems, problem];
                end
            end
        elseif contains( string(cfg.currentSegment) , 'interaction' )
            %epochs interaction
            if ~exist(des_dir, 'file')
                    try
                        data_in = load(file_path, '-mat');
                    catch
                        problem = {'file to segment can''t be opened'};
                        cfg.problems = [cfg.problems, problem]; 
                        continue
                    end
                    fprintf('\nSegmenting data.\n Processing segment ')
                    fprintf(cfg.currentSegment)
                    fprintf('\n');
                try
                    data_out = LT_epoch_interaction(data_in, cfg.currentSegment);
                    %save cut data
                    fprintf('The interaction data of participant ')
                    fprintf(fileName)
                    fprintf(' will be saved in');
                    fprintf('%s ...\n', des_dir);
                    save(des_dir, 'data_out');
                    fprintf('Data stored!\n\n');
                    clear data_out
                catch
                    fprintf('<strong>interaction epoching did not work and was not saved!</strong>\n');
                    fprintf('check interaction trials of participant ')
                    fprintf(fileName);
                    problem = {'error in interaction epoching'};
                    cfg.problems = [cfg.problems, problem]; 
                end
            end
        end
    end
    cfg.srcDir = cfg.desDir;
    cfg.Steps = [cfg.Steps, {'segmentation'}];
    
end