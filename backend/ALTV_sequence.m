function trialseq = ALTV_sequence(settings, data)

    id = ALTV_columns;
    trialseq = [];

    % SHORTCUTS
    col = length(fieldnames(id));
    
    for it = 1:settings.general.blocks
        
        % get number of each trial type
        go_stan = int64((settings.general.trials * (1-settings.general.nogo) * (1-settings.general.nov))); %32
        nogo_stan = int64((settings.general.trials * settings.general.nogo * (1-settings.general.nov))); %16
        go_nov = int64((settings.general.trials * (1-settings.general.nogo) * settings.general.nov)); %8
        nogo_nov = int64((settings.general.trials * settings.general.nogo * settings.general.nov)); %4
        
        % trial chunks
        go_stan = zeros(go_stan,col);
        go_stan(1:size(go_stan,1)/2, id.side) = 1;
        go_stan(size(go_stan,1)/2+1:end, id.side) = 2;
        go_stan(:, id.go) = 1;
        
        nogo_stan = zeros(nogo_stan,col);
        nogo_stan(1:size(go_stan,1)/2, id.side) = 1;
        nogo_stan(size(nogo_stan,1)/2+1:end, id.side) = 2;
        
        go_nov = zeros(go_nov,col);
        go_nov(1:size(go_nov,1)/2, id.side) = 1;
        go_nov(size(go_nov,1)/2+1:end, id.side) = 2;
        go_nov(:,id.nov) = 1;
        go_nov(:,id.go) = 1;
        
        nogo_nov = zeros(nogo_nov,col);
        nogo_nov(1:size(nogo_nov,1)/2, id.side) = 1;
        nogo_nov(size(nogo_nov,1)/2+1:end, id.side) = 2;
        nogo_nov(:,id.nov) = 1;
        
        % Merge
        block = [go_stan; nogo_stan; go_nov; nogo_nov];
        
        if data.training == 0;
        
            % shuffle (no two novel trials in a row)
            block = trialcheck(block,id.nov);
        
        else
            
            block = shuffle_me(block,id.trialnum);
            
        end
        
        % block number
        block(:,id.block) = it;
        
        trialseq = [trialseq; block];
        
    end
    
    % starting deadline
    trialseq(:,id.deadline) = settings.duration.deadline;

    % correct trial numbers
    for ib = 1:(settings.general.trials * settings.general.blocks)
        trialseq(ib,id.trialnum) = ib;
    end
end
        