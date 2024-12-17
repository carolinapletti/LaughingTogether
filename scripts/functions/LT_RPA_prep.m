function [coherences] = LT_RPA_prep(cfg, data_sub1) 
    
    %load preprocessed fNIRS data of randomly selected participant 2 for
    %the experiment Laughing Together
    %prepare empty cells to save coherences, check that time vectors of 2 participants correspond, calculate
    %coherences and return raw coherences and coherences averages
    
    %cfg: structure containing all necessary info on the data (e.g. in which folder to find it, which is the pair number)
    %data_sub1: data of participant 1
    
    %Output:
	%coherences: structure containing following cells:
        %coherences_all: coherence values per each channel, time point and
        %period
        %coherences_avgTime: coherence values averaged across time points
        %coherences_avgAll: coherence values averaged across time points
        %and periods
    
    %author: Carolina Pletti (carolina.pletti@gmail.com).
    
    % load preprocessed data
    fprintf('Load preprocessed data...\n');
        
    %randomly determine Subject 2

    r=randi(length(cfg.sources));
    randPart = strsplit(cfg.sources{r}, '_');
    file_path_sub2 = strcat(cfg.dataDir, randPart{1},'\', cfg.segment, '\preprocessed\', cfg.sources{r}, '_sub2.mat');
    data_sub2=load(file_path_sub2);
    
    
    %extract number of trials, numer of channels, and prepare coherence cell
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
            return
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
end


    