function trialseq = ALTV_backend(settings,trialseq,data)

% SHORTCUTS
ow = settings.screen.outwindow;
owd = settings.screen.outwindowdims;

% COLUMNS
id = ALTV_columns;

% INTRO
glo_welcome(ow);

    % TRIAL LOOP
    for it = 1:size(trialseq,1)

        % START TIME
        if it == 1; begintime = GetSecs; end
        trialseq(it, id.time) = GetSecs - begintime;

        % FIXATION
        trial_start = glo_fixation(settings.screen.outwindow,settings.duration.fixation);

        % MAP BUTTONS
        if trialseq(it, id.go) == 1
            stim = settings.general.buttons{1};
        else
            stim = settings.general.buttons{2};
        end
        if trialseq(it, id.side) == 1
            side = -settings.layout.size.offset;
        else
            side = settings.layout.size.offset;
        end
        
        % PREP V NOVEL
        if trialseq(it, id.nov) == 1
            % color
            r1 = randperm(length(settings.layout.color.options)-1);
            colors = 2:length(settings.layout.color.options);
            color = colors(r1(1));
            % symbol
            r1 = randperm(9);
            symbols = 1:9;
            symbol = symbols(r1(1));
        else
            color = 1; % green
            symbol = 10; % circle
        end

        videocue = ALTV_makevisualcue(settings,symbol,color);
        
        % DRAW STIMULUS
        DrawFormattedText(ow, '+', 'center', 'center', settings.layout.color.text);
        DrawFormattedText(ow, stim, owd(3)/2+side, 'center', settings.layout.color.text);
        starttime = Screen('Flip', ow);
        
        % prep cue screen
        eval(videocue);
        DrawFormattedText(ow, stim, owd(3)/2+side, 'center', settings.layout.color.text);
        
        % Check for Response
        [trialseq(it,id.rt),trialseq(it,id.resp)] = handle_response_ALTV(settings.daq,trialseq(it,id.deadline)*1000,settings,trialseq,id,it,stim,side);
        
        trialend = GetSecs;
        
        % if there is no response on go trials then display feedback,
        % otherwise just keep checking for .5 seconds.
        if trialseq(it,id.go) == 1 && trialseq(it,id.resp) == 0
            DrawFormattedText(settings.screen.outwindow, 'Too Slow!', 'center', 'center', settings.layout.color.feedback);
            Screen('Flip',settings.screen.outwindow);
        else
            % Get back black background
            Screen('FillRect', settings.screen.outwindow, settings.layout.color.bg);
            Screen('Flip', settings.screen.outwindow);
            [~,post_resp] = handle_response_ALTV_postcheck(settings.daq,500);
        end
        
        % Code Responses
        if trialseq(it,id.go) == 1
            if trialseq(it,id.resp) ~= 0 && trialseq(it,id.resp) == trialseq(it,id.side)
                trialseq(it,id.acc) = 1; % correct
            elseif trialseq(it,id.resp) ~= 0 && trialseq(it,id.resp) ~= trialseq(it,id.side)
                trialseq(it,id.acc) = 2; % error
            elseif trialseq(it,id.resp) == 0
                trialseq(it,id.acc) = 99; % miss
            end
        else
            if trialseq(it,id.resp) == 0 && post_resp == 0
                trialseq(it,id.acc) = 4; % successful stop
            else
                trialseq(it,id.acc) = 3; % failed stop
            end
        end
        
        if it < size(trialseq,1)
            % adjust deadline
            if trialseq(it,id.acc) == 99
                trialseq(it+1:end,id.deadline) = trialseq(it,id.deadline) + settings.duration.deadlineadjust;
            else
                % get go trials
                gos = trialseq(trialseq(1:it,id.go)==1,:);
                if size(gos,1) >=5 && gos(end,id.acc) == 1 && gos(end-1,id.acc) == 1 && gos(end-2,id.acc) == 1
                    trialseq(it+1:end,id.deadline) = trialseq(it,id.deadline) - settings.duration.deadlineadjust;
                end
            end  
        end

        % PREVENT TRIAL OVERLOAD
        if it+1 < size(trialseq,1)
            if trialseq(it+1,id.deadline) < .25
                trialseq(it+1:end,id.deadline) = .25;
            end    
        end

        % BLOCK BREAK / countdown
        if it == size(trialseq,1) || trialseq(it,id.block) ~= trialseq(it+1,id.block)

            % Collect stats
            block = settings.blocktrials(trialseq,id,it);
            goTrials = settings.goTrials(block,id);
            nogoTrials = settings.nogoTrials(block,id);
            correctTrials = settings.correctTrials(block,id);
            missError = settings.missError(goTrials,id);
            rt = settings.RT(correctTrials,id);
            succstop = settings.succstop(nogoTrials,id);
            currentBlock = settings.currentBlock(block,id);
            stats = [currentBlock, rt, missError, succstop];

            % Display feedback
            glo_blockfeedback(settings.screen.outwindow, settings.strings, stats);

            if it ~= size(trialseq,1)
                glo_countdown(ow);
            else
                glo_outro(ow);
            end
        end
        
        % SAVE
        save(fullfile(settings.files.outfolder,settings.files.outfile),'trialseq','settings','data');
        
        while GetSecs - trialend <= settings.duration.iti
            WaitSecs(.01);
        end
        
    end
end