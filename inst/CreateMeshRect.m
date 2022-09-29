## Copyright (C) 2020 Andreas Stahel
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{function file}{}Mesh = CreateMeshRect(@var{x},@var{y},@var{Blow},@var{Bup},@var{Bleft},@var{Bright})
##
##   Create a mesh on a rectangle with nodes at (x_i,y_j)
##
##parameters:
##@itemize
##@item @var{x},@var{y} are the vectors containing the coodinates of the mesh nodes to be generated.
##@item@var{Blow}, @var{Bup}, @var{Bleft}, @var{Bright} indicate the type of boundary condition at lower, upper, left and right edge of the rectangle
##@* B* = -1: Dirichlet boundary condition
##@* B* = -2: Neumann or Robin boundary condition
##@end itemize
##
##return value
##@itemize
##@item @var{Mesh} is a a structure with the information about the mesh.
##@*The mesh consists of n_e elements, n_n nodes and n_ed edges.
##@itemize
##@item@var{Mesh.type} a string with the type of triangle: linear
##@item@var{Mesh.elem} n_e by 3 matrix with the numbers of the nodes forming triangular elements
##@item@var{Mesh.elemArea} n_e vector with the areas of the elements
##@item@var{Mesh.elemT} n_e vector with the type of elements (not used)
##@item@var{Mesh.nodes} n_n by 2 matrix with the coordinates of the nodes
##@item@var{Mesh.nodesT} n_n vector with the type of nodes (not used)
##@item@var{Mesh.edges} n_ed by 2 matrix with the numbers of the nodes forming edges
##@item@var{Mesh.edgesT} n_ed vector with the type of edge
##@item@var{Mesh.GP} n_e*3 by 2 matrix with the coordinates of the Gauss points
##@item@var{Mesh.GPT} n_e*3 vector of integers with the type of Gauss points
##@item@var{Mesh.nDOF} number of DOF, degrees of freedom
##@item@var{Mesh.node2DOF} n_n vector of integer, mapping nodes to DOF
##@end itemize
##@end itemize
##
## Sample call:
##@verbatim
##Mesh = CreateMeshRect(linspace(0,1,10),linspace(-1,2,20),-1,-1,-2,-2)
##         will create a mesh with 200 nodes and 0<=x<=1, -1<=y<=+2
##@end verbatim
## @c Will be cut out in ??? info file and replaced with the same
## @c references explicitly there, since references to core Octave
## @c functions are not automatically transformed from here to there.
## @c BEGIN_CUT_TEXINFO
## @seealso{CreateMeshTriangle, BVP2D, BVP2Dsym, BVP2eig}
## @c END_CUT_TEXINFO
## @end deftypefn

## Author: Andreas Stahel <andreas.stahel@gmx.com>
## Created: 2020-03-30


function mesh = CreateMeshRect(x,y,Blow,Bup,Bleft,Bright)

if (nargin ~=6 ) print_usage(); endif
n = length(x);   m = length(y);

%===================== nodes =======================================
[xx,yy] = meshgrid(x,y);
nodes = [xx'(:), yy'(:), ones(n*m,1)];

%for im = 1:m
%  nodes((im-1)*n+1,3) = Bleft;
%  nodes(  im*n    ,3) = Bright;
%endfor  
nodes([0:m-1]*n+1,3) = Bleft;
nodes([1:m]*n    ,3) = Bright;

if (Bleft  == -1)  instart = 2;       else instart = 1; endif 
if (Bright == -1)  inend   = (n-1);   else inend   = n; endif

%%for in = instart:inend
%%  nodes(in,        3) = Blow;
%%  nodes((m-1)*n+in,3) = Bup;
%%endfor
nodes([instart:inend]        ,3) = Blow;
nodes([instart:inend]+(m-1)*n,3) = Bup;

%======================= elements =====================================
%% all triangles have a positive orientation
elem = zeros((n-1)*(m-1)*2,4);
cc = 1;
for row = 1:m-1
  for col = 1:n-1
    elem(cc,:) = [(row-1)*n+col,row*n+col+1    ,row*n+col  ,1];
    cc++;
    elem(cc,:) = [(row-1)*n+col,(row-1)*n+col+1,row*n+col+1,1];
    cc++;
  endfor
endfor
%========================= edges ===================================

edges = zeros(2*(n+m-2),3);
cc = 1;
for in = 1:n-1
  edges(cc,1:3) = [in,in+1,Blow];
  cc++;
endfor

for in = 1:n-1
  edges(cc,1:3) = [(m-1)*n+in,(m-1)*n+in+1,Bup];
  cc++;
endfor

for im = 1:m-1
  edges(cc,1:3) = [(im-1)*n+1,im*n+1,Bleft];
  cc++;
endfor

for im = 1:m-1
  edges(cc,1:3) = [im*n,(im+1)*n,Bright];
  cc++;
endfor

%% determine area of elements and the GP (Gauss integration Points)
nElem = size(elem)(1);
elemArea = zeros(nElem,1);
GP = zeros(3*nElem,2); mesh.GPT = zeros(3*nElem,1);
%% for each element
for ne = 1:nElem
  v0 = nodes(elem(ne,1),1:2);
  v1 = nodes(elem(ne,2),1:2) - v0;
  v2 = nodes(elem(ne,3),1:2) - v0;
  GP(3*ne-2,:) = v0 + v1/6   + v2/6;
  GP(3*ne-1,:) = v0 + v1*2/3 + v2/6;
  GP(3*ne,:)   = v0 + v1/6   + v2*2/3;
  elemArea(ne) = abs(det([v1;v2]))/2;
endfor

mesh.type   = 'linear';
mesh.elem   = elem(:,[1 2 3]);
mesh.elemT  = elem(:,4);
mesh.edges  = edges(:,[1 2]);
mesh.edgesT = edges(:,3);
mesh.nodes  = nodes(:,[1 2]);
mesh.nodesT = nodes(:,3);
mesh.GP = GP;
mesh.elemArea = elemArea;

%%mesh.nDOF = 0;
%%ln = size(mesh.nodes)(1);
%%mesh.node2DOF = zeros(ln,1);
%%for k = 1:ln
%%  if (mesh.nodesT(k)~=-1)
%%    mesh.nDOF++;
%%    mesh.node2DOF(k) = mesh.nDOF; 
%%  endif
%%endfor
ind = (mesh.nodesT~=-1);
mesh.node2DOF = cumsum(ind).*ind;
mesh.nDOF = sum(ind);
endfunction
