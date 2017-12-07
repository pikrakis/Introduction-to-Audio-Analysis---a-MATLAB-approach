function recObject = audioRecorderOnline

timerPeriod = 0.5;
recObject = audiorecorder(8000, 16, 1);
set( recObject, 'TimerFcn', @audioRecorderTimerCallback, 'TimerPeriod', timerPeriod);
record( recObject );

end