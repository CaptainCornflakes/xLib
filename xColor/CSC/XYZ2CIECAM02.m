function Img = XYZ2CIECAM02(Img, WP, La, Yb, Surround)
%Lab2XYZ Convert linear XYZ to CIECAM02
%   Moroney, N., Fairchild, M., Hunt, R., & Li, C. (2002). 
%   The CIECAM02 color appearance model, 23?27. 
%   Retrieved from https://ritdml.rit.edu/handle/1850/7848

%% Inputs:
% Img: Image in XYZ
% WP:  Whitepoint in XYZ (Be carful - Values are scaled by WP_Y [WP(2)])
% La:  Adapting Luminance in cd/m2 (often 20% of (diffuse) white object in scene)
%      Relative luminance of the surround (5*La ~ LW)
%      Or 18% (Gray world Theory)
% Yb:  Yb is the relative luminance of background
% D:   Discount-the-illuminant. 1.0: Full discounting, otherwise: 
% Surround:

% %% Debug
% clear classes
% Img = [100,100,100;11.1888200000000 9.30994000000000 3.21014000000000;46.6854200000000 40.9282100000000 22.9758800000000;16.7582600000000 18.1139100000000 26.2697300000000;8.15736000000000 10.9013500000000 3.51587000000000;27.1097000000000 24.7090200000000 34.2584700000000;30.2017700000000 40.1619000000000 38.4030100000000;43.2910600000000 35.8008300000000 4.24324000000000;11.7222600000000 10.2977100000000 26.5536000000000;35.5533300000000 24.1177200000000 10.6168200000000;8.46030000000000 5.95075000000000 8.62407000000000;33.4836000000000 43.1894000000000 10.5689400000000;50.8407000000000 47.7820100000000 6.44891000000000;7.04857000000000 5.20992000000000 20.9946900000000;13.3814700000000 22.2855600000000 9.12724000000000;28.5474300000000 16.1113100000000 3.69209000000000;62.6446000000000 65.1303100000000 8.64558000000000;35.8915200000000 23.1847100000000 21.4777300000000;12.8470900000000 16.6331200000000 32.1581500000000;88.2731600000000 91.6910100000000 73.9732100000000;58.1568400000000 60.4703600000000 49.5230700000000;34.9839600000000 36.4597700000000 29.8558800000000;19.2811600000000 20.0254400000000 16.1892900000000;8.48420000000000 8.78762000000000 7.07607000000000;2.97292000000000 3.08391000000000 2.51477000000000];
% WP = [96.4296 100.0 82.49];
% La = 1000;
% Yb = 20;
% Surround = 'Average';

%% Convert input types n*m*3 or xPixel/xImage to line representation
[Img, meta] = img2raw(Img);

%% Check Input Vars
if ischar(Surround)
    switch lower(Surround)
        case 'average'
            Surround = [1.0 0.69  1.0 ];
        case 'dim'
            Surround = [0.9 0.59  0.9 ];
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

%% Scale XYZ Values via White to 0...100 Range and trnasfer to shapened LMS via CAT02
% To Do
% Img = Img/[W]*100;

CAT02 = [0.7328 0.4296 -0.1624;...      % Eqn.(7)
        -0.7036 1.6975  0.0061;...
         0.0030 0.0136  0.9834];
     
MHPE  = [0.38971 0.68898 -0.07868;...   % Eqn.(12)
        -0.22981 1.18340  0.04641;...
         0.0     0.0      1.0    ];
%% Transfer to shapened CAT02 LMS space
LMSs = (CAT02*(Img'))';
WP_LMSs = (CAT02*(WP'))';
     
D = F*(1-1/3.6 * exp(-(La+42)/92));

%% Adapt
LMSsa = ([WP(2)*D/WP_LMSs(1) + 1 - D, 0, 0;...
          0, WP(2)*D/WP_LMSs(2) + 1 - D, 0;...
          0, 0, WP(2)*D/WP_LMSs(3) + 1 - D] * LMSs')';
WP_LMSsa = ([WP(2)*D/WP_LMSs(1) + 1 - D, 0, 0;...
             0, WP(2)*D/WP_LMSs(2) + 1 - D, 0;...
             0, 0, WP(2)*D/WP_LMSs(3) + 1 - D] * WP_LMSs')';

%% Transfer back to Hunt-Pointer-Estevez LMS-Cone-Space
LMS = (MHPE/CAT02*LMSsa')';
LMS_WP = (MHPE/CAT02*WP_LMSsa')';

%% Introduce Nonlinearity:
LMS_p = (400*(LMS*Fl/100).^0.42)./(27.13 + (LMS*Fl/100).^0.42) + 0.1;
WP_LMS_p = (400*(LMS_WP*Fl/100).^0.42)./(27.13 + (LMS_WP*Fl/100).^0.42) + 0.1;

%% Calculate a,b
a = ([1, -12/11, 1/11]*LMS_p')';
b = ([1/9, 1/9, -2/9]*LMS_p')';

h = cart2pol(a,b);
h = h*180/pi;
%% TODO AUFRÄUMEN
h = (h<0).* (h+360) + not(h<0).*h;
et = (cos(h*pi/180+2)+3.8)/4;
% %% Excentricity values to make h H:
% ehH = [20.14 90 164.25 237.53 380.14;0.8 0.7 1.0 1.2 0.8;0 100 200 300 400];
% %%
% % H0 = interp1(ehH(1,:),ehH(2,:),h0,'linear'); 

%% Lightness:
A = (([2, 1, 1/20]*LMS_p')' - 0.305)*Nbb;
AW = (([2, 1, 1/20]*WP_LMS_p')' - 0.305)*Nbb;
J = 100*(A/AW).^(c*z);

% %% Brightness
% Q = (4/c)*sqrt(J/100)*(AW+4)*Fl^0.25;

%% Chroma
t = 50000/13*Nc*Ncb*(  et.*sqrt(a.^2+b.^2)./(([1, 1, 21/20]*LMS_p')')  );
C = (t.^0.9) .* sqrt(J/100) * (1.64-0.29^n)^0.73;

% %% Colorfulness
% M = C*Fl^0.25;
% 
% %% Saturation
% s = 100*sqrt(M./Q);

%% Cart. Coordinates
aCh = C.*cosd(h);
bCh = C.*sind(h);

% %% Check
% % Calculate Reference Values:
% [RefJ,RefQ,RefC,RefM,Refs,Refh] = ciecam02(Img,WP,La,Yb,Surround);
% 
% %% 
% RefJ'-J
% %%
% RefQ'-Q
% %%
% RefC'-C
% %%
% RefM'-M
% %%
% Refs'-s
% %%
% Refh'-h

    
Img = cat(2,J,aCh,bCh);

%% Convert back to original image format
Img = raw2img(Img,meta);

if isa(Img,'xBase')
    Img = Img.setHistory('Converted from XYZ to CIECAM02');
end

end

    
    
