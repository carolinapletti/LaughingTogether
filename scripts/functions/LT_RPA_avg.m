function cfg = LT_RPA_avg(cfg) 
    
    %this function loads all wavelet transform coherence files calculated
    %for one pair of Laughing Together participants, averages all of them
    %and saves the resulting average of all randomly permuted pairs
    %coherence
    
    %cfg: structure containing all necessary info on the data (e.g. in which folder to find it, which is the pair number)

    %Output:
	%cfg:  structure containing all necessary info on the data (e.g. in which folder to find it, which is the pair number)
    
    %author: Carolina Pletti (carolina.pletti@gmail.com).
    
    out_path = strcat(cfg.desDir, cfg.currentPair, '_avg.mat');
    if ~exist(out_path, 'file')
    
        all_coherences = cell(1, 100); %create cell that contains data for each of the 100 pairings

        mat = dir([cfg.desDir, '*.mat']);
        fprintf('loading...')
        for q = 1:length(mat)
            path = strcat(mat(q).folder, '\', mat(q).name);
            load(path);
            all_coherences{q} = coherences.all{1,:};
        end
        fprintf('all loaded!')

        % Get the number of participants and sensors
        numSensors = numel(all_coherences{1});   % Should be 16

        % Initialize the output structure
        average_coherences = cell(1, numSensors);

        % Loop through each sensor
        for sensorIdx = 1:numSensors
            % Extract the matrices for all participants for this sensor
            all_matrices = cellfun(@(participant) participant{sensorIdx}, all_coherences, 'UniformOutput', false);

            % Convert the cell array to a 3D matrix (47 x 3748 x numParticipants)
            all_matrices = cat(3, all_matrices{:});

            % Compute the average across the third dimension (participants)
            average_matrix = mean(all_matrices, 3, "omitnan");

            % Store the result in the output structure
            average_coherences{sensorIdx} = average_matrix;
        end
        % The variable "average_coherences" now contains the averaged data

        %save data
        try
            fprintf('The average random permutation coherence data of dyad %s  will be saved in \n %s \n', cfg.currentPair, out_path)
            save(out_path, 'average_coherences');
            fprintf('Data stored!\n\n');
            clear coherences
            clear all_coherences
            clear all_matrices
            clear average_matrix
            clear average_coherences
        catch
            fprintf('Couldnt save data \n'); 
            return
        end
    end