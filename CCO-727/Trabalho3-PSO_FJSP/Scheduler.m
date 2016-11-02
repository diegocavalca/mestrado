function [pScheduling] = Scheduler (Planning, mSize)

    % Organizar planejamento para as operacoes
    pScheduling = cell(1, mSize);
    for mach=1:mSize;
      % Operacoes Oij (indices em X) atribuidas para a Maquina Mj em Xi
      fOper = find( Planning == mach );
      pScheduling{1,mach} = fOper;
    end;  

end
