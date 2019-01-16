-module(event_handler).
-export([make/1,add_handler/2,event/2]).
%%制作一个名为Name的新事件处理器
%%处理函数是no_op，代表不对事件做任何处理
make(Name) ->
	register(Name , spawn(fun() -> my_handler(fun no_op/1) end)).
	
add_handler(Name , Fun )->
	Name ! {add , Fun}.
%生成一个事件
event(Name , X) -> Name ! {event ,X}.

my_handler(Fun) ->
	receive
		{add , Fun1} ->
			my_handler(Fun1);
		{event , Any} ->
			(catch Fun(Any)),
			my_handler(Fun)
	end.

no_op(_) -> void.