function [cfg] = LT_convert(cfg)
    %this function converts raw NIRX data into raw .nirs data that can be
    %opened with Homer2
    
    %load SD file
    load(cfg.SDFile, '-mat', 'SD');
    
    %this loops through 2 because there are two subjects per pair
    for i = 1:2
        %set filenames
        SubSrcDir = strcat(cfg.srcDir, cfg.currentPair, '\Subject', int2str(i), '\');
        SubDesFile = strcat(cfg.desDir, cfg.currentGroup, '\', cfg.currentPair, '_sub', int2str(i),'.nirs');
        
        Sub_wl1File = strcat(SubSrcDir, cfg.currentPair, '.nosatflags_wl1');
        Sub_wl2File = strcat(SubSrcDir, cfg.currentPair, '.nosatflags_wl2');
        Sub_hdrFile = strcat(SubSrcDir, cfg.currentPair, '.hdr');

        % -------------------------------------------------------------------------
        % Convert and export data
        % -------------------------------------------------------------------------

        if ~exist(SubDesFile, 'file')
            try
                convertData(SubDesFile, Sub_wl1File, Sub_wl2File, Sub_hdrFile, SD);
            catch
                Sub_wl1File = strcat(SubSrcDir, cfg.currentPair, '.wl1');
                Sub_wl2File = strcat(SubSrcDir, cfg.currentPair, '.wl2');
                try
                    convertData(SubDesFile, Sub_wl1File, Sub_wl2File, Sub_hdrFile, SD);
                catch e
                    fprintf(e.identifier);
                    fprintf(e.message);
                    problem = 'error in conversion';
                    cfg.problems = [cfg.problems, problem];
                end
            end    
        end
    end
    cfg.srcDir = cfg.desDir;
    cfg.Steps = 'conversion';
end  

