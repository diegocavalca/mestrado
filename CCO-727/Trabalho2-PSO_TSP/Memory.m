function SS = Memory( SS, c )
    % Memoria...
    if( c > 0 && c <= 1 );
      x = floor(c * size(SS,1));
      SS = SS(randperm(x, x),:);     
    elseif( c > 1 || c < 1)
        partInt = floor(abs(c));
        Vaux = [];
        for j=1:partInt;
           Vaux =[Vaux; SS]; 
        end;
        %V{i} = [V{i}; unique(Vaux,'rows','stable')];
        SS = Vaux;

        partDec = c - partInt;
        x = floor(partDec * size(SS,1));
        SS = [SS; SS(randperm(x, x),:)];                
    else
        SS = [];    
    end;
end

