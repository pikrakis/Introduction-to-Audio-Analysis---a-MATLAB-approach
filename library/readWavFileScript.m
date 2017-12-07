function readWavFileScript(fileName, nExperiments)

for (i=1:nExperiments)
    [Etime1(i)] = readWavFile(fileName);
end

for (i=1:nExperiments)
    [Etime2(i)] = readWavFile(fileName, 60*0.5);    
    [Etime3(i)] = readWavFile(fileName, 60*2);
    [Etime4(i)] = readWavFile(fileName, 60*5);
    [Etime5(i)] = readWavFile(fileName, 60*10);
end

figure;
hold on;
plot(Etime1);
plot(Etime2, 'r');
plot(Etime3, 'g');
plot(Etime4, 'c');
plot(Etime5, 'c');
legend('simple','block=0.5','block=2','block=5','block=10');

[a,b] = wavread(fileName,'size');
fprintf('Signal duration: %.1f seconds\n', a(1)/b);
fprintf('%40s:%10.2f\n', 'Simple wavread()', median(Etime1));
fprintf('%40s:%10.2f\n', 'Block = 0.5 min', median(Etime2));
fprintf('%40s:%10.2f\n', 'Block = 2 min', median(Etime3));
fprintf('%40s:%10.2f\n', 'Block = 5 min', median(Etime4));
fprintf('%40s:%10.2f\n', 'Block = 10 min', median(Etime5));