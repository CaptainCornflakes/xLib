
%% DEBUG 01
punkte = xPoint();
lline = xLine();
%lline = lline.setLine([0.2 0.2 1 1 0 0; 0 0 0 1 0.75 0.75]);
tri = xTriangle([1 0.2 -1 0 0 0 1 1 1]);
line = xLine([0 1 -1 1 0 1])

show(line)
show(tri)

grid on
xlabel X
ylabel Y
zlabel Z



%% DEBUG 02
lines = xLine([0.5 0 0.5 0.5 1 0.5; 0.1 0 0.1 0.1 1 0.1]);
line = xLine([0.5 0 0.5 0.5 1 0.5]);
%tri = xTriangle([0.9 0.5 0.2 0.2 0.5 0.4 0.5 0.5 0.9]);
tris = xTriangle([0.9 0.5 0.2 0.2 0.5 0.4 0.5 0.5 0.9; 1 0.2 0.1 0.1 0.1 0 1 0.3 0.3]);

figure
axis([0 1 0 1 0 1])

show(line)
show(tris)

%%
lineTriangleIntersect(line, tris, 'any2any')


%% debug 03 shcnitt 1tri und 1 line

line = xLine([1 0 1 1 2 1]);
tri = xTriangle([0 1 0 2 1 0 1 1 2]);

test = xPoint.lineTriangleIntersect(line, tri)