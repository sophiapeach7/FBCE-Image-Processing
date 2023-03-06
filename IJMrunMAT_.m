cleanup = "YES";
datadirectory = 'C:\\Users\\Sophia\\Documents\\GitHub\\FBCE_ImageProcessing\\_dir_intermediate_';

if cleanup == "YES"
    og_dir = pwd;
    cd(datadirectory)
    files = dir('*.txt');
    parfor i = 1:length(files)
        [empty,name] = fileparts(files(i).name);
        img = readmatrix(files(i).name);
        for n = 1:2040
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
        writematrix(img,files(i).name);
    end
end