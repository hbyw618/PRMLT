function [model, llh] = rvmFast(X, t)
% Relevance Vector Machine (ARD sparse prior) for regression 
% training by empirical bayesian (type II ML) using Coordinate Descent
% reference: (Fast RVM)
% Tipping and Faul. Fast marginal likelihood maximisation for sparse Bayesian models. AISTATS 2003.

xbar = mean(X,2);
tbar = mean(t,2);
X = bsxfun(@minus,X,xbar);
t = bsxfun(@minus,t,tbar);

maxiter = 1000;
tol = 1e-4;
llh = -inf(1,maxiter);


[globalParam, localParam] = initParam(X, t);
for iter = 2:maxiter
    llh(iter) = calcLlh(globalParam, localParam);
    if abs(llh(iter)-llh(iter-1)) < tol*llh(iter-1); break; end
    switch act
        case 1
            localParam = addLocalParam(globalParam, localParam);
        case 2
            localParam = delLocalParam(globalParam, localParam);
        case 3
            localParam = updLocalParam(globalParam, localParam);
        otherwise
            error('error');
    end
    globalParam = updGlobalParam(globalParam, localParam);
    
end






function [globalParam, localParam] = initParam(X, t)

X2 = dot(X,X,2);   
Xt = X*t';
[v,j] = max(Xt.^2./X2);

beta = 1/mean(t.^2);   % Beta = 1/sigma^2
phi = X(j,:);
alpha = X2(j)/(v-1/beta);
sigma = 1/(alpha + beta*(phi'*phi));
mu = beta*sigma*phi*t';




globalParam = packGlobalParam(Beta, Q, S);
localParam = packLocalParam(j, alpha, mu, sigma);




function llh = calcLlh(globalParam, localParam)
[Beta, Q, S] = unpackGlobalParam(globalParam);
[index, Alpha, Mu, Sigma] = unpackLocalParam(localParam);



function [globalParam, localParam] = addLocalParam(j, globalParam, localParam)
[Beta, Q, S, X] = unpackGlobalParam(globalParam);
[index, Alpha, Mu, Sigma, Phi] = unpackLocalParam(localParam);

phi = X(j,:);
alpha = s(j)^2/theta(j);
sigma = 1/(alpha+S(j));
mu = sigma*Q(j);
             
% local
v = Beta*Sigma*(Phi*phi'); 
off = -Beta*sigma*v;
Sigma = [Sigma+sigma*(v*v'), off; off', sigma];
Mu = [Mu-mu*v; mu];
index = [index,j];
Alpha = [Alpha,alpha];

% global
e = phi-v'*Phi;
v = Beta*X*e';
S = S-sigma*v.^2;
Q = Q-mu*v;



localParam = packLocalParam(index, Alpha, Mu, Sigma);


function localParam = delLocalParam(j, globalParam, localParam)
[Beta, Q, S] = unpackGlobalParam(globalParam);
[index, Alpha, Mu, Sigma] = unpackLocalParam(localParam);


localParam = packLocalParam(index, Alpha, Mu, Sigma);



function localParam = updLocalParam(j, globalParam, localParam)
[Beta, Q, S] = unpackGlobalParam(globalParam);
[index, Alpha, Mu, Sigma] = unpackLocalParam(localParam);


localParam = packLocalParam(index, Alpha, Mu, Sigma);


function globalParam = updGlobalParam(globalParam, localParam)
[Beta, Q, S] = unpackGlobalParam(globalParam);





globalParam = packGlobalParam(Beta, Q, S);

function localParam = packLocalParam(Index, Alpha, Mu, Sigma, Phi)
localParam.Index = Index;
localParam.Alpha = Alpha;
localParam.Mu = Mu;
localParam.Sigma = Sigma;
localParam.Phi = Phi;

function [Index, Alpha, Mu, Sigma] = unpackLocalParam(localParam)
Index = localParam.Index;
Alpha = localParam.Alpha;
Mu = localParam.Mu;
Sigma = localParam.Sigma;


function globalParam = packGlobalParam(Beta, Q, S, X)
globalParam.Beta = Beta;
globalParam.Q = Q;
globalParam.S = S;
globalParam.X = X;


function [Beta, Q, S, X] = unpackGlobalParam(globalParam)
Beta = globalParam.Beta;
Q = globalParam.Q;
S = globalParam.S;
X = globalParam.X;