%Este fitness do PSO na verdade é outro algoritmo (SA), trabalhando para
%converter os encodes baseado em operações, para um encode baseado em
%máquina e assim processar seus tempos no fitnessSA (que na verdade é a aptidão de todo o sistema)
function [minbestSolCost, bestSchedule] = fitnessG(S, tempo_jobs, m, n, iterationsAtTemp, sT, ...
                               alpha, Fitness, ...
                               gerar_vizinho,alternativa_produtos,n_iteracoesSA,leveis,Tend)
                           
  %inicializa os custos, final e vetor de custos                  
  costsEnd = 0;
  costs = zeros(1,(n_iteracoesSA*iterationsAtTemp));
  %roteiro = [2 5 6     3 4 7 5     7 4 1   2 6 3   1 7 6 7      3 8 2      3 8 4   1 2 8 3];

  %variáveis de controle do procedimento de criação de todas as permutações
  %possíveis dos níveis
  opcoes = cell(1, m);
  total = 1;
  
  %o procedimento abaixo gera a partir de um roteiro de operações em níveis, todas os roteiros
  %possíveis das combinações destes níveis expressados em tempos, ou seja, se uma mesma operação
  %de nivel 1 possuir 2 máquinas com tempos iguais, teremos já de antemão 2
  %roteiros possíveis se todas as outras operações possuirem níveis com
  %apenas 1 máquina
  for i=1:n
    opcoes{i} = find(S(1,i));%==leveis(i,:));
    total = total * length(opcoes{i}) ; % 3
  end
    repeticoes = total; %3
    MS = zeros(total,n);
  for i=1:n 
    coluna = zeros(total,1);
    repeticoes = repeticoes/length(opcoes{i}); %1
    if total == repeticoes
      permutacoes = length(opcoes{i});
    else
      permutacoes = total/repeticoes; %3
    end
    for j=1:permutacoes
      intervalo_inicio = repeticoes*(j-1)+1;
      intervalo_fim = (repeticoes*(j-1))+repeticoes;
      coluna(intervalo_inicio:intervalo_fim,1) = opcoes{1,i}(mod(j-1,length(opcoes{i}))+1);
    end
    MS(:,i) = coluna;     
  end
  bestSolCost = zeros(total,1);  
  
  %para cada roteiro gerado é necessário avaliar sua aptidão
  for z=1:total 
      %transforma em um encode baseado em máquina
      k = cell(1, m);
      for i=1:m
        k{i} = find(MS(z,:)==i);
      end
      
      %já atribui um melhor valor com o roteiro do jeito que está de início
      bestSol = k;
      disp(k);
      bestSolCost(z,1) = Fitness(k, tempo_jobs, alternativa_produtos, m, n);%fitnessSA(tempo_jobs, m, alternativa_produtos,k);
      %se o roteiro der deadlock (tiver errada a precendencia das
      %operações), força gerar um novo sequenciamento
      while bestSolCost(z,1) == 0 
          k = gerar_vizinho(bestSol, m);
          bestSolCost(z,1) = Fitness(k, tempo_jobs, alternativa_produtos, m, n);%fitnessSA(tempo_jobs, m, alternativa_produtos,k);
      end
      
      %variavel que ira permutar a sequenciação do roteiro inicialmente
      acceptedSol = k;
      acceptedSolCost = bestSolCost(z,1);
      %temperatura do SA
      T = sT;
      
      
      %enquanto a temperatura for maior que a definida faça
      while T > Tend
      %é necessário repetir o procedimento x vezes na mesma temperatura para garantir a distinção dos resultados
        for i=1:iterationsAtTemp
          %gera uma nova sequenciação e já avalia sua aptidão
          newSol = gerar_vizinho(acceptedSol, m);
          newSolCost = Fitness(newSol, tempo_jobs, alternativa_produtos, m, n);%fitnessSA(tempo_jobs, m, alternativa_produtos,newSol);      
          %se der deadlock, força uma nova sequenciação
          while newSolCost == 0 
              newSol = gerar_vizinho(acceptedSol, m);
              newSolCost = Fitness(newSol, tempo_jobs, alternativa_produtos, m, n);%fitnessSA(tempo_jobs, m, alternativa_produtos,newSol);             
          end
          %verifica se houve melhora, e mesmo se não houve, com uma
          %probabilidade a solução é atualizada
          deltaCost = newSolCost - acceptedSolCost;
          if deltaCost < 0
            acceptedSol = newSol;
            acceptedSolCost = newSolCost;
          else
            randVal = rand(1);
            p = exp(-1*deltaCost / T);
            if p > randVal
              acceptedSol = newSol;
              acceptedSolCost = newSolCost;
            end
          end

          %grava o valor no vetor de custos
          costsEnd = costsEnd + 1;
          costs(costsEnd) = acceptedSolCost;

          %Atualiza o melhor custo
          if acceptedSolCost < bestSolCost(z,1)
             bestSolCost(z,1) = acceptedSolCost;
          end
        end
        T = T * alpha; % resfriamento do SA
      end
  end
  [minbestSolCost, index] = min(bestSolCost);
  bestSchedule = MS(index,:);
end
