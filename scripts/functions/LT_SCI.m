%function [, , ]= LT_SCI()

    %calculate scalp coupling index
    %from raw signal for both wave lengths, extract heart-rate related frequencies
    for i = 1:length(d)
        for j = 1:16
            x1 = d{i}(:,j);
            y1 = bandpass(x1,[1/2 1+1/2],fs);
            x2 = d{i}(:,j+16);
            y2 = bandpass(x2,[0.5 1.5], fs);
            %cut the first and last 200 time points to leave out artifacts. Then normalize. Cut
            %also in raw signal for plotting purposes.
            y1 = y1(200:length(y1)-200);
            normy1 = y1/max(y1)
            y2 = y2(200:length(y2)-200);
            normy2 = y2/max(y2)
            x1 = x1(200:length(x1)-200);
            x2 = x2(200:length(x2)-200);
            %calculate cross-correlation
            r = xcorr(normy1,normy2,'normalized');
            %calculate peak power
            p = pspectrum(r,fs);
            pks = findpeaks(p);
            mp = max(pks);
            %plot
            figure(1)
            set(gcf, 'WindowState', 'maximized');
            subplot(5,1,1)
            plot([x1,y1])
            subplot(5,1,2)
            plot([x2,y2])
            %plot both
            subplot(5,1,3)
            plot([normy1,normy2])
            %plot crosscorrelation
            subplot(5,1,4)
            plot(r)
            yline(0.5)
            %plot spectral power
            subplot(5,1,5)
            plot(pks)
        end
    end
    %end
