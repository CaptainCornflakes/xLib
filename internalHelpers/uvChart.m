function uvChart(img,varargin)
%UVCHART just playing around

% % %% DEBUG:
% clear classes
% img = jImage('peppers');
% img = img.toXYZ.times(1/80);

%% Presets
backGroundColor = 'w';
fontColor = 'k';

colorBGRes = 650;
uvLimit = 0.65;
viewColorSpace = x3PrimaryCS('sRGB');

% Constants
planckConstantH = 6.626176*10^-34;      % Planck's constant J*s
speedOfLight = 2.99792458*10^8;         % speed of light m/s
boltzmannConstantK = 1.380662*10^-23;	% Boltzmann's constant J/K

% 2 deg CIE CMFs in 5nm steps
CMF(:,1) = [1.299000E-4	2.321000E-4	4.149000E-4	7.416000E-4	1.368000E-3	2.236000E-3	4.243000E-3	7.650000E-3	1.431000E-2	2.319000E-2	4.351000E-2	7.763000E-2	1.343800E-1	2.147700E-1	2.839000E-1	3.285000E-1	3.482800E-1	3.480600E-1	3.362000E-1	3.187000E-1	2.908000E-1	2.511000E-1	1.953600E-1	1.421000E-1	9.564000E-2	5.795001E-2	3.201000E-2	1.470000E-2	4.900000E-3	2.400000E-3	9.300000E-3	2.910000E-2	6.327000E-2	1.096000E-1	1.655000E-1	2.257499E-1	2.904000E-1	3.597000E-1	4.334499E-1	5.120501E-1	5.945000E-1	6.784000E-1	7.621000E-1	8.425000E-1	9.163000E-1	9.786000E-1	1.026300E+0	1.056700E+0	1.062200E+0	1.045600E+0	1.002600E+0	9.384000E-1	8.544499E-1	7.514000E-1	6.424000E-1	5.419000E-1	4.479000E-1	3.608000E-1	2.835000E-1	2.187000E-1	1.649000E-1	1.212000E-1	8.740000E-2	6.360000E-2	4.677000E-2	3.290000E-2	2.270000E-2	1.584000E-2	1.135916E-2	8.110916E-3	5.790346E-3	4.106457E-3	2.899327E-3	2.049190E-3	1.439971E-3	9.999493E-4	6.900786E-4	4.760213E-4	3.323011E-4	2.348261E-4	1.661505E-4	1.174130E-4	8.307527E-5	5.870652E-5	4.150994E-5	2.935326E-5	2.067383E-5	1.455977E-5	1.025398E-5	7.221456E-6	5.085868E-6	3.581652E-6	2.522525E-6	1.776509E-6	1.251141E-6];
CMF(:,2) = [3.917000E-6	6.965000E-6	1.239000E-5	2.202000E-5	3.900000E-5	6.400000E-5	1.200000E-4	2.170000E-4	3.960000E-4	6.400000E-4	1.210000E-3	2.180000E-3	4.000000E-3	7.300000E-3	1.160000E-2	1.684000E-2	2.300000E-2	2.980000E-2	3.800000E-2	4.800000E-2	6.000000E-2	7.390000E-2	9.098000E-2	1.126000E-1	1.390200E-1	1.693000E-1	2.080200E-1	2.586000E-1	3.230000E-1	4.073000E-1	5.030000E-1	6.082000E-1	7.100000E-1	7.932000E-1	8.620000E-1	9.148501E-1	9.540000E-1	9.803000E-1	9.949501E-1	1.000000E+0	9.950000E-1	9.786000E-1	9.520000E-1	9.154000E-1	8.700000E-1	8.163000E-1	7.570000E-1	6.949000E-1	6.310000E-1	5.668000E-1	5.030000E-1	4.412000E-1	3.810000E-1	3.210000E-1	2.650000E-1	2.170000E-1	1.750000E-1	1.382000E-1	1.070000E-1	8.160000E-2	6.100000E-2	4.458000E-2	3.200000E-2	2.320000E-2	1.700000E-2	1.192000E-2	8.210000E-3	5.723000E-3	4.102000E-3	2.929000E-3	2.091000E-3	1.484000E-3	1.047000E-3	7.400000E-4	5.200000E-4	3.611000E-4	2.492000E-4	1.719000E-4	1.200000E-4	8.480000E-5	6.000000E-5	4.240000E-5	3.000000E-5	2.120000E-5	1.499000E-5	1.060000E-5	7.465700E-6	5.257800E-6	3.702900E-6	2.607800E-6	1.836600E-6	1.293400E-6	9.109300E-7	6.415300E-7	4.518100E-7];
CMF(:,3) = [6.061000E-4	1.086000E-3	1.946000E-3	3.486000E-3	6.450001E-3	1.054999E-2	2.005001E-2	3.621000E-2	6.785001E-2	1.102000E-1	2.074000E-1	3.713000E-1	6.456000E-1	1.039050E+0	1.385600E+0	1.622960E+0	1.747060E+0	1.782600E+0	1.772110E+0	1.744100E+0	1.669200E+0	1.528100E+0	1.287640E+0	1.041900E+0	8.129501E-1	6.162000E-1	4.651800E-1	3.533000E-1	2.720000E-1	2.123000E-1	1.582000E-1	1.117000E-1	7.824999E-2	5.725001E-2	4.216000E-2	2.984000E-2	2.030000E-2	1.340000E-2	8.749999E-3	5.749999E-3	3.900000E-3	2.749999E-3	2.100000E-3	1.800000E-3	1.650001E-3	1.400000E-3	1.100000E-3	1.000000E-3	8.000000E-4	6.000000E-4	3.400000E-4	2.400000E-4	1.900000E-4	1.000000E-4	4.999999E-5	3.000000E-5	2.000000E-5	1.000000E-5	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0];
CMF(:,4) = [360    365	370	375	380	385	390	395	400	405	410	415	420	425	430	435	440	445	450	455	460	465	470	475	480	485	490	495	500	505	510	515	520	525	530	535	540	545	550	555	560	565	570	575	580	585	590	595	600	605	610	615	620	625	630	635	640	645	650	655	660	665	670	675	680	685	690	695	700	705	710	715	720	725	730	735	740	745	750	755	760	765	770	775	780	785	790	795	800	805	810	815	820	825	830]*10^-9;

