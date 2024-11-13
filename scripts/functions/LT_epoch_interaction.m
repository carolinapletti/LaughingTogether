function data_out = LT_epoch_interaction(data_in, segment)

    %this function cuts the fNIRS time series and saves the part of the time series corresponding to when the participants were
	%freely interacting in the experiment Laughing Together. Depending on input, data are either segmented into 2 4 minutes interval,
	%or into 1 8 minute interval
    
    %data_in: fNIRS data containing time series, time vector and triggers
    %segment: how to cut the data. Possible values are either "interaction" (cut into two segments) or "interaction_long" (cut into one long segment)
    
    %Output: structure with the same format as data_in, but containing only data corresponding to the time period of interest
    
    %author: Carolina Pletti (carolina.pletti@gmail.com).

	%interaction start trigger = 5; interaction end trigger = 6
    fprintf('time stamp interaction begins');
    evtInteraction  = find(data_in.s(:, 5) > 0)
    fprintf('time stamp interaction ends');
    evtInteractionEnd  = find(data_in.s(:, 6) > 0)

    if size(evtInteraction,1)~=1 | size(evtInteractionEnd,1)~=1
        fprintf('Trial number is different than expected!\n');
        weirdtrials=1;
    else
        fprintf('Trial number is correct!\n');
        weirdtrials=0;
    end

    %cut out interaction data

    % first calculate if there are enough samples to sum
    % up to 10 minutes (with sampling rate 7.8 that would be: 10
    % minutes = 600 sec, 7.8 samples per sec means minimum 4680
    % samples). Also check that this part is not longer than 15
    % minutes, since this could indicate that something went wrong

    if weirdtrials == 0
        if evtInteractionEnd - evtInteraction > 4600 && evtInteractionEnd - evtInteraction < 7020
            
            if string(segment) == 'interaction'
                %if you want to divide interaction into two segments (segment = interaction):
                %eliminate first minute and last minutes. Segment
                %following samples: 4 minutes after the first, 4 minutes
                %before the last.

                IntFirst = evtInteraction + 468; %first sampling point of the first part to analyze
                IntFirstEnd = IntFirst + 2340; %last sampling point of the first part to analyze
                IntSecondEnd = evtInteractionEnd - 468; % last sampling point of the second part to analyze
                IntSecond = IntSecondEnd - 2340; % first sampling point of the second part to analyze
                Starts = [IntFirst, IntSecond];
                Ends = [IntFirstEnd, IntSecondEnd];
            elseif string(segment) == 'interaction_long'
                %if you want to just have an interaction block (segment = interaction_long):
                %eliminate first minute. Segment 8 minutes after the first

                Starts = evtInteraction + 468; %first sampling point of the part to analyze
                Ends = Starts + 3744; %last sampling point of the part to analyze
            end
            for n = 1:length(Starts)
                data_out.d{n} = data_in.d(Starts(n):Ends(n),:);
                data_out.s{n} = data_in.s(Starts(n):Ends(n),:);
                data_out.t{n} = data_in.t(Starts(n):Ends(n),:);
                data_out.aux{n} = data_in.aux(Starts(n):Ends(n),:);
            end
            data_out.SD = data_in.SD;
        else
            fprintf('Interaction duration is different than expected!\n');
        end
    end
end