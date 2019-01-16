-module(lib_misc).
-export([for/3]).

for(Max,Max,F) -> [F(Max)];
for(I,Max,F) -> [F(I)|for(I+1,Max,F)].

%lib_misc:for(1,10,fun(I) -> I*I end).