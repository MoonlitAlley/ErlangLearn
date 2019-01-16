%%%-------------------------------------------------------------------
%%% @author admin
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 一月 2019 12:46
%%%-------------------------------------------------------------------
-module(dets_test).
-author("admin").

%% API
-export([]).

init(File) ->
    Bool = filelib:is_file(File),
    case dets:open_file(?MODULE,{}) of