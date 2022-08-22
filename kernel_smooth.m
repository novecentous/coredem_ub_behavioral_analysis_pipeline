function smsig = kernel_smooth(sig,kernel,std)
% smooth signal by convolution with a kernel
%
% Input:
%     sig:       signal vector
%     kernel:    string identifying what kernel to use
%                  choices are 'boxcar', 'gaussian', 'decayexp', 'halfgauss', and 'alpha'
%     std:       specifies width of kernel (in msec)
%
% Output:
%     smsig: smoothed signal vector (length == length of input sig)
%
% create kernel

sig2=sig;

if ((sum(~isnan(sig)))>(2*std))

    i1=find(~isnan(sig));
    sig=sig(i1);
    
    if strcmp(kernel,'boxcar')
        r = floor(std*sqrt(3));
        x = ones(1,2*r+1);
        krnl = x/sum(x);
        ctrbin = ceil(length(krnl)/2);
    end
    if strcmp(kernel,'triangle')
        r = floor(std*2.5);
        ch = 1/r;
        lhalftri = (ch/r)*(0:r);
        rhalftri = fliplr(lhalftri(1:r));
        krnl = [lhalftri,rhalftri];
        ctrbin = ceil(length(krnl)/2);
    end
    if strcmp(kernel,'gaussian')
        r = floor(3*std);
        x = -r:r;
        krnl = normpdf(x,0,std);
        krnl = krnl/sum(krnl);
        ctrbin = ceil(length(krnl)/2);
    end
    if strcmp(kernel,'decayexp')
        r = floor(4.5*std);
        x = 0:r;
        krnl = exppdf(x,std);
        krnl = krnl/sum(krnl);
        ctrbin = 1;
    end
    if strcmp(kernel,'halfgauss')
        r = floor(3*std);
        x = 0:r;
        krnl = normpdf(x,0,std)*2;
        krnl = krnl(floor(length(krnl)/2):length(krnl));
        krnl = krnl/sum(krnl);
        ctrbin = 1;
    end
    if strcmp(kernel,'alpha')
        theta = std/sqrt(2);
        r = floor(7.5*theta);
        x = 0:r;
        krnl = gampdf(x,2,theta);
        krnl = krnl/sum(krnl);
        ctrbin = round(theta)+1;
    end

    % convolve and clip
    smsig2 = conv(krnl,sig);
    smsig2 = smsig2(ctrbin:ctrbin+length(sig)-1);

    % =========================================================================

    smsig=nan(size(sig2,1),1);
    smsig2(1:ctrbin)=repmat(smsig2(ctrbin),ctrbin,1);
    smsig2(end-ctrbin+1:end)=repmat(smsig2(end-ctrbin),ctrbin,1);

    smsig(i1)=smsig2;

else
    
   smsig=nan(size(sig));
    
end