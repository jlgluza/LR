(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* Auxiliary function to get dimension of  a parameter *)
DimensionParameter=DeleteCases[DimensionParameter,1,{3}];
getDimPar[x_]:=Block[{pos},
pos=Position[DimensionParameter,x][[1,1]];
Return[DimensionParameter[[pos]][[2]]];
];


(* Translating parameters  so that they can be used with NDSolve *)
(* g1 -> g1[t], ..., Yd -> {{Yd[1,1][t],0,0},{0,Yd[2,2][t],0},{0,0,Yd[3,3]}}, .. *)

subParameters={};
AllParameters={};
dim=DimensionParameter;
For[i=1,i<=Length[dim],
Switch[Length[dim[[i,2]]],
0,
	(* For scalars *)
	subParameters=Join[subParameters,{dim[[i,1]]->dim[[i,1]][t]}];
	AllParameters=Join[AllParameters,{dim[[i,1]]}];,
1,
	(* For vectors *)
	subParameters=Join[subParameters,{dim[[i,1]]->Table[dim[[i,1]][i1][t],{i1,1,dim[[i,2,1]]}]}];
	AllParameters=Join[AllParameters,Table[dim[[i,1]][i1],{i1,1,dim[[i,2,1]]}]];,
2,
	(* For matrices; including check of off-diagonal terms should be included *)
subParameters=Join[subParameters,{dim[[i,1]]->Table[If[i1==i2 || IncludeOffDiagonal===True,dim[[i,1]][i1,i2][t],0],{i1,1,dim[[i,2,1]]},{i2,1,dim[[i,2,2]]}]}];
AllParameters=Join[AllParameters,Table[If[i1==i2|| IncludeOffDiagonal===True,dim[[i,1]][i1,i2],0],{i1,1,dim[[i,2,1]]},{i2,1,dim[[i,2,2]]}]];
];
i++;];


(* Flatten the list and remove 0's (which correspond to off-diagonal terms set to zero above) *)
AllParameters=DeleteCases[Flatten[AllParameters],0];


(* Some rules to expand the matrix manipulations *)
subExpandRGEs = {trace[a__]:>Tr[Dot[a]],ScalarProd->Dot, MatMul->Dot,Adj[x_]:>Transpose[Conjugate[x]],Tp[x_]:>Transpose[x], conj->Conjugate};

(* Preparing Equations*)
AllEquations={};
For[i=1,i<=Length[AllRGEs],
(* Check if parameters includes generation indices; in that case create a substitution to rename the indices to i1, i2 *)
If[Head[AllRGEs[[i,1]]]=!=Symbol,
list=List@@AllRGEs[[i,1]];
sub=Table[list[[j]]->ToExpression["i"<>ToString[j]],{j,1,Length[list]}];,
sub={};
];
(* temporary, modified version of the beta-function *)
temp=Log[10] *(AllRGEs[[i,2]] /. subParameters//. subExpandRGEs //. sub );
(*temp=Log[10] *(AllRGEs[[i,2]] /. subParameters//. subExpandRGEs //. sub /. pi -> 1. Pi);*)
dim=getDimPar[AllRGEs[[i,1]] /. A_[b___]->A];
(* check for the dimension of the parameter and add a beta-function for each entry *)
Switch[Length[dim],
0,
	(* scalars *)
	AllEquations=Join[AllEquations,{(AllRGEs[[i,1]]'[t] ) ==temp /. i1->jj1 //. A_List[b__Integer]:>A[[b]]}];,
1,
	(* vectors *)
	For[jj1=1,jj1<=dim[[1]],
	AllEquations=Join[AllEquations,{(AllRGEs[[i,1]]'[t]//. sub /. i1->jj1) ==temp /. i1->jj1 //. A_List[b__Integer]:>A[[b]]}];
	jj1++;];,
2,
	(* matrices *)
	For[jj1=1,jj1<=dim[[1]],
	For[jj2=1,jj2<=dim[[2]],
	If[jj1==jj2 || IncludeOffDiagonal===True,AllEquations=Join[AllEquations,{(AllRGEs[[i,1]]'[t] //. sub/. {i1->jj1, i2->jj2}) ==(temp /. {i1->jj1,i2->jj2} )//. A_List[b__Integer]:>A[[b]]}];
];
	jj2++;];
	jj1++;];
];
i++;];




(* Function to run RGEs *)
RunRGEs[input_,start_,finish_,twoloop_:False]:=Block[{init,subTL},
If[twoloop===False,subTL={1/pi^4->0, pi->1. Pi};,subTL={ pi->1. Pi};];
init={};
For[i=1,i<=Length[AllParameters],
(* All values which don't get an initializaiton value from the user are initialized with 0 *)
init=Join[init,{AllParameters[[i]][start]==(AllParameters[[i]] /. input /. (AllParameters[[i]]->0))}];
i++;];
equations=Join[AllEquations ,init]/.subTL;

sol=NDSolve[equations,AllParameters,{t,start,finish}];
Return[sol];
];




Print["Running of RGEs provided by pyR@te is ready !"];
Print[""];
Print["Usage:"];
Print["RunRGEs[input values, Log of scale where running starts, Log of scale where running finishes,True/False (For twoloop)]"];
Print["e.g. \:ffffRunRGEs[{g1\[Rule]0.36,g2\[Rule]0.64, g3\[Rule]0.7},3,16,False];"];


