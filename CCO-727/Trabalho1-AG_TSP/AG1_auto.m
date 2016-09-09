% DADOS - Dataset (EIL51.tsp) e matriz de distancias do dataset
load 'eil51.tsp'
load 'dist.mat'
[d,c]=size(dist); % Dimensoes do dataset

bestPopSize = 0;
bestPc = 0.0;
bestPm = 0.0;
bestDistance = Inf;

popsize = 0;
pc = 0.00;
pm = 0.00;
for popsize=300:50:1000
%while(popsize<=950)   
    %popsize = popsize + 50;
    
    for pc=0.1:0.1:0.4
    %while(pc<0.90)
        %pc = pc + 0.05;
        
        for pm=0.1:0.1:0.9
            %pm = pm + 0.1;

            clear bestfit;
            %clear all;
            %clc;

%             % DADOS - Dataset (EIL51.tsp) e matriz de distancias do dataset
%             load 'eil51.tsp'
%             load 'dist.mat'
%             [d,c]=size(dist); % Dimensoes do dataset

            %% Parametros do AG - 
            % Refs:
            % - http://www.impactjournals.us/download.php?fname=--1391174555-4.%20Eng-Solving%20Travelling%20Salesman-Kanchan%20Rani.pdf
            % - http://www.isaet.org/images/extraimages/IJCSEE%200101308.pdf
            % - https://iccl.inf.tu-dresden.de/w/images/b/b7/GA_for_TSP.pdf
            % - http://www.obitko.com/tutorials/genetic-algorithms/recommendations.php%
            %popsize=50;
            %pc=.001; % .02, .05, .02, 
            %pm=0.5;  %  .4,  .4, .25,
            iter=1000;

            Ncities = c;
            totalDist = zeros(popsize,2);
            numberofcrossover=round(pc*popsize);
            numberofmutation=round(pm*popsize);
            numberofrec=popsize-(numberofcrossover+numberofmutation);

            %% Inicialização do AG

            % INICIO - Gerar populacao inicial
            pop = zeros(popsize, d);
            pop(1,:) = (1:d);
            for i = 2:popsize;
                pop(i,:) = randperm(d,d);
            end

            % FITNESS - Calcular aptidao de cada individuo (caminho) da populacao
            individual = 0;
            for i=1:popsize;
                % Capturar cada indivíduo da população
                individual = pop(i,:);

                % Percorrer colunas (pontos) do individuo a fim de totalizar o custo do
                % trajeto
                total = 0;
                for j=2:d;
                    total = total + dist(individual(1,j),individual(1,j-1));
                end;

                % Calcular o custo de voltar ao ponto 1
                total = total + dist(individual(1,d),individual(1,1));
                % Guardando a aptidão do indivíduo
                pop(i,c+1) = total;
            end;

            %% Ordenar populacao (distancia ascendente
            for i=1:popsize;
                for j=1:i
                    if pop(j,Ncities+1)>pop(i,Ncities+1);
                        temp=pop(i,:);
                        pop(i,:)=pop(j,:);
                        pop(j,:)=temp;
                    end
                end
            end
            
            %% Percorrer geracoes 
            for i=1:iter
            %i = 0;
            %while (pop(1,Ncities+1)>465)
                %i = i+1;

                %% Selecao para o cruzamento (crossover)
                selected=[];
                for j=1:numberofrec
                    selected(j,:)=pop(j,:);
                end  
                %%% Fim da selecao

                %% Crossover
                randElm=randperm(popsize);
                for j=1:numberofcrossover;
                       individualsForCross(j,:)=pop(randElm(j),1:Ncities);
                end  
                
                % crossover dos pais 1 e 2
                offspringset=[];    
                for z=1:numberofcrossover;

                    n_parent1=ceil(numberofcrossover*rand);
                    n_parent2=ceil(numberofcrossover*rand);
                    parent1=individualsForCross(n_parent1,:);
                    parent2=individualsForCross(n_parent2,:);

                    crossoverpoint=ceil((Ncities-1)*rand);

                    parent12=parent1(1:crossoverpoint);
                    parent21=parent2(1:crossoverpoint);

                    s1=[];
                    s2=[];

                    for j=1:numel(parent1)

                        if sum(parent1(j)~=parent21)==numel(parent21);
                            s2=[s2 parent1(j)];
                        end

                        if sum(parent2(j)~=parent12)==numel(parent12);
                            s1=[s1 parent2(j)];
                        end

                    end

                    offspring1=[parent12 s1];
                    offspring2=[parent21 s2];

                    % FITNESS - Avaliar fitness dos cruzamentos
                    offspring1(Ncities+1)=0;
                    for j=2:(Ncities-1);
                        offspring1(Ncities+1)=offspring1(Ncities+1)+ dist(offspring1(1,j),offspring1(1,j-1)); 
                    end;
                    offspring1(Ncities+1) = offspring1(Ncities+1) + dist(offspring1(1,Ncities),offspring1(1,1)); % Calcular o custo de voltar ao ponto 1

                    offspring2(Ncities+1)=0;
                    for j=2:(Ncities-1);
                        offspring2(Ncities+1)=offspring2(Ncities+1)+ dist(offspring2(1,j),offspring2(1,j-1)); 
                    end;
                    offspring2(Ncities+1) = offspring2(Ncities+1) + dist(offspring1(1,Ncities),offspring2(1,1)); % Calcular o custo de voltar ao ponto 1

                    % Atualizando conjunto de cruzamentos
                    offspringset=[offspringset;offspring1;offspring2];

                end
                %%% Fim do crossover

                %% Mutacao
                % Selecionando um individuo base pra mutacao
                randElm=randperm(popsize);    
                for j=1:numberofmutation
                    individualsForMutation(j,:)=pop(randElm(j),1:Ncities);
                end
                
                % realizando mutacao
                Mutatedset=[];
                for z=1:numberofmutation

                    parent=individualsForMutation(z,:);

                    mutationPoint1=ceil(Ncities*rand);
                    mutationPoint2=ceil(Ncities*rand);

                    temp=parent(mutationPoint1);
                    parent(mutationPoint1)=parent(mutationPoint2);
                    parent(mutationPoint2)=temp;

                    % FITNESS - Calcular aptidao dos membros mutados
                    parent(Ncities+1)=0;
                    for j=2:(Ncities-1);
                        parent(Ncities+1)=parent(Ncities+1)+ dist(parent(1,j),parent(1,j-1)); 
                    end;
                    parent(Ncities+1) = parent(Ncities+1) + dist(parent(1,Ncities),parent(1,1)); % Calcular o custo de voltar ao ponto 1

                    % Atualizar conjunto de dados mutados
                    Mutatedset=[Mutatedset;parent];

                end
                %%% Fim da mutacao...

                % Nova populacao
                pop2=[selected;offspringset;Mutatedset];
                % Ordenar nova população (distancia ascendente)
                for z=1:size(pop)
                    for j=1:z
                        if pop(j,Ncities+1)>pop(z,Ncities+1)
                            temp=pop(z,:);
                            pop2(z,:)=pop(j,:);
                            pop2(j,:)=temp;
                        end
                    end
                end

                % Atualizando populacao
                for j=1:popsize
                    pop(j,:)=pop2(j,:);
                end
                % Melhor rota
                bestfit(i)=pop(1,Ncities+1);

                % Media das distancias...
                mean=0;
                for j=1:popsize
                   mean=mean+pop(j,Ncities+1);
                end
                meanfit(i)=mean/popsize;    

                disp(strcat('(Popsize=',num2str(popsize),',Pc=',num2str(pc),',Pm=',num2str(pm),') Gen: ',num2str(i),' - Min. Dist: ',num2str(min(bestfit))));
                
            end   

            % % Resultados...
             bestRoute=pop(1,1:Ncities);
             minDistance=pop(1,Ncities+1);
            % disp(strcat('Best route: ',num2str(bestRoute)));
            % disp(strcat('Min. Dist: ',num2str(minDistance)));
            % 
            % % Plotando detalhes e melhor rota...
            % figure();
            % subplot(2,2,1:2);
            % route = bestRoute([1:Ncities 1]);
            % plot(route',route','r.-'); % Caminho
            % plot(eil51(route,2),eil51(route,3),'r.-'); % Pontos (cidades)        
            % % Detalhe1 - Comportamento dos melhores caminhos...
            % subplot(2,2,3);
            % plot(bestfit,'.r')
            % % Detalhes2 - Comportamento das medias a cada geração...
            % subplot(2,2,4);
            % plot(meanfit);


            if minDistance < bestDistance
                bestDistance = minDistance;
                bestPopSize = popsize;
                bestPc = pc;
                bestPm = pm;
            end;
        end;
        
    end;
    
end;

disp(strcat('Best popsize: ',num2str(bestPopSize)));
disp(strcat('Best Pc: ',num2str(bestPc)));
disp(strcat('Best Pm: ',num2str(bestPm)));