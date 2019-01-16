%%%-------------------------------------------------------------------
%%% @author admin
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 一月 2019 12:43
%%%-------------------------------------------------------------------
-module(server_genmodel).
-author("admin").
-behaviour(gen_server).

-define(SERVER , ?MODULE).

%% API
-export([start_link/0]).
%%gen_server回调函数
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2,code_change/3])).



start_link() ->
  gen_server:start_link( { local ,?SERVER} ,?MODULE , [],[]).


init([]) ->


  xxx_gen:start_link(),

  {ok,State}.

handle_call(_Request,_From,State) ->
  {reply , Reply ,State}.

handle_cast(_Msg ,State ) ->
  {noreply , State}.

handle_info(_Info , State } ->
{noreply , State}.

terminate(_Reason ,_State) ->
  ok.

code_change(_OldVsn , State, Extra) ->
  {ok , State}.
