function GL = L2GL(L,mid)
% Converts luminance to 'Gamma Log' according to
% 'HDR Video Coding based on Local LDR Quantization' paper

% Params:
if ~exist('mid','var')
mid = 10;
end

f = 1;
iGamma = 1/2.4;
a = 0.4742;
b = 0.1382;
c = 0.9386;

L=L/mid;

% Calculate GL
idx = (L)>f;

GL = (L.^iGamma).*not(idx) + (a.*log(L+b) + c).*idx;

% Normalize to 0...1 output for 0...10000 input
GL = GL./(a.*log(10000/mid+b)+c);

end