% xyzSPD = jSPD('XYZ');
% CMF(:,1) = interp1(xyzSPD.refWfl,xyzSPD.data(1,:),360:5:830,'linear',0);
% CMF(:,2) = interp1(xyzSPD.refWfl,xyzSPD.data(2,:),360:5:830,'linear',0);
% CMF(:,3) = interp1(xyzSPD.refWfl,xyzSPD.data(3,:),360:5:830,'linear',0);
% CMF(:,4) = [360:5:830]*10^-9;
% 


ww = CMF(5:1:85,4)';
wgX = CMF(5:1:85,1)';
wgY = CMF(5:1:85,2)';
wgZ = CMF(5:1:85,3)';

% Calculate u and v for spectral colors following Kang:
wu = 4*wgX./(wgX+15*wgY+3*wgZ);
wv = 9*wgY./(wgX+15*wgY+3*wgZ);

% get Primaries:
redYxy = viewColorSpace.getRedPrimary('Yxy');
greenYxy = viewColorSpace.getGreenPrimary('Yxy');
blueYxy = viewColorSpace.getBluePrimary('Yxy');
normalenVektor = cross( redYxy-blueYxy,greenYxy-blueYxy);
const = normalenVektor*blueYxy';


%% Calc BG Image
ColorBGLuv(:,:,1) = repmat( 0.0, [colorBGRes colorBGRes]); % Wird in xyY überschrieben
ColorBGLuv(:,:,2) = repmat((0:(uvLimit/(colorBGRes-1)):uvLimit),[colorBGRes 1]);
ColorBGLuv(:,:,3) = permute(ColorBGLuv(:,:,2),[2 1]);

% Convert to uv
ColorBGYxy(:,:,2) = 9*ColorBGLuv(:,:,2)./(6*ColorBGLuv(:,:,2)-16*ColorBGLuv(:,:,3)+12);
ColorBGYxy(:,:,3) = 4*ColorBGLuv(:,:,3)./(6*ColorBGLuv(:,:,2)-16*ColorBGLuv(:,:,3)+12);
ColorBGYxy(:,:,1) = (const - normalenVektor(2).*ColorBGYxy(:,:,2) -...
    normalenVektor(3).*ColorBGYxy(:,:,3))./normalenVektor(1);


ColorBGYxy(ColorBGYxy>1)=1;
ColorBGYxy(ColorBGYxy<0.07)=0.07;
% Y = 0.0722 um Blau nicht zu clippen

ColorBGXYZ = xImage( Yxy2XYZ(xImage( ColorBGYxy ).getPixel ) ).setColorSpace('XYZ').setSize(650,650);

ColorBGsRGB = ColorBGXYZ.setColorSpace(x3PrimaryCS('sRGB').setBlackLevel(0)...
    .setEncodingWhite(1,'Y')).fromXYZ.deLinearize.clamp(0,1).getImage;

ColorBGsRGB = ColorBGsRGB./repmat(sqrt(sum(ColorBGsRGB(:,:,1).^2 + ColorBGsRGB(:,:,2).^2 + ColorBGsRGB(:,:,3).^2,3)),[1 1 3]);

clear blueXYZ redXYZ greenXYZ redxyY greenxyY bluexyY normalenVektor


%% Start drawing Figure
figure('color',[0.5 0.5 0.5],'Position',[900,0,1050,1000]);
hold on;

%% Hintergrundbild vorbereiten
image(ColorBGsRGB)
axis image % make it fullscreen
%% colormap(map)
set(gca,'visible','off')
%set(findall(gcf,'type','text'),'fontSize',14,'fontWeight','bold')
haxes = axes;

%% Umrandung und Hintergrundfläche
wui = interp1(1:1:81,wu,1:0.1:81,'spline');
wui = [0.0 wui wu(1) 0.0 uvLimit uvLimit 0.0 0.0];

wvi = interp1(1:1:81,wv,1:0.1:81,'spline');
wvi = [0.0 wvi wv(1) 0.0 0.0 uvLimit uvLimit 0.0];

fill(wui,wvi,backGroundColor,'FaceColor',backGroundColor,'EdgeColor',backGroundColor);
set(haxes,'Color','none')
hold on;
axis image % make it fullscreen

set(gca,'FontSize',16)
% %% Gamut Triangles:
% jancolormap = [1 1 0;1 0 1;0 1 1;0 0 1; 1 0 0; 0 1 0; 1 1 1; 0.5 0.5 0.5];
% for i = 3:1:nargin
%     disp(['Schleife' num2str(i) cell2mat(varargin(i-2))])
%     curcolorspace = JColorSpace(cell2mat(varargin(i-2)));
%     text(0.4,0.20-i*0.02,curcolorspace.getName,'FontSize',14,'color',jancolormap(i-2,:));
%     [x(1), y(1), x(2), y(2), x(3), y(3)] = getPrimaries(curcolorspace);
%     x(4) = x(1); y(4) = y(1);
%     u = 4*x./(-2*x+12*y+3);
%     v = 9*y./(-2*x+12*y+3);
%     plot(u,v,'-','LineWidth',1,'Color',jancolormap(i-2,:));
% end
%% Gamuts
janColorMap = [0 0.8 0;0.8 0.8 0;0 0 1 ;0 0 0;0 1 1; 1 0 0; 0 1 0; 1 1 1; 0.5 0.5 0.5];

ct{1} = x3PrimaryCS('Rec709').setName('Rec. 709');
ct{2} = x3PrimaryCS('P3D65').setName('Dci P3');
ct{3} = x3PrimaryCS('Rec2020').setName('Rec. 2020');
%ct{4} = j3PrimaryCS('P3D65').setName('Barco DP90(K)P 2005').setRedPrimary([0.702 0.298])...
%    .setGreenPrimary([0.199 0.762]).setBluePrimary([0.143 0.044]);

%ct{4} = j3PrimaryCS('AlexaWG').setName('Alexa Wide Gamut'); 

%ct{4} = j3PrimaryCS('P3D65').setName(['Christie CP2242 with ' 10 'Barco DP90(K)P notch filter']).setRedPrimary([0.7046 0.2943])...
%    .setGreenPrimary([0.2161 0.7505]).setBluePrimary([0.1418 0.0457]);   

