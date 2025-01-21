function cfg = LT_WTC(cfg)
	%this function calls a subfunction to calculate the wavelet transform coherence for every
    %participant pair. Then, it saves wtc data as a structure containing the following:
    % 1 - one matrix per channel combination with one value per each time
    % point and period, excluding periods not of interest (i.e. from 
    %greater than 4 times the filter to smaller than trial duration/4)
    % 2 - one vector per channel combination with one value per period
    % (excluding periods not of interest), averaged across timepoints
    % 3 - one value per channel combination representing average WTC across
    % timepoints and periods of interest
	
	%cfg: structure containing all necessary info on where to find the data and where to save them
    
    %Output: updated cfg containing all necessary info on where to find wavelet coherence transform data
    
    %author: Carolina Pletti (carolina.pletti@gmail.com). Based on a script by Trinh Nguyen

    
    if cfg.ROI == 1
        cfg.desDir = strcat(cfg.srcDir, 'Coherence_ROIs\');
    else
        cfg.desDir = strcat(cfg.srcDir, 'Coherence_single_channels\');
    end

    if ~exist(cfg.desDir, 'dir')
        mkdir(cfg.desDir);
    end
    
    out_path = strcat(cfg.desDir, cfg.currentPair, '.mat');
    if ~exist(out_path, 'file')
        try
            [data_sub1, data_sub2] = LT_load_prep(cfg);
        catch
            problem = {'file for WTC can''t be opened'};
            cfg.problems = [cfg.problems, problem];
            return
        end

        %extract number of trials, numer of channels, and prepare
        %coherence cell
        numOfTrials = length(data_sub1.hbo);
        %space to save coherence for each combination of time and
        %period(frequency)
        coherences_all{numOfTrials}  = [];
        coherences_avgTime{numOfTrials} = [];
        coherences_avgAll{numOfTrials} = [];

        for m = 1:numOfTrials
            %calculate ROIs
            hbo_1 = data_sub1.hbo{m};
            badChannels_1 = data_sub1.badChannels{m};
            t = data_sub1.t{m};
            fs = data_sub1.fs;
			
            hbo_2 = data_sub2.hbo{m};
            badChannels_2 = data_sub2.badChannels{m};
            %the time vectors for both participants should be identical.
            %check if that's the case
            if data_sub2.t{m} ~= t
                fprintf('the time vectors of the two participants don''t correspond!')
                problem = {'time vectors don''t correspond'};
                cfg.problems = [cfg.problems, problem];
                return;
            end
            if cfg.ROI == 1
                %average all channels by ROI
                [hbo_1, badChannels_1] = LT_calcROI(hbo_1, badChannels_1);
                [hbo_2, badChannels_2] = LT_calcROI(hbo_2, badChannels_2);
            end

            %calculate coherences

            try
                coherences_all{m} = LT_calcCoherence(hbo_1, hbo_2, badChannels_1, badChannels_2, t, fs);
            catch exception
                fprintf('couldnt calculate coherence for this part!\n');
                msgText = getReport(exception);
                fprintf(msgText);
                problem = {'couldn''t calculate coherence'};
                cfg.problems = [cfg.problems, problem];
                return;
            end
            
            % calculate the averages
            
            for i = 1:length(coherences_all{m})
                %average through time, one value per period
                headers = coherences_all{m}{i}(:,1:3);
                avgTime = mean(coherences_all{m}{i}(:,4:end),2, "omitnan");
                %average through period as well. One value per channel.
                avgAll = mean(avgTime, "omitnan");
                coherences_avgTime{m}{i} = [headers, avgTime];
                coherences_avgAll{m}{i} = [headers(1,2:3),avgAll];
            end
                time{m} = t;
        end
        
        coherences.all = coherences_all;
        coherences.avgTime = coherences_avgTime;
        coherences.avgAll = coherences_avgAll;
        coherences.time = time;
        
        %save data
        try
            fprintf('The wtc data of dyad ')
            fprintf(cfg.currentPair)
            fprintf(' will be saved in\n'); 
            fprintf('%s ...\n', out_path);
            save(out_path, 'coherences');
            fprintf('Data stored!\n\n');
            clear coherences
        catch
            fprintf('Couldnt save data '); 
            problem = {'couldn''t save coherence data'};
            cfg.problems = [cfg.problems, problem];
        end
    end
    
end