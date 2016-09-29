function [path,cost] = LocalSearch(path,distances)


% ============================ Code Description ========================= %
%             2-opt algorithm for tour improvement procedure              %
% ======================================================================= %
%
% The 2-opt search is one of various local search that is simple and famous 
% to improve the solution executing on neighborhood search.  In addition, it  
% can be found the locally optimal solution (see Croes, 1958).  However, this
% version of 2-opt heuristic is originally coded by Nuhoglu (2007).
%
%
% Reference:
%
% Croes, G.A. (1958). A method for solving traveling salesman problems. 
%        Operations Research, 6: 791-812.
% Nuhoglu, M. (2007). Shortest path heuristics (nearest neighborhood, 2 opt, 
%        farthest and arbitrary insertion) for travelling salesman problem.  
%        Available Source: http://snipplr.com/view/4064/shortest-path-heuristics-
%        nearest-neighborhood-2-opt-farthest-and-arbitrary-insertion-for-travelling-
%        salesman-problem/
%
% --------------------------------------------------------------------
%
% Modified by: Wantchapong Kongkaew
%              Department of Industrial Engineering, Faculty of Engineering,
%              Kasetsart University, Thailand.
% Date: January 20, 2012 
% 
% ======================================================================= %



global n 
n = length(path);

for i=1:n
    for j=1:n-3
        if change_in_distance(path,i,j,distances) < 0 
            path = swap_edge(path,i,j);
        end
    end
end
cost = Fitness(path,distances);


 % Additional subfunctions for solving via 2-Opt algorithm (Croes, 1958)

function result = change_in_distance(path,i,j,distances)
before=distances(path(r(i)),path(r(i+1)))+distances(path(r(i+1+j)),path(r(i+2+j)));
after=distances(path(r(i)),path(r(i+1+j)))+distances(path(r(i+1)),path(r(i+2+j)));
result=after-before;

function path = swap_edge(path,i,j)
old_path=path;
 % exchange edge cities
path(r(i+1))=old_path(r(i+1+j));
path(r(i+1+j))=old_path(r(i+1));
 % change direction of intermediate path 
for k=1:j-1
    path(r(i+1+k))=old_path(r(i+1+j-k));
end

  % if index is greater than the path length, turn index one round off
function result = r(index)
global n
if index > n
    result = index - n;
else
    result = index;
end