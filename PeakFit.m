function res = PeakFit(b,n,ROI,numPeaks,sig_est,plotflag)

% res = PeakFit(b,n,ROI,numPeaks,sig_est,plotflag)
%
%   General Peak Fitting Tool using Curve Fitting Toolbox.  
%       Single Peak Fitting Function: (Linear Background)
%       m*x + b + A/sqrt(2*pi*sig^2)*exp(-(x-pk)^2/(2*sig^2))
%
%       Dual Peak Fitting Function: (Linear Background)
%       m*x + b + A/sqrt(2*pi*sig^2)*exp(-(x-pk)^2/(2*sig^2))+A2/sqrt(2*pi*sig^2)*exp(-(x-pk2)^2/(2*sig^2))
%
%       Inputs:
%       b: Bin Centers (x-axis ... usually energy) vector
%       n: Counts vector
%       ROI: 2 element vector region of interest
%           data includes ROI values. (ie. b >= ROI(1) & b <= ROI(2))
%       numPeaks: 1 for single, 2 for double
%       sig_est: estimate for standard deviation of a single peak
%       plotflag: 0 (no Display) >0 (show display)
%
%   res: Results structure
%         res.ft = fit results
%         res.gof = goodness of fit results
%         res.ci = confidence limits matrix (1 sigma)
%         res.cnts1 = total counts in first peak
%         res.cnts2 = total counts in second peak (if applicable)
%         res.bkgcnts = total background counts
%         res.src1cnts = total source counts in peak 1
%         res.src2cnts = total source counts in peak 2 (if applicable)
%


    if length(ROI) ~= 2
        error('ROI must have two elements [bmin,bmax]');
        return;
    end
    
    if size(b,1) > 1
        b = b';
    end
    
    if size(n,1) > 1
        n = n';
    end
    

    b_o = b;
    n_o = n;
    
    F = find(b >= ROI(1) & b <= ROI(2));
    b = b(F); n = n(F);
    
    if numPeaks==1
        mxb = b(find(n==max(n)));
        mxb = mxb(1);

        %Estimates
        %sig_est = 35;  %keV
        
        A_est = max(n)*sqrt(2*pi*sig_est^2);
        
        if length(n) > 6
            m_est = (mean(n(1:3)) - mean(n(end-2:end)))/(b(2) - b(end-1));
        else
            m_est = 0;
        end
        b_est = b(1) - m_est*b(1); 

        s = fitoptions('Method','NonlinearLeastSquares',...
                            'Lower',[0,-inf,-inf,0,0],...
                            'Upper',[inf,inf,inf,inf,inf],...
                            'Startpoint',[A_est,b_est,m_est,mxb,sig_est]);
        f = fittype('m*x + b + A/sqrt(2*pi*sig^2)*exp(-(x-pk)^2/(2*sig^2))','options',s);
        [ft,gof] = fit(b',n',f);
        
        if plotflag
            b_hires = min(b):(b(2)-b(1))/10:max(b);
            semilogy(b_o,n_o,'b',b_o,n_o,'k.'); hold on;
            semilogy(b_hires,ft.b + ft.m*b_hires,'r','LineWidth',2.0);
            semilogy(b_hires,ft.b + ft.m*b_hires + ft.A/sqrt(2*pi*ft.sig^2)*exp(-(b_hires-ft.pk).^2/(2*ft.sig^2)),'g','LineWidth',2.0);
            drawnow;
            hold off;
        end
        
        ci = confint(ft,.68);
        cnts = sum(n);
        bkg_ = ft.b + ft.m*b;
        bkg = round(sum(ft.b + ft.m*b));
        src = round(sum(n - bkg_));

        disp('Fit Results');
        disp('-----------');
        disp(['Peak Value: ',num2str(ft.pk),' ( ',num2str(ci(1,4)),' , ',num2str(ci(2,4)),' )']);
        disp(['FWHM: ',num2str(2.355*ft.sig),' ( ',num2str(2.355*ci(1,5)),' , ',num2str(2.355*ci(2,5)),' )']);
        disp(['Total Counts: ',num2str(cnts),' ( ',num2str(round(cnts-sqrt(cnts))),' , ',num2str(round(cnts+sqrt(cnts))),' )']);
        disp(['Background Counts: ',num2str(bkg),' ( ',num2str(round(bkg-sqrt(bkg))),' , ',num2str(round(bkg+sqrt(bkg))),' )']);
        disp(['Peak Counts: ',num2str(src),' ( ',num2str(round(src-sqrt(src+bkg))),' , ',num2str(round(src+sqrt(src+bkg))),' )']);
        disp(['Peak Fit Area: ',num2str(ft.A/(b(2)-b(1))),' ( ',num2str(ci(1,1)/(b(2)-b(1))),' , ',num2str(ci(2,1)/(b(2)-b(1))),' )']);

        
        res.ft = ft;
        res.ci = ci;
        res.gof = gof;
        res.cnts1 = cnts;
        res.bkgcnts = bkg;
        res.src1cnts = src;
        
        
    elseif numPeaks==2
        
        m_est = (n(end)-n(1))/(b(end)-b(1));
        b_est = n(1) - m_est*b(1);

        NBkg = b_est + m_est*b;
        DBkg = n - NBkg;
        
        F = find(DBkg < 0);
        if ~isempty(F)
            indMax = find(DBkg == min(DBkg));
            indMax = indMax(1);
            R = -1*DBkg(indMax)/n(indMax);
            m_est = (1-R)*m_est;
            b_est = (1-R)*b_est;
        end

        ind1 = find(DBkg == max(DBkg));
        A1_est = n(ind1) - (b_est + m_est*b(ind1));
        sig1_est = sig_est;
        n1 = b_est + m_est*b + A1_est*exp(-(b-b(ind1)).^2/(2*sig1_est^2));
        n2 = n-n1;
        ind2 = find(n2 == max(n2));
        A2_est = n(ind2) - (b_est + m_est*b(ind2));
      



        s = fitoptions('Method','NonlinearLeastSquares',...
                        'Lower',[0,0,-inf,-inf,0,0,0],...
                        'Upper',[inf,inf,inf,inf,inf,inf,inf],...
                        'Startpoint',[A1_est,...
                                      A2_est,...
                                      b_est,...
                                      m_est,...
                                      b(ind1),...
                                      b(ind2),...
                                      sig1_est,...
                                      ]);
        f = fittype('m*x + b + A/sqrt(2*pi*sig^2)*exp(-(x-pk)^2/(2*sig^2))+A2/sqrt(2*pi*sig^2)*exp(-(x-pk2)^2/(2*sig^2))','options',s);
        [ft,gof] = fit(b',n',f);
        if plotflag
            b_hires = min(b):(b(2)-b(1))/10:max(b);
            semilogy(b_o,n_o,'b',b_o,n_o,'k.'); hold on
            semilogy(b_hires,ft.b + ft.m*b_hires,'r','LineWidth',2.0);
            semilogy(b_hires,ft.b + ft.m*b_hires + ft.A/sqrt(2*pi*ft.sig^2)*exp(-(b_hires-ft.pk).^2/(2*ft.sig^2)),'m','LineWidth',2.0);
            semilogy(b_hires,ft.b + ft.m*b_hires + ft.A2/sqrt(2*pi*ft.sig^2)*exp(-(b_hires-ft.pk2).^2/(2*ft.sig^2)),'g','LineWidth',2.0);
            semilogy(b_hires,ft.b + ft.m*b_hires + ft.A/sqrt(2*pi*ft.sig^2)*exp(-(b_hires-ft.pk).^2/(2*ft.sig^2))+ft.A2/sqrt(2*pi*ft.sig^2)*exp(-(b_hires-ft.pk2).^2/(2*ft.sig^2)),'k','LineWidth',2.0);
            hold off
            drawnow;
        end
        
        cnts = sum(n);
        ci = confint(ft,.68);
        n1 = ft.b + ft.m*b + ft.A/sqrt(2*pi*ft.sig)*exp(-(b-ft.pk).^2/(2*ft.sig^2));
        n2 = ft.b + ft.m*b + ft.A2/sqrt(2*pi*ft.sig)*exp(-(b-ft.pk2).^2/(2*ft.sig^2));
        db = b(2)-b(1);
        cnts1 = sum(n1)/db;
        cnts2 = sum(n2)/db;
        bkg_ = ft.b + ft.m*b;
        bkg = round(sum(ft.b + ft.m*b));
        src1 = round(sum(n1 - bkg_));
        src2 = round(sum(n2 - bkg_));

        disp('Fit Results');
        disp(['Background Counts: ',num2str(bkg),' ( ',num2str(round(bkg-sqrt(bkg))),' , ',num2str(round(bkg+sqrt(bkg))),' )']);
        disp(['Peak 1 Value: ',num2str(ft.pk),' ( ',num2str(ci(1,5)),' , ',num2str(ci(2,5)),' )']);
        disp(['FWHM 1: ',num2str(2.355*ft.sig),' ( ',num2str(2.355*ci(1,7)),' , ',num2str(2.355*ci(2,7)),' )']);
        disp(['Peak 1 Fit Area: ',num2str(ft.A/db),' ( ',num2str(ci(1,1)/db),' , ',num2str(ci(2,1)/db),' )']);
        disp(['Peak 2 Value: ',num2str(ft.pk2),' ( ',num2str(ci(1,6)),' , ',num2str(ci(2,6)),' )']);
        disp(['FWHM 2: ',num2str(2.355*ft.sig),' ( ',num2str(2.355*ci(1,7)),' , ',num2str(2.355*ci(2,7)),' )']);
        disp(['Peak 2 Fit Area: ',num2str(ft.A2/db),' ( ',num2str(ci(1,2)/db),' , ',num2str(ci(2,2)/db),' )']);
        disp(['Total Counts: ',num2str(cnts),' (',num2str(cnts-sqrt(cnts)),' , ',num2str(cnts+sqrt(cnts)),' )']);

        
        res.ft = ft;
        res.gof = gof;
        res.ci = ci;
        res.cnts1 = cnts1;
        res.cnts2 = cnts2;
        res.bkgcnts = bkg;
        res.src1cnts = src1;
        res.src2cnts = src2;
        
    end
    