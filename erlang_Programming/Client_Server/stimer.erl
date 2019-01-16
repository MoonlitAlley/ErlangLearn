-module(stimer).
-export([start/2,cacel/1]).

start(Time , Fun ) ->
	spawn(fun() -> timer(Time,Fun) end ).
	
	cacel(Pid) ->Pid ! cacel.

	timer(Time , Fun) ->
		receive
			cacel ->
				void
		after Time ->
			Fun()
		end.
	