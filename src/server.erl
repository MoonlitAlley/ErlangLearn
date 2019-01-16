%%%-------------------------------------------------------------------
%%% @author song saifei
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 一月 2019 15:58
%%%-------------------------------------------------------------------
-module(server).
-author("song saifei").

%% API
-export([start_server/0]).

-record(user,{
  socket
}).



start_server() ->
      {ok , Listen} = gen_tcp:listen( 6789 , [ binary ,{packet , 4} ,{active , true}]),
      io:format("Start Listen , Port : 6789~n"),

      %进入创建，但是无返回
      BroadCastPid = spawn(fun() -> broadcast( [] ) end),
      io:format("BroadCast in service~n"),
%%    接收并行连接
      spawn( fun() -> par_connect(Listen , BroadCastPid) end ).


par_connect(Listen ,BroadCastPid) ->
      %接受一个新客户端连接，在服务端打印，并存入在线用户列表
      {ok , Socket} = gen_tcp:accept(Listen),
      io:format("New Client : ~p~n", [Socket] ),
      BroadCastPid ! {register , Socket},
      Pid = spawn( fun() -> loop(Socket, BroadCastPid ) end),
      gen_tcp:controlling_process(Socket,Pid),
      par_connect(Listen,BroadCastPid).


%%      spawn( fun() ->par_connect(Listen,BroadCastPid) end ),
%%      loop(Socket,BroadCastPid).


loop(Socket,BroadCastPid) ->
      receive
            {tcp , Socket , Bin} ->
                  %收到客户端发来的信息
                  Str = binary_to_term(Bin),
                  io:format("Server (unpacked) ~p~n" ,[{Socket,Str}]),
                  BroadCastPid ! {msg , Socket , Str},
                  io:format("BroadCasting  ~p~n" ,[{Socket,Str}]),
                  loop(Socket,BroadCastPid);

            {tcp_closed ,Socket} ->
                  %有客户端离开，更新在线用户列表
                  BroadCastPid ! {logout , Socket},
                  io:format("Server socket closed： ~p~n",[ Socket]),
                  loop(Socket,BroadCastPid)
  end .


broadcast(UserList) ->
    %向用户列表进程索要信息
    io:format("Begin BroadCast  pattern~n" ),
    receive
          {register, Socket} ->
                User = #user{socket = Socket},
                broadcast( [User | UserList] );
          {logout , Socket } ->
                broadcast(lists:keydelete( Socket , #user.socket, UserList));
%%          {change , {Socket ,username }} ->
%%                io:format("There Function undefine");
%%                %用于给广播进程发送在线用户列表信息
          {msg, Socket ,Str} ->
                io:format("Begin BroadCast  ~p~n" ,[{Socket,Str}]),
                %广播到除自己以外的所有在线客户端
                UserListsTemp = lists:keydelete(Socket , #user.socket , UserList),
                send_msg(Str , UserListsTemp),
                io:format("after BroadCast ~p~n",[{Socket,Str}]),
                broadcast( UserList);
          _ ->
            io:format("There is nothing ~n" ),
            broadcast( UserList)
    end.
send_msg( _, []) ->
    true;
send_msg( Str,[H|T] ) ->
    Socket= H#user.socket,
    gen_tcp:send(Socket ,term_to_binary(Str)),
    send_msg(Str ,T).