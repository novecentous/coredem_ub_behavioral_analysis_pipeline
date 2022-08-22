function filtsig = lo_pass(sigC,cutoff,samprate,order)
% lo_pass(sig,cutoff,samprate,order): filters sig using a nth order Butterworth filter
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
    
if (nargin < 4)
    order = 6;
end
if (nargin < 3)
    samprate = 1000;
end


for m=1:size(sigC,2),

    sig=sigC(:,m);
    i1=find(~isnan(sig));

    if ((sum(~isnan(sig)))>(3*order))

        sig2=sig;
        sig=sig(i1);

        [b,a] = butter(order,(cutoff/(samprate/2)),'low');
        filtsig2 = filtfilt(b,a,sig);

        filtsig(:,m) = nan(size(sig2));
        filtsig(i1,m) = filtsig2;

    else

        filtsig(:,m)=nan(size(sig));

    end

end
