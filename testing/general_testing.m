img = xImage('peppers.png')
img.show
img.getHistory()

%% create default testimage
ti = xImage(xPixel([0 0 0; 0.18 0.18 0.18; 1 0 0; 0 1 0; 0 0 1; 1 1 1]));
ti.show
ti.getData()
%% 
t = xImage('testcolors2');
%t.show
%t.getHistory()
%t.getData()
