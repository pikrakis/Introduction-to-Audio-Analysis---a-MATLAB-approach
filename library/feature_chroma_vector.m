function [C, y, c] = feature_chroma_vector(x_in, Fs)

% [C, y, c]=feature_chroma_vector(x_in,Fs,winlength,step)

% ARGUMENTS:
%  - x_in:          input window (1D vector) 
%  - Fs:            sampling frequency

% RETURNS:
%  - C:             y ./ c (see below)
%  - y:             sequence of chroma vectors. Each bin of each chroma 
%                   vector is a sum of FFT amplitudes
%  - c:             sequence vectors that indicates, for each chroma 
%                   vector, the number of  Fourier coefs that take part 
%                   in the respective bin. This is useful when it comes to 
%                   calculating the man value at each bin
%
% (c) 2014 T. Giannakopoulos, A. Pikrakis


x_in = x_in / max(abs(x_in));
tone_analysis=12;
num_of_bins=12;

[mm,nn]=size(x_in);
if nn>1
    x_in=x_in';
end

l=1;
y=[];
c=[];
lengthx=length(x_in);
winlength = lengthx;
freqs=0:Fs/winlength:(floor(winlength/2)-1)*(Fs/winlength);
f0=55;
i=0;
while (1) % define the chromatic scale on the frequency axis
    f(i+1)=f0*2^(i/tone_analysis);
    if f(i+1)>freqs(length(freqs))
        f(i+1)=[];
        break
    end
    i=i+1;
end

time_vector=[];
    
    x = x_in;      
    fftMag=abs(fft(x))';
    fftMag=fftMag(1:floor(winlength/2));
    
    the_max=max(fftMag); %checking for very low-energ frames
    if the_max<=eps
        ytemp=zeros(num_of_bins,1);
        y=[ytemp];
    end
        
    dfind=find(freqs<f(1) | freqs>2000);
    fftMag(dfind)=zeros(1,length(dfind));    

    %Keep spectral PEAKS ONLY (can be omitted)
    c1=fftMag-[0 fftMag(1:length(fftMag)-1)];
    c2=[fftMag]-[fftMag(2:length(fftMag)) 0];
    dfind=find(~(c1>0 & c2>0));
    fftMag(dfind)=zeros(1,length(dfind));          
  
    nonzero=find(fftMag>0);
    if isempty(nonzero)
        y=zeros(num_of_bins,1);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    ytemp=zeros(num_of_bins,1);
    ctemp=zeros(num_of_bins,1);
    for k=1:length(nonzero)
        temp=freqs(nonzero(k));
        %N=hist(temp,f);                
        %pitch_class=find(N==1);
        [MIN, IMIN] = min(abs(temp-f));
        pitch_class = IMIN;
        h=rem(pitch_class,num_of_bins);
        if h==0
            h=num_of_bins;
        end
        ytemp(h)=ytemp(h)+fftMag(nonzero(k));
        ctemp(h)=ctemp(h)+1;
    end
    
    y=ytemp;
    c=ctemp;

% WHY????????????????
[K1,L1] = size(y);
[K2,L2] = size(c);
if (L1~=L2)
    c = imresize(c,size(y));
end
C = y./(c+1);
