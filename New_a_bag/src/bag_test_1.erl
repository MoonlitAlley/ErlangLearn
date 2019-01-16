%%%-------------------------------------------------------------------
%%% @author songsaifei
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 实现背包中物品的：增加、删除、修改、查找、排序（按照ID/按照NUM）
%%% @end
%%% 叠加 / 拆分 多个物品在格子里
%%% Created : 05. 一月 2019 15:07
%%%-------------------------------------------------------------------
-module(bag_test).
-author("songsaifei").
%% API
-export([ start/2, add_good/2 , delete_good/2 , change_good/2 , find_element/2,sort_Num/1]).

-record(bag,{
  cap =10,
  goods = []
}).
-record(good,{
  id,
  name,
  num = 1,
  des
}).

-define(MAX_CAP, 10).

%Func -> 标识对应的函数 ， Good ->要操作的数据
start( Func , Good) ->
  %数据初始化
  Sword = #good{id = 00001 ,name = "The Sword in the Stone" , num =1,des = "the blade of legend" },
  MpBottle = #good{id = 00002 ,name ="bukeberry" , num =1,des = "this is a magic renew" },
  GodFace = #good {id = 00003 ,name = "wakan" ,  num = 2 , des = "legend material" },

  Mybag = #bag{},

%选择需要执行的操作
  case Func of
    add_good  ->
      case Good of
        %将第一个物品转入背包
        1 ->
          Mybag1 = add_good(Mybag,Sword),
          Mybag1;
        %将第二个物品转入背包
        2->
          Mybag1 = add_good(Mybag,MpBottle),
          Mybag1;
        %将第三个物品转入背包
        3->
          Mybag1 = add_good(Mybag,GodFace),
          Mybag1;
        %全部装入背包中
        4 ->
          %用列表推导来完成，作用于每个函数。
          Mybag1 = add_good(Mybag,Sword),
          Mybag2 = add_good(Mybag1,MpBottle),
          Mybag3 = add_good(Mybag2,GodFace),
          Mybag3
      end;
    delete_good ->
      case Good of
        1 ->
          _Mybag1 = delete_good(Mybag,Sword);
        2 ->
          _Mybag1 = delete_good(Mybag,MpBottle);
        3 ->
          _Mybag1 = delete_good(Mybag,GodFace);
        4 ->
          Mybag1 = delete_good(Mybag,Sword),
          Mybag2 = delete_good(Mybag1,MpBottle),
          Mybag3 = delete_good(Mybag2,GodFace),
          Mybag3
      end

    %其他操作相同
  end.


%添加物品 ->单元测试通过
add_good( #bag{ cap = Cap, goods = GoodList } = Mybag ,  Good)->
  %背包中是否有相同物品， 若有-> 修改num \若无 -> 增加物品，修改Cap
  #good{ id = X } = Good,
  case lists:keyfind(X ,#good.id , GoodList ) of
    #good{num = Count} = TempGood when Count > 1 ->
      %找到相应的Good,修改num
%%      TempGood = find_element(Mybag,Good),
%%
%%      #good{num = Count} = TempGood,
      #good{num = Count1} = Good,
      TempGood1 = TempGood#good{ num =Count +Count1 },

      Mybag1 = change_good(Mybag,TempGood1),
      Mybag1;
    false ->
      xxx;
    _ ->
      %没有找到相应的物品
      Mybag1 = #bag{ cap = Cap-1, goods = [ Good | GoodList ] },
      Mybag1
  end.


%删除   ->单元测试通过
delete_good(#bag{ cap = Cap, goods = GoodList } = Mybag , Good ) ->
  #good{ id = X }  = Good,
  %是否存在于背包中
  case lists:keymember(X ,#good.id , GoodList ) of
    false ->
      io:format("there is no this element~n"),
      Mybag ;
    true ->
      TempList = lists:keydelete( X , #good.id , Mybag#bag.goods ),
      Mybag1 = #bag{ cap = Cap+1, goods = TempList },
      Mybag1
  end.


% 修改   ->单元测试通过
change_good( #bag{ cap = Cap, goods = GoodList } = Mybag ,Good) ->
  #good{ id = X }  = Good,
  %是否存在于背包中

  case lists:keymember(X ,#good.id , GoodList ) of
    false ->
      io:format("there is no this element~n"),
      Mybag ;
    true ->
      %物品存在于背包中 -> 修改数量 、数量为0时删除
      #good{ num = Count1 } = Good,
      case Count1 of
         Count1 when Count1=<0 ->
            Mybag1 = delete_good(Mybag,Good),
            Mybag1;
        Count1 when Count1>0 ->
            TempList = lists:keyreplace(X,#good.id,GoodList, Good),
            Mybag1 = #bag{ cap = Cap, goods = TempList },
            Mybag1
      end

  end.

%查找   ->单元测试通过
find_element( #bag{goods = GoodList} = _Mybag , Good) ->
  #good{id = X} = Good,

  case lists:keymember(X, #good.id , GoodList) of
      true ->
          TempGood = lists:keyfind(X , #good.id  , GoodList),
          TempGood;
      false ->
        io:format("there is no this element~n")
  end.

%整理背包   -> 按照ID排序
% 默认已按照ID排序

%整理背包  -> 按照num排序  ->单元测试通过
sort_Num(#bag{goods = GoodList} = Mybag) ->
  TempList = lists:keysort(#good.num , GoodList),
  Mybag1 = Mybag#bag{goods = TempList},
  Mybag1.






