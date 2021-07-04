function L = GL2L(GL,mid)
% Converts luminance to 'Gamma Log' according to
% 'HDR Video Coding based on Local LDR Quantization' paper

% Params:
if ~exist('mid','var')
    mid = 2;
end

f = 1; % Beware, code below must be adapted for f != 1;
gamma = 2.4;
a = 0.4742;
b = 0.1382;
c = 0.9386;

%%
% Remove normalization to 0...1
GL = GL.*(a.*log(10000/mid+b)+c);

% Calculate GL
idx = (GL)>f;

L = (GL.^gamma).*not(idx) + (exp((GL-c)./a)-b).*idx;

% Scale to 0...10000
L=L.*mid;

end


