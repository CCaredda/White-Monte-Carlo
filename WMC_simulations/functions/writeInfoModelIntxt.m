function writeInfoModelIntxt(info_model,outpath)

    f = fopen(strcat(outpath,'info_model.txt'), 'w');
    fprintf(f,'%s\n',strcat(resolution,num2str(info_model.resolution_xyz)));
end