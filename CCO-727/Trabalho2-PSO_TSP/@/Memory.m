function SS = Memory( SS, c )
    % Memoria...
    if( c > 0 && c <= 1 );
      limit = floor(c * size(SS,1));
      SS = SS(1:limit,:);     
      %SS = SS(randperm(limit),:);
    elseif( c > 1 || c < 1)
        partInt = floor(abs(c));
        Vaux = [];
        for j=1:partInt;
           Vaux =[Vaux; SS]; 
        end;
        %V{i} = [V{i}; unique(Vaux,'rows','stable')];
        SS = Vaux;

        partDec = c - partInt;
        limit = floor(partDec * size(SS,1));
        SS = [SS; SS(1:limit,:)];   
        %SS = [SS; SS(randperm(limit),:)]; 
    else
        SS = [];    
    end;
end

