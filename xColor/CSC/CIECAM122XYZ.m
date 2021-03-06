function Img = CIECAM122XYZ(Img,WP, La,Yb,Surround)
%Lab2XYZ Convert CIECAM02 J,aCh,bCh to linear XYZ 
%   Moroney, N., Fairchild, M., Hunt, R., & Li, C. (2002). 
%   The CIECAM02 color appearance model, 23?27.
%
%   Modifications according to:
%   C. Li, and M. R. Luo, 
%   A New version of CIECAM02 with the HPE primaries
%   Proc of IS&T?s 6th European Conference on Colour in Graphics, Imaging, and Vision, pp. 151-154 2012

%% Inputs:
% Img: Image in J,aCh,bCh
% WP:  Whitepoint in XYZ (Be carful - Values are scaled by WP_Y [WP(2)])
% La:  Adapting Luminance in cd/m2 (often 20% of (diffuse) white object in scene)
%      Relative luminance of the surround (5*La ~ LW)
%      Or 18% (Gray world Theory)
% Yb:  Yb is the relative luminance of background
% D:   Discount-the-illuminant. 1.0: Full discounting, otherwise: 
% Surround: Char or [F,c,Nc]

% %% Debug
% clear classes
% WP = [96.4296 100.0 82.49];
% La = 1000;
% Yb = 20;
% Surround = 'Average';
% ChkImg = [100,100,100;11.1888200000000 9.30994000000000 3.21014000000000;46.6854200000000 40.9282100000000 22.9758800000000;16.7582600000000 18.1139100000000 26.2697300000000;8.15736000000000 10.9013500000000 3.51587000000000;27.1097000000000 24.7090200000000 34.2584700000000;30.2017700000000 40.1619000000000 38.4030100000000;43.2910600000000 35.8008300000000 4.24324000000000;11.7222600000000 10.2977100000000 26.5536000000000;35.5533300000000 24.1177200000000 10.6168200000000;8.46030000000000 5.95075000000000 8.62407000000000;33.4836000000000 43.1894000000000 10.5689400000000;50.8407000000000 47.7820100000000 6.44891000000000;7.04857000000000 5.20992000000000 20.9946900000000;13.3814700000000 22.2855600000000 9.12724000000000;28.5474300000000 16.1113100000000 3.69209000000000;62.6446000000000 65.1303100000000 8.64558000000000;35.8915200000000 23.1847100000000 21.4777300000000;12.8470900000000 16.6331200000000 32.1581500000000;88.2731600000000 91.6910100000000 73.9732100000000;58.1568400000000 60.4703600000000 49.5230700000000;34.9839600000000 36.4597700000000 29.8558800000000;19.2811600000000 20.0254400000000 16.1892900000000;8.48420000000000 8.78762000000000 7.07607000000000;2.97292000000000 3.08391000000000 2.51477000000000];
% Img = XYZ2CIECAM12(ChkImg,WP,La,Yb,Surround);

%% Convert input types n*m*3 or jPixel/jImage to line representation
[Img, meta] = img2raw(Img);

%% Check Input Vars
if ischar(Surround)
    switch lower(Surround)
        case 'average'
            Surround = [1.0 0.69  1.0 ];
        case 'dim'
            Surround = [0.9 0.59  0.9];
        case 'dark'
            Surround = [0.8 0.525 0.8 ];
        otherwise
            error(['Surround Parmaeter value ' Surround ' not supported. Try ''Average'', ''Dim'' or ''Dark'''])
    end
end

F = Surround(1);
c = Surround(2);
Nc = Surround(3);

%% Precalculations
k = 1/(5*La+1);         % Eqn.(1):
% Lumance Level Adaption Factor:
Fl = 0.2*k^4*(5*La)+0.1*(1-k^4)^2*(5*La)^(1/3); % Eqn.(2)
% Induction Factor
n = Yb/WP(2);           % Eqn.(3): % Yb/Ww
Nbb = 0.725*(1/n)^0.2;  % Eqn.(4)
Ncb = Nbb;              % Eqn.(4)
% Base exponential nonlinearity
z = 1.48+sqrt(n);       % Eqn.(5)
D = F*(1-1/3.6 * exp(-(La+42)/92));


%% Scale XYZ Values via White to 0...100 Range and trnasfer to shapened LMS via CAT02
% To Do
% Img = Img/[W]*100;
     
MHPE  = [0.38971 0.68898 -0.07868;...   % Eqn.(12)
        -0.22981 1.18340  0.04641;...
         0.0     0.0      1.0    ];
     
%% Inverse Model Steps:
%% Step 0: Convert J,aCh,bCh to JCh
iJ = Img(:,1);
iC = hypot(Img(:,2),Img(:,3));

