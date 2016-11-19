function [vizinho] = Neighbor(k, m)
  %aqui é feito um swap das posições de 2 valores de agendamento de um
  %roteiro qualquer
  
%   vizinho = k;
%   for i=1:m;
%       machine = k{i};
%       lm = length(machine);
%       if lm>=2;
%           c = 2;
%           while c <= lm;
%               v_aux = vizinho{i}(c-1);
%               vizinho{i}(c-1) = vizinho{i}(c);
%               vizinho{i}(c) = v_aux;
%               c = c + 2;
%           end;
%       end;
%   end;
  vizinho = k;  
  
  regMach = zeros(1,1);
  
  % numero de maquinas a realizar troca (maximo 1/2 do total)
  numberMachines = randi([1 m/2]);
  
  for i=1:numberMachines;
      
      nova_maq = randi([1, m], 1);
      
      while ismember(nova_maq, regMach);
          nova_maq = randi([1, m], 1);
          %disp(':B');
      end;
      
      regMach = [regMach; nova_maq];
      
      z = vizinho{nova_maq};

      %força uma máquina que possua mais de 2 operações para dar swap
      while length(z) < 2
        nova_maq = randi([1, m], 1);
        z = vizinho{nova_maq};
      end

      %antigo permutate de 2
      job_to_mutate1 = randi([1, length(z)], 1);
      v1 = z(job_to_mutate1);
      job_to_mutate2 = randi([1, length(z)], 1);
      %força um valor diferente do escolhido anteriormente
      while v1 == job_to_mutate2
       job_to_mutate2 = randi([1, length(z)], 1);
      end
      v2 = z(job_to_mutate2);
      z(job_to_mutate1) = v2;
      z(job_to_mutate2) = v1;  
      vizinho{nova_maq} = z;
  end;
  
  %vizinho{nova_maq} = z(randperm(length(z)));
  %while vizinho{nova_maq} == z
  %  vizinho{nova_maq} = z(randperm(length(z)));
  %end
end
