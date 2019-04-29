function [z]=fisherz(x)

for n=1:length(x);
    z(n)=1/2*log((1+x(n))/(1-x(n)));
end