ih = atan2(Img(:,3),Img(:,2))*180/pi;
%ih = atan2(bCh,aCh)*180/pi;
ih = (ih<0).* (ih+360) + not(ih<0).*ih;

%% Step 1: Calculate t from C and J
it = (iC ./ (sqrt(iJ/100) * (1.64-0.29^n)^0.73)).^(1/0.9);

%% Step 2: Calculate et from h
iet = (cos(ih*pi/180+2)+3.8)/4;

%% Step 3.1: Calculate  iAW
WP_LMSs = (MHPE*(WP'))';                                      % Transfer to HPE LMS space
 
WP_LMSa = ([WP(2)*D/WP_LMSs(1) + 1 - D, 0, 0;...
             0, WP(2)*D/WP_LMSs(2) + 1 - D, 0;...
             0, 0, WP(2)*D/WP_LMSs(3) + 1 - D] * WP_LMSs')';
         
%iLMS_WP = (MHPE/CAT02*iWP_LMSsa')';                             % Transfer back to Hunt-Pointer-Estevez LMS-Cone-Space
iWP_LMS_p = (400*(WP_LMSa*Fl/100).^0.42)./(27.13 + (WP_LMSa*Fl/100).^0.42) + 0.1; % Introduce Nonlinearity
iAW = (([2, 1, 1/20]*iWP_LMS_p')' - 0.305)*Nbb;                 % Lightness

%% Step 3.2: Calculate A from AW and J
iA = (iJ/100).^(1/(c*z)) *iAW;

%% Step 4: Calculate a and b from t,et,h and A
% from Mark Fairchild xls:

% Calc P1, P2, P3, hr, P4
p1 = ((50000 / 13) * Nc * Ncb .* iet) ./ it;
p2 = (iA / Nbb) + 0.305;
p3 = 21 / 20;
hr = ih * pi / 180;
p4 = p1 ./ sin(hr);
 
%% Here come the ugly formulas!!!
% Calculate a and b:
idx = abs(sin(hr)) >= abs(cos(hr));
ndx = not(idx);
%%
bl = zeros(size(iA),1);
al = zeros(size(iA),1);

bl(idx) = (p2(idx) .* (2 + p3) .* (460 / 1403)) ./ ...
    (p4(idx) + (2 + p3) * (220/1403) * (cos(hr(idx)) ./ sin(hr(idx))) - (27/1403) + p3 * (6300/1403));
%%
al(idx) = bl(idx) .* (cos(hr(idx)) ./ sin(hr(idx)));
%%
P5 = p1(ndx) ./ cos(hr(ndx));
%%
al(ndx) = (p2(ndx) .* (2 + p3) .* (460/1403)) ./ ...
    (P5 + (2 + p3) .* (220/1403) - ( (27/1403) - p3.*(6300/1403) ) .* (sin(hr(ndx)) ./ cos(hr(ndx))));

bl(ndx) = al(ndx) .* (sin(hr(ndx)) ./ cos(hr(ndx)));
%% Step 5: CCalculate LMS_p from A, a and b
iLMS_p = ([460/1403,  451/1403,   288/1403;...
            460/1403, -891/1403,  -261/1403;...
            460/1403, -220/1403, -6300/1403] * cat(2,p2,al,bl)')';

%%  Step 6: Inverse Nonlinearity
iLMSa = 100/Fl * (((27.13 * abs(iLMS_p - 0.1)) ./ (400 - abs(iLMS_p - 0.1))) .^ (1 / 0.42));

% This should not be need with corrected HPE CIECAM02
%% Rem If any of the values of (Rap -.1), (Gap-.1), or (Bap-.1) are negative then the
%% Rem Corresponding value of Rp, Gp, or Bp must be made negative.
iLMSa((iLMS_p - 0.1) < 0 & (iLMSa > 0)) = -iLMSa((iLMS_p - 0.1) < 0 & (iLMSa > 0));

% %% Transfer from Hunt-Pointer-Estevez LMS-Cone-Space to CAT02 CONESpace
% iLMSsa = (CAT02/MHPE*iLMS')';



%% Revert Adaption
iLMSs = ([WP(2)*D/WP_LMSs(1) + 1 - D, 0, 0;...
          0, WP(2)*D/WP_LMSs(2) + 1 - D, 0;...
          0, 0, WP(2)*D/WP_LMSs(3) + 1 - D] \ iLMSa')';

%% Transfer from HPE LMS space to XYZ
Img = (MHPE\(iLMSs'))';


% %% DEBUG - CHECK
% Img - ChkImg


%% Convert back to original image format
Img = raw2img(Img,meta);

if isa(Img,'xBase')
    Img = Img.setHistory('Converted from CIECAM12 to XYZ');
end

end

    
