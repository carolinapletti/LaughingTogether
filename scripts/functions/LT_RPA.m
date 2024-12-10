function cfg = LT_RPA(cfg)
	%this function calls a subfunction to calculate the wavelet transform
    %coherence for 100 random pairs for each Subject 1 of each pair.
    %Then, it saves each of the 100 wtc data as a structure containing the following:
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
        cfg.desDir = strcat(cfg.srcDir, 'Coherence_ROIs_RPA\', cfg.currentPair, '\');
    else
        cfg.desDir = strcat(cfg.srcDir, 'Coherence_single_channels_RPA\', cfg.currentPair, '\');
    end

    if ~exist(cfg.desDir, 'dir')
        mkdir(cfg.desDir);
    end
    
    file_path_sub1 = strcat(cfg.srcDir, cfg.currentPair,'_sub1.mat');
    try
        data_sub1 = load(file_path_sub1);
    catch
        fprintf('main participant does not have a file\n');
        return
    end
    
    
    for i = 1:cfg.permnum
        out_path = strcat(cfg.desDir, cfg.currentPair, '_', int2str(i), '.mat');
        if ~exist(out_path, 'file')
            done = 0; %so that the script picks another random participant in case one of the steps does not work for one random pair. This way, we will have exactly 100 pairs for each participant
            
            while done == 0
                try
                    data_sub2 = LT_RPA_prep(cfg);
                catch
                    continue
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
                    %extract data to calculate ROIs
                    hbo_1 = data_sub1.hbo{m};
                    badChannels_1 = data_sub1.badChannels{m};
                    t = data_sub1.t{m};
                    fs = data_sub1.fs;
            
                    hbo_2 = data_sub2.hbo{m};
                    badChannels_2 = data_sub2.badChannels{m};
                    %the files should be equal length for both participants.
                    %check if that's the case and eventually adjust by taking
                    %the shortest file
                    if length(data_sub2.t{m}) ~= length(t)
                        shortest_duration = min(length(data_sub2.t{m}), length(t));
                        t = t(1:shortest_duration);
                        hbo_1 = hbo_1(1:shortest_duration, :);
                        hbo_2 = hbo_2(1:shortest_duration, :);
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
                        continue
                    end
            
                    % calculate the averages
            
                    for i = 1:length(coherences_all{m})
                        %average through time, one value per period
                        headers = coherences_all{m}{i}(:,1:3);
                        avgTime = nanmean(coherences_all{m}{i}(:,4:end),2);
                        %average through period as well. One value per channel.
                        avgAll = nanmean(avgTime);
                        coherences_avgTime{m}{i} = [headers, avgTime];
                        coherences_avgAll{m}{i} = [headers(1,2:3),avgAll];
                    end
                end
        
                coherences.all = coherences_all;
                coherences.avgTime = coherences_avgTime;
                coherences.avgAll = coherences_avgAll;
        
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
                    continue
                end
            done = 1;
            end     
        end
    end
end