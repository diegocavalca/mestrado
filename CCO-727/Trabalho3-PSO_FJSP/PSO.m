function [tempos, melhorSolucao] = PSO(tempo_jobs, m, n, particulas, n_iteracoes, alternativa_produtos)
  N=particulas*n_iteracoes;
  q=0;
  c1 = 1.4944;
  c2 = 1.4944;
  w = 0.9;
  %cria um array de 1 com a quantidade de tempo_jobs
  [~, index] = max(tempo_jobs,[],2);
  melhores_globais = index';

  %gera o custo para melhor_global, primeira iteração será 911
  melhor_global = sum(max(tempo_jobs,[],2));
  %cria uma matriz onde as linhas sao as particulas e as colunas os tempo_jobs,
  %os valores são de 1...m
  for i = 1:n
    row = find(tempo_jobs(i,:));
    melhores_locais(:,i) = row(randi(numel(row), particulas, 1));
  end
  
  %disp(melhores_locais(1,:));
  
  %inicializa o vetor das melhores soluções das particulas
  melhor_local = ones(1, particulas);
  aux_melhores = melhores_locais;
  aux_melhor = melhor_local;
  nsize = 2;
  %inicializa os tempos
  tempos = ones(n_iteracoes, 1);
  tempoFinal = 0;
  for i = 1:particulas
      %disp(i);
      %calcula o custo inicial das particulas setando para melhor_local e aux_melhor
                       %Fitness(M                    , Tij       , Oij                 , m, n)
        % SEQUENCIAMENTO - operacoes das maquinas pra cada solucao (linha de X)...
        M = cell(1, m);
        for mach=1:m;
            % Operacoes Oij (indices em X) atribuidas para a Maquina Mj em Xi
            fOper = find( melhores_locais(i, :) == mach );
            M{1,mach} = fOper;
        end; 
      melhor_local(i) = Fitness(M, tempo_jobs, alternativa_produtos, m, n);
      %if melhor_local(i) < melhor_global
      %    melhor_global = melhor_local(i);
      %    melhores_globais = melhores_locais(i, :);
      %end
      aux_melhor(i) = melhor_local(i);
  end
  for i = 1:particulas
      for k = (i-nsize-1):(i+nsize-1)
          if melhor_local(i) < aux_melhor(mod(k, particulas) + 1)
              aux_melhor(mod(k, particulas) + 1) = melhor_local(i);
              aux_melhores(mod(k, particulas) + 1, :) = melhores_locais(i, :);
          end
      end
  end
  x = melhores_locais;
  v = zeros(particulas, n);
  
  for i = 1:n_iteracoes
      %disp(i);
      fprintf('Completed  %d  %% ...', uint8(q*100/N ))
        % SEQUENCIAMENTO - operacoes das maquinas pra cada solucao (linha de X)...
        M = cell(1, m);
        for mach=1:m;
            % Operacoes Oij (indices em X) atribuidas para a Maquina Mj em Xi
            fOper = find( melhores_globais == mach );
            M{1,mach} = fOper;
        end; 
      ibest = Fitness(M, tempo_jobs, alternativa_produtos, m, n);%fitness(melhores_globais, tempo_jobs, m, n, alternativa_produtos);
      r1 = rand(particulas, 1);
      r2 = rand(particulas, 1);
      %v = w*v + c1 * bsxfun(@times, r1, melhores_locais - x) + ...
      %  c2 * bsxfun(@times, r2, (bsxfun(@minus, melhores_globais, x)));
      %disp(melhores_locais);      
      v = w*v + c1 * bsxfun(@times, r1, melhores_locais - x) + c2 * bsxfun(@times, r2, aux_melhores - x);
      
      x_aux = round(x + v);
      x_aux(x_aux < 1) = 1;
      x_aux(x_aux > m) = m;
      
      %olhar indices, talvez será necessário outro for
      for z=1:n  %for de 1 a quantidade de jobs       
      wrongs_index = find(~tempo_jobs(z,x_aux(:,z))); %acho todos os jobs que possuam tempos '0' em seus roteiros
          for w=1:length(wrongs_index) %para todos as operações erradas
            if sign(v(wrongs_index(w),z)) == 1 && ~isempty(find(tempo_jobs(z,x_aux(wrongs_index(w),z)+1:m),1)) % checo se a velocidade para essa operação é positiva
              x(wrongs_index(w),z) = x_aux(wrongs_index(w),z) + find(tempo_jobs(z,x_aux(wrongs_index(w),z)+1:m),1); %atribuo a proxima máquinas que é capaz de processar essa operação
            elseif sign(v(wrongs_index(w),z)) == -1 &&  ~isempty(find(tempo_jobs(z,1:x_aux(wrongs_index(w),z)-1),1,'last')) % verifico se é negativo
              x(wrongs_index(w),z) = find(tempo_jobs(z,1:x_aux(wrongs_index(w),z)-1),1,'last'); %atribuo um próxima máquina com número inferior
            end
          end      
      end
      
      for j = 1:particulas     
          
            % SEQUENCIAMENTO - operacoes das maquinas pra cada solucao (linha de X)...
            M = cell(1, m);
            for mach=1:m;
                % Operacoes Oij (indices em X) atribuidas para a Maquina Mj em Xi
                fOper = find( x(j, :) == mach );
                M{1,mach} = fOper;
            end; 
            c = Fitness(M, tempo_jobs, alternativa_produtos, m, n);
            %c = fitness(x(j, :), tempo_jobs, m, n, alternativa_produtos);
          if c < ibest
              ibest = c;
          end
          if c < melhor_local(j)
              melhor_local(j) = c;
              melhores_locais(j, :) = x(j, :);
              for k = (j-nsize-1):(j+nsize-1)
                  if melhor_local(j) < aux_melhor(mod(k, particulas) + 1)
                      aux_melhor(mod(k, particulas) + 1) = melhor_local(j);
                      aux_melhores(mod(k, particulas) + 1, :) = melhores_locais(j, :);
                  end
              end
          end
      q=q+1;    
      end
      tempoFinal = tempoFinal + 1;
      tempos(tempoFinal) = ibest;
      [ilbest, idx] = min(melhor_local);
      %ibest
      ilbests = melhores_locais(idx, :);
      if ilbest < melhor_global
          melhor_global = ilbest;
          melhores_globais = ilbests;
      end
  clc;
  end
  %v
  melhorSolucao = melhores_globais;
end