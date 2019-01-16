-module(server4).
-export([start/2,rpc/2,swap_code/2]).

start(Name , Mod) ->
	register( Name , spawn(fun() -> loop(Name , Mod , Mod:init() ) end )).
	
swap_code(Name , Mod) ->
	rpc(Name , {swap_code , Mod}).
	
rpc(Name , Request) ->
	Name ! {self() , Request},
	receive
		{Name ,crash } -> exit(rpc);
		{Name , ok , Response} -> Response
		
	end.
	
loop(Name , Mod , OldState) ->
	receive
		{From , {swap_code , NewCallBackMod}} ->
			From ! {Name ,ok ,ack},
			loop(Name , NewCallBackMod , OldState);
		{From , Request}->
			try Mod:handle(Request ,OldState) of
				{Response ,NewState} ->
					From ! {Name , ok , Response},
					loop(Name , Mod , NewState)
			catch
				_:Why ->
					log_the_error(Name , Request ,Why),
					%%发送一个消息来让客户端崩溃
					From ! {Name , crash} ,
					%%以初始状态继续循环
					loop(Name , Mod , OldState)
			end
	end.

log_the_error(Name , Request , Why) ->
	io:format("Server ~p requester ~p ~n"
		"caused exception ~p~n",
		[Name , Request , Why]).