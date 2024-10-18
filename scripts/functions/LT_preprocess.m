function cfg = LT_preprocess(cfg)
    %this function calls another function containing the following preprocessing steps:
    %1: convert the wavelength data to optical density
    %2: identifies motion artifacts and performs spline interpolation
    %3: applies wavelet-based artifact correction
    %4: applies bandpass filtering
    %5: manual rejection of bad channels through visual inspection
    %6: converts changes in optical density to changes in HbO, HbR and HbT
    %concentration
    
    cfg.desDir = strcat(cfg.srcDir, ['preprocessed\']);
        
    if ~exist(cfg.desDir, 'dir')
        mkdir(cfg.desDir);
    end
  
    % preprocessing
    
    %for each participant in a pair
    for i = 1:2
    
        % load segment data
        fileName    = strcat(cfg.currentPair, '_sub', int2str(i));       
        file_path = strcat(cfg.srcDir, fileName, '.nirs');
        out_path = strcat(cfg.desDir, fileName, '.mat');
        
        if ~exist(out_path, 'file')
            fprintf('Load data of subject...\n');
            try
                load(file_path, '-mat');
            catch
                problem = {'file to prep can''t be opened'};
                cfg.problems = [cfg.problems, problem]; 
                continue
            end
            
            if iscell(data_out.d)
                for tn = 1:length(data_out.d)
                    try
                        [hbo{tn}, hbr{tn}, badChannels{tn}, SCIList{tn}, fs]= LT_prep(data_out.t{tn}, data_out.d{tn}, data_out.SD);   
                        t{tn} = data_out.t{tn};
                        s{tn} = data_out.s{tn};
                    catch
                        error = 1;
                        fprintf('<strong>preprocessing did not work and was not saved!</strong>\n');
                        fprintf(strcat('check preprocessing of participant ', fileName));
                        problem = {'error in preprocessing'};
                        cfg.problems = [cfg.problems, problem]; 
                    end
                end
            else
                try
                    [hbo, hbr, badChannels, SCIList, fs]= LT_prep(data_out.t, data_out.d, data_out.SD);   
                    t = data_out.t;
                    s = data_out.s;
                catch
                    error = 1;
                    fprintf('<strong>preprocessing did not work and was not saved!</strong>\n');
                    fprintf(strcat('check preprocessing of participant ', fileName));
                    problem = {'error in preprocessing'};
                    cfg.problems = [cfg.problems, problem];
                end
            end
            
            if ~error
                fprintf('The preprocessed data of dyad will be saved in'); 
                fprintf('%s ...\n', out_path);
                save(out_path, 'hbo','hbr','s','t', 'fs', 'badChannels');
                outTable = strcat(out_path, '_SCI.mat');
                save (outTable, 'SCIList');
                fprintf('Data stored!\n\n');
            end
        end
    end
    
    cfg.srcDir = cfg.desDir;
    cfg.Steps = [cfg.Steps, {'preprocessing'}];
end