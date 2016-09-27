function SS = Memory( SS, c )
    % Memoria...
    if( c > 0 && c <= 1 );
        SS = SS(1:ceil( c * size(SS,1)),:);     
    elseif( c > 1)
        partInt = floor(c);
        Vaux = [];
        for j=1:partInt;
           Vaux =[Vaux; SS]; 
        end;
        %V{i} = [V{i}; unique(Vaux,'rows','stable')];
        SS = Vaux;

        partDec = c - partInt;
        SS = [SS; SS(1:ceil( partDec * size(SS,1)),:)];                
    else
        SS = [];    
    end;
end

