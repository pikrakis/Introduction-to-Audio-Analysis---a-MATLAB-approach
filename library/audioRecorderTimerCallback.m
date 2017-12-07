function audioRecorderTimerCallback(obj, event)
    %
    % function audioRecorderTimerCallback(obj, event)
    %
    % This is the callback used by the audiorecorder object
    %    
    
    MAX_SEGMENTS_TO_RECORD = 10;
    Fs           = get(obj, 'SampleRate');
    num_channels = get(obj, 'NumberOfChannels');
    num_bits     = get(obj, 'BitsPerSample');    
    TimerPeriod  = get(obj, 'TimerPeriod');
    
    if length(get(obj, 'Tag'))==0
        set(obj, 'Tag', '0')
    end
    set(obj, 'Tag', num2str(str2num(get(obj, 'Tag')) + 1));
    N = str2num(get(obj, 'Tag'));    
    if N>=MAX_SEGMENTS_TO_RECORD
        stop(obj)
        close
        return
    end    
    try                                       
        stop(obj);
        data = getaudiodata(obj);                
        plot(data)        
        axis([0 length(data) -1 1]);
        title(sprintf('Segment %d of %d\n', N, MAX_SEGMENTS_TO_RECORD));
        drawnow;
        record(obj);              
    catch
        % Stop the recorder and exit
        stop(obj)
        rethrow(lasterror)        
    end            
end