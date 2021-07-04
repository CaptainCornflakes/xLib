function L = PQ2L(PQ)
    % Converts perceptual quantized to luminance
    % Robin Atkins, Scott Miller and Jan Froehlich
    % Mar 2014
    % This version has the limits removed to handle negatives and >10000,
    % and uses piecewise curve to ensure invertibility
 
    % Parameters used for ITU submission
    ni = 4096*4/2610;
    mi = 4096/2523/128;
    c1 = 3424/4096;
    c2 = 2413/4096*32;
    c3 = 2392/4096*32;
 
    % Parameters used for linear section
    s = 36628238 / 2^32; % Slope to get to breakpoint
    k = 1 / 8192;        % Breakpoint
    
    % Find out if value falls in linear slope
    SlopeIdx = abs(PQ)<k;
    
    % Calculate curve part
    PQa = max(abs(PQ),k);
    L = PQa.^mi;
    L = sign(PQ).*((10000) .* ((L-c1) ./ (c2-c3.*L)).^ni);
    
    % Replace slope part
    L(SlopeIdx) = PQ(SlopeIdx) .* s;
end