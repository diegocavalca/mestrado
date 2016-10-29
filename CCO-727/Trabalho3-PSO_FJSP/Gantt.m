%abaixo est� um exemplo de uma sequencia��o em tmepos, e o tamanho do vetor
%de m�quinas;

%gantt = [0 3 3 5 6 7 0 0 0 0; 0 1 1 4 5 9 9 14 0 0; 0 1 1 3 3 6 6 8 11 14; 2 6 6 8 10 13 0 0 0 0; 4 7 10 14 0 0 0 0 0 0; 1 6 7 9 9 11 0 0 0 0; 0 2 3 9 9 10 11 14 0 0; 1 5 5 10 10 11 0 0 0 0];
m = 8;
V = (1:m);
slots = gantt;

for i = length(slots(1,:)):-1:2
    for j = 1:1:length(slots(:,1))
        if slots(j,i) > 0
           slots(j,i) = slots(j,i)-slots(j,i-1); 
        end
    end
end

figure;
h = barh(V,slots,'stacked','LineStyle',':');
set(h, 'FaceColor', [1,1,1]);
set(h, 'EdgeColor', [0,0,0]);
title('Grafico de Gantt');
xlabel('Time');
ylabel('Machines');
set(gca, 'YDir', 'reverse');
set(gca, 'YTick', 1:1:length(V));


for i = 1:1:length(gantt(1,:))
    if mod(i,2) ~= 0
        set(h(i),'FaceColor',[0.8 0.8 0.8]); 
    end
end

for i=1:length(gantt_op(:,1))
    length_op = sum(~cellfun(@isempty,gantt_op(i,:)));
    for j=1:length_op        
        indice = (((gantt(i,(j-1)*2+1)+gantt(i,(j-1)*2+2))/2)-0.4);        
        text(indice,i,gantt_op(i,j))
    end
end

