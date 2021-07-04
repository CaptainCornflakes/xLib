function PQ = L2PQ(L)
%% L2PQ % Converts perceptual quantized to luminance
% Robin Atkins, Scott Miller and Jan Froehlich
% Mar 2014
% This version has the limits removed to handle negatives and >10000,
% and uses piecewise curve to ensure invertibility.

% Parameters used for ITU submission
n  = 2610/4096/4;
m  = 2523/4096*128;
c1 = 3424/4096;
c2 = 2413/4096*32;
c3 = 2392/4096*32;

% Parameters used for linear section
s = 36628238 / 2^32; % Slope to get to breakpoint
ks = s / 8192;       % Breakpoint

% Find out if value falls in linear slope
SlopeIdx = abs(L) < ks;

% Calculate curve part
La = max(abs(L),ks);
PQ = ((La)./(10000)).^n;
PQ = sign(L).*(((c1+c2.*PQ)./(c3.*PQ+1)).^m);

% Replace slope part
PQ(SlopeIdx) = L(SlopeIdx) ./ s;
end