%ct{4} = j3PrimaryCS('P3D65').setName(['Christie 6P (Red=100%Left, ' 10 'Green=67%Left/33%Right, ' 10 'Blue=100%Right)'])...
%    .setRedPrimary([0.716919085 0.28304571]).setGreenPrimary([0.168716556 0.786729836]).setBluePrimary([0.134433422 0.041997552]);

%ct{5} = j3PrimaryCS('P3D65').setName('Solaria Notch 2013').setRedPrimary([0.704019447 0.293865376])...
%    .setGreenPrimary([0.229008176 0.739622377]).setBluePrimary([0.144832972 0.044892981]); %  i1Pro Measurement
%%
for g = 1:1:length(ct)
    x = [ct{g}.getRedPrimary('x'), ct{g}.getGreenPrimary('x'), ct{g}.getBluePrimary('x'), ct{g}.getRedPrimary('x')];
    y = [ct{g}.getRedPrimary('y'), ct{g}.getGreenPrimary('y'), ct{g}.getBluePrimary('y'), ct{g}.getRedPrimary('y')];
    u = 4*x./(-2*x+12*y+3);
    v = 9*y./(-2*x+12*y+3);
    plot(u,v,'LineWidth',1,'Color',janColorMap(g,:));
    text(0.4,0.17-0.03*g,ct{g}.getName,'FontSize',16,'Color',janColorMap(g,:));
end

% dCinema P7v2 KP-Notch-Filter V1 gemessen 2009.11.6 Dreieck einzeichnen
% x = [0.702 0.199 0.143 0.702 ];
% y = [0.298 0.762 0.044 0.298];
% u = 4*x./(-2*x+12*y+3);
% v = 9*y./(-2*x+12*y+3);
% plot(u,v,'-r','LineWidth',1);
% % Laser im Osiris Projekt:
% % ToDo: Calculate x,y from 465,532,635nm via spds
% % Done: Lookup 465,535,635nm
% x = [0.1355 0.1650 0.7140 0.1355];
% y = [0.0399 0.7980 0.2859 0.0399];
% u = 4*x./(-2*x+12*y+3);
% v = 9*y./(-2*x+12*y+3);
% plot(u,v,'-c','LineWidth',1);



%% Farbtemperaturen des schwarzen strahlenden Körpers einzeichnen
% http://www.brucelindbloom.com/index.html?Eqn_XYZ_to_T.html
PlanckKxy(:,1) = 100:100:10000;

c1 = 2 * pi * planckConstantH * speedOfLight;
c2 = (planckConstantH * speedOfLight) / boltzmannConstantK;

for i = 1:100
    
    X = wgX*((10^-8).*(c1*4)./(ww.^5.*(exp(c2./(PlanckKxy(i,1).*ww))-1)))';
    Y = wgY*((10^-8).*(c1*4)./(ww.^5.*(exp(c2./(PlanckKxy(i,1).*ww))-1)))';
    Z = wgZ*((10^-8).*(c1*4)./(ww.^5.*(exp(c2./(PlanckKxy(i,1).*ww))-1)))';
    
    PlanckKxy(i,2) = X/(X+Y+Z) ;
    PlanckKxy(i,3) = Y/(X+Y+Z) ;
end
PlanckKuv(:,1) = PlanckKxy(:,1);
PlanckKuv(:,2) = 4*PlanckKxy(:,2)./(-2*PlanckKxy(:,2)+12*PlanckKxy(:,3)+3);
PlanckKuv(:,3) = 9*PlanckKxy(:,3)./(-2*PlanckKxy(:,2)+12*PlanckKxy(:,3)+3);

plot(PlanckKuv(:,2),PlanckKuv(:,3),'-k','LineWidth',1);

% Kreuzchen bei n Kelvin
KtoPrint = [20 30 40 55 65 100];
plot(PlanckKuv(KtoPrint,2),PlanckKuv(KtoPrint,3),...
    'k+','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',8);  %Stars

printspec = {'VerticalAlignment','top','HorizontalAlignment','left','FontSize',14,'color','k'};

text(PlanckKuv(20,2),PlanckKuv(20,3),' 2000K', printspec{:});
text(PlanckKuv(30,2),PlanckKuv(30,3),' 3000K', printspec{:});
text(PlanckKuv(40,2),PlanckKuv(40,3),' 4000K', printspec{:});
text(PlanckKuv(55,2),PlanckKuv(55,3),' 5500K', printspec{:});
text(PlanckKuv(65,2),PlanckKuv(65,3),' 6500K', printspec{:});
text(PlanckKuv(100,2),PlanckKuv(100,3),' 10000K', printspec{:});

% Die D Beleuchtungen einzeichnen
x = [0.3325 0.312727];
y = [0.3476 0.329024];
u = 4*x./(-2*x+12*y+3);
v = 9*y./(-2*x+12*y+3);
plot(u,v,'w*','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',5);  %Stars
text(u(1),v(1),' D55 ','VerticalAlignment','middle','HorizontalAlignment','right','FontSize',14,'color','k');
text(u(2),v(2),' D65 ','VerticalAlignment','middle','HorizontalAlignment','right','FontSize',14,'color','k');

% %% TMP LocPro
% % Die D Beleuchtungen einzeichnen
% x = [0.3281 0.3195 0.314];
% y = [0.3551 0.3438 0.351];
% u = 4*x./(-2*x+12*y+3);
% v = 9*y./(-2*x+12*y+3);
% plot(u,v,'k*','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',5);  %Stars
% text(u(1),v(1),' Mit Filter -------','VerticalAlignment','middle','HorizontalAlignment','right','FontSize',10,'color','r');
% text(u(2),v(2),' PGM -','VerticalAlignment','middle','HorizontalAlignment','right','FontSize',10,'color','r');
% text(u(3),v(3),' DCI --------','VerticalAlignment','middle','HorizontalAlignment','right','FontSize',10,'color','r');
%% End tmp LocPro

% Punkte alle 5 nm auf der Linie der spektral reinen Farben.
plot(wu(1:2:end),wv(1:2:end),'ko','MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',5)  %Dots

%% Beschriftung der spektral reinen Punkte
text(wu(1),wv(1),[num2str((ww(1)*10^9)),'nm   '],'VerticalAlignment','middle',...
    'HorizontalAlignment','right','FontSize',16,'color',fontColor)
text(wu(13),wv(13),[num2str((ww(13)*10^9)),'nm '],'VerticalAlignment','middle',...
    'HorizontalAlignment','right','FontSize',16,'color',fontColor)

for i = 15:2:21
    text(wu(i),wv(i),[num2str((ww(i)*10^9)),'nm '],'VerticalAlignment','middle',...
        'HorizontalAlignment','right','FontSize',16,'color',fontColor)
end
for i = 23:2:27
    text(wu(i),wv(i),[num2str((ww(i)*10^9)),'nm '],'VerticalAlignment','bottom',...
        'HorizontalAlignment','right','FontSize',16,'color',fontColor)
end

%text(wu(28),wv(28),[' ',num2str((ww(28)*10^9)),'nm'],'VerticalAlignment','middle',...
%    'Rotation',90,'HorizontalAlignment','left','FontSize',16,'color',fontColor)

for i = 29:2:51
    text(wu(i),wv(i),[' ',num2str((ww(i)*10^9)),'nm'],'VerticalAlignment','middle',...
        'Rotation',90,'HorizontalAlignment','left','FontSize',16,'color',fontColor)
end

text(wu(53),wv(53),[' ',num2str((ww(53)*10^9)),'nm'],'VerticalAlignment','middle',...
    'Rotation',90,'HorizontalAlignment','left','FontSize',16,'color',fontColor)
text(wu(55),wv(55),[' ',num2str((ww(55)*10^9)),'nm'],'VerticalAlignment','middle',...
    'Rotation',90,'HorizontalAlignment','left','FontSize',16,'color',fontColor)
text(wu(79),wv(79),[' ',num2str((ww(79)*10^9)),'nm'],'VerticalAlignment','middle',...
    'Rotation',90,'HorizontalAlignment','left','FontSize',16,'color',fontColor)

%%
rawYxy = XYZ2Yxy(img.getPixel);
x = rawYxy(:,2);
y = rawYxy(:,3);
u = 4*x./(-2*x+12*y+3);
v = 9*y./(-2*x+12*y+3);

u = min( 0.65, max(0,u) );
v = min( 0.65, max(0,v) );
plot(u,v,'.k','MarkerSize',1)
end

