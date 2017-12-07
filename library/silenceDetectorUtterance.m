function [B1, E1, B2, E2, Er, Zr] = silenceDetectorUtterance(fileName, winl, wins)

% Speech/Background discriminator based on Rabiner and Schafer, Theory and
% Applications of Digital Speech Processing, Section 10.3. Computes the
% endpoints of a speech utterance. The first 100 ms are assumed to contain
% backgroung noise.
% ARGUMENTS:
%  - fileName:  path to the input (WAVE) file
%  - winl:      length of moving window (in seconds)
%  - wins:      step (hop size) of moving window (in seconds)
%
% RETURNS:
%  - B1:        initial estimate of the beginning of the speech utterance 
%               (in seconds)
%  - E1:        initial estimate of the end of the speech utterance (seconds)
%  - B2:        final estimate of the beginning of the speech utterance (seconds)
%  - E2:        final estimate of the end of the speech utterance (seconds)
%  - Er:        normalized log Energy
%  - Zr:        Zeroc Crossing Rate
% (c) 2013 T. Giannakopoulos, A. Pikrakis
%

[x,Fs]=wavread(fileName);

L=round(winl*Fs); R=round(wins*Fs); w=hamming(L); Lx=length(x);
Er=[];
i=1;
while (i+L-1<=Lx)
    Er=[Er sum((x(i:i+L-1).*w).^2)];
    i=i+R;
end
Er=10*log10(Er)-max(10*log10(Er));

i=1;
Zr=[];
while (i+L-1<=Lx)
    tmp=x(i:i+L-1);
    sumtmp=0;
    for k=2:L
        if (tmp(k)>=0 && tmp(k-1)<0) || (tmp(k)<0 && tmp(k-1)>=0)
            sumtmp=sumtmp+2;
        end
    end
    Zr=[Zr (R/(2*L))*sumtmp];
    i=i+R;
end

fframes=round(.1/wins); % compute number of initial frames. 
% It is assumed that the first 100 ms corrspond to background signal.
eavg=mean(Er(1:fframes));
esig=std(Er(1:fframes));
zcavg=mean(Zr(1:fframes));
zcsig=std(Zr(1:fframes));

IF=35;
IZCT=max([IF zcavg+3*zcsig]);

ITU=-15; % constant in the range [-10 -20] dB
ITR=max([ITU-10 eavg+3*esig]);

Le=length(Er);
% Stage 1
flag=1;
c=1;
B1=1;
while (flag)    
    while (Er(c)<=ITR)
        c=c+1;
    end
    B1=c;
    flag=0;
    for c=B1+1:B1+3
        if c>Le
            break;
        end
        if Er(c)<ITU
            flag=1;            
            break;        
        end
    end
    if flag
        c=B1+1;
    else
        break;
    end
end

% Stage 2
flag=1;
c=length(Er);
E1=c;
while (flag)    
    while (Er(c)<=ITR)
        c=c-1;
    end
    E1=c;
    flag=0;
    for c=E1+1:-1:E1-3
        if c>length(Le)
            break;
        end
        if Er(c)<ITU
            flag=1;            
            break;        
        end
    end
    if flag
        c=E1-1;
    else
        break;
    end
end

% Stage 3
for i=B1:-1:B1-25
    if i<1
        break;
    end
    sumZ=0;
    ind=[];
    if Zr(i)>IZCT
        sumZ=sumZ+1;
        ind=[i ind];
    end
end
if sumZ>=4
    B2=ind(1);
else
    B2=B1;
end

% Stage 4
for i=E1:E1+25
    if i>Le
        break;
    end
    sumZ=0;
    ind=[];
    if Zr(i)>IZCT
        sumZ=sumZ+1;
        ind=[ind i];
    end
end
if sumZ>=4
    E2=ind(end);
else
    E2=E1;
end

% Stage 5
i=B2-1;
while (1)
    if i<1
        i=1;
        break;
    end    
    if Er(i)>ITR
        B2=i;
    else
        break;
    end
    i=i-1;
end

i=E2+1;
while(1)
    if i>Le
        i=Le;
        break;
    end    
    if Er(i)>ITR
        E2=i;
    else
        break;
    end
    i=i+1;
end
E1 = E1 * wins;
E2 = E2 * wins;
B1 = B1 * wins;
B2 = B2 * wins;