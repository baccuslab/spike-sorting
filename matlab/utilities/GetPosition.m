function pos=GetPosition(ch, arraytype)

if strcmp(arraytype, 'hidens')
    [posx, posy] = meshgrid(linspace(0.1,0.9,11), linspace(0.1,0.9,12));
    poslistx = posx(:);
    poslisty = posy(:);
else
    poslistx=1/11*[[0 0 10 10] 1.5+[3 3 3 3 2 2 1 2 1 0 1 0 2 1 0 0 1 2 0 1 0 1 2 1 2 2 3 3 3 3 4 4 4 4 5 5 6 5 6 7 6 7 5 6 7 7 6 5 7 6 7 6 5 6 5 5 4 4 4 4]];
    poslisty=0.125*[7 6 7 6 1 0 2 3 0 1 0 2 1 1 2 2 3 3 3 4 4 4 5 5 6 6 5 7 6 7 4 5 7 6 6 7 5 4 7 6 7 5 6 6 5 5 4 4 4 3 3 3 2 2 1 1 2 0 1 0 3 2 0 1];
end
pos=[poslistx(ch+1);poslisty(ch+1)]';