datadirectory = 'C:\Users\Sophia\Documents\GitHub\FBCE_ImageProcessing\_dir_intermediate_';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

D = parallel.pool.DataQueue;
h = waitbar(0, 'Program initiaiting...');
afterEach(D, @nUpdateWaitbar);
N = 1;

cd(datadirectory);
files = dir('*.txt');
nfiles = length(files);
parfor i = 1:nfiles
    [empty,name] = fileparts(files(i).name);
    img = readmatrix(files(i).name);
    if sum(img(15:30,1:2040),"all") > 3*255
        ndiv = 4;
        range = 2040/ndiv;
        for q = 1:ndiv
            nstart = 1+(q-1)*range;
            nstop = q*range;
            for n = nstart:nstop
                if sum(img(15:30,nstart:nstop),"all") > 0
                    for m = 15:30
                        if img(m,n) == 255
                            if img(33,n) == 255
                                break
                            else
                                img(1:33,n) = 0;
                                break
                            end
                        end
                    end
                end
            end
        end
        writematrix(img,files(i).name)
    end
    send(D, [i nfiles]);
end

close all force;
clear;
clc;
cd("C:\");


function nUpdateWaitbar(input)
N = evalin("base","N");
h = findall(0, 'type', 'figure', 'Tag', 'TMWWaitbar');
p = N/input(2);

waitbar(p, h, "Cleaning...");
assignin("base","N",N+1);

end