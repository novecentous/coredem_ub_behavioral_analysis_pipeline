function filtsig = hi_pass(sig,cutoff,samprate,order)
% hi_pass(sig,cutoff,samprate,order): filters sig using a nth order Butterworth filter
%
% Input:
%     sig:      signal to be filtered
%     cutoff:   cutoff for filter (in Hz)
%     samprate: sampling rate of data in sig (in Hz) (default = 1000)
%     order:    order of filter (default = 6)
%
% Output:
%     filtsig: filtered signal
%

i1=find(~isnan(sig));

if (nargin < 4)
    order = 6;
end
if (nargin < 3)
    samprate = 1000;
end


if ((sum(~isnan(sig)))>(3*order))

    sig2=sig;
    sig=sig(i1);


    [b,a] = butter(6,(cutoff/(samprate/2)),'high');
    filtsig2 = filtfilt(b,a,sig);

    filtsig = nan(size(sig2));
    filtsig(i1) = filtsig2;
    
else

    filtsig=nan(size(sig));

end