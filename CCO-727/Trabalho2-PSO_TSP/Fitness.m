function total = Fitness( individual, distances )
    total = 0;
    parfor c=2:size(individual,2);
        total = total + distances(individual(c),individual(c-1));
    end;
end

