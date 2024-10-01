function [data_sub1, data_sub2] = sp(prefix, id, srcPath, numOfSources, numOfPart) 
    % load preprocessed data
    filename_sub1    = strcat(prefix, sprintf('_%02d_sub1', id));
    r=randi(numOfSources);
    while id == numOfPart(r)
        r=randi(numOfSources);
    end
    filename_sub2    = strcat(prefix, sprintf('_%02d_sub2', numOfPart(r))); %change when processing pilots

    fprintf('Load preprocessed data...\n');
    file_path_sub1 = strcat(srcPath, filename_sub1,'.mat')
    file_path_sub2 = strcat(srcPath, filename_sub2,'.mat')

    data_sub1=load(file_path_sub1); 
    data_sub2=load(file_path_sub2);