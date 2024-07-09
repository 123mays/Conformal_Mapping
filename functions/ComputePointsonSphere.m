sphere1 = [shapeCenter(1) shapeCenter(2) shapeCenter(3) 5.0];
streamlines_uniq=cell(length(streamlines),1);
endPoints_strLines=[];
for i=1:stepSizeforStreamLines:length(streamlines)
    i
    streamLines_i=streamlines{i};

    shapeCenter_rep=repmat(shapeCenter, length(streamLines_i),1);

    distvec=euclidean(streamLines_i, shapeCenter_rep);
    distvec_diag=diag(distvec);
    dist_idx=find(distvec_diag > 5);
    %end_idx=dist_idx(length(dist_idx));
    end_idx=length(dist_idx);
    a_start=streamLines_i(end_idx,:);
    a_end = streamLines_i(end_idx+1,:);
    diff_dx=a_end-a_start;
    line=[a_start(1) a_start(2) a_start(3) diff_dx(1) diff_dx(2) diff_dx(3)];
    
    pt=intersectLineSphere(line, sphere1);
    streamLines_uniq=[streamLines_i((1:end_idx),:); pt(1,:)];   
    endPoints_strLines=[endPoints_strLines; pt(1,:)];
    streamlines_uniq{i}=streamLines_uniq;
   
end