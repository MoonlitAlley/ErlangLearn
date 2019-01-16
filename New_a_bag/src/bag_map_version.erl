%%%-------------------------------------------------------------------
%%% @author admin
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 一月 2019 9:35
%%%-------------------------------------------------------------------
-module(bag_map_version).
-author("admin").
%% API
-export([move_good/4,add_good/3,change_good/3,delete_good/2,find_element/2]).

-record(good,{
  id,
  num = 1,
  name,
  des
}).

%%    使用新方法
%%    Good = #good{id= 0001, num =20 , name = "", des ="" }
%%    Mybag = #{cap => 10 ,gird =>#good{}, gird =>#good{} ... }


%%将背包 GirdFrom 号格子中的物品的 Num 个移动到 GirdTo 格子中
%%  查看要操作的格子中是否是指定的物品
%%      待操作格子中有物品 ，且支持 相应数量 的操作（拆分、叠加） （不支持交换、移动）TempNumFrom < Num
%%          目标格子是否合法
%%              目标格子中有物品而且与待操作格子中的 物品id 相同  ->先拆分 后叠加
%%              目标格子中有物品而且与待操作格子中的 物品id 不相同    数量不合法不可交换
%%              目标格子没有物品  ->拆分(cap-1)
%%              无效操作，返回原背包
%%
%%      待操作格子中有物品 ，且支持 相应数量 的操作（交换、叠加、移动） （不支持拆分）TempNumFrom =< Num
%%          目标格子是否合法
%%              目标格子中有物品而且与待操作格子中的 物品id 相同  ->叠加(cap+1)
%%              目标格子中有物品而且与待操作格子中的 物品id 不相同    交换
%%              目标格子没有物品  ->移动
%%              无效操作，返回原背包
%%      待操作格子中没有物品
%%          无效操作，返回原背包

%将背包 GirdFrom 号格子中的物品的 Num 个移动到 GirdTo 格子中 --> 单元测试通过
move_good(#{cap := Cap } = Mybag , GirdFrom , Num ,GirdTo ) ->
    case maps:find(GirdFrom , Mybag) of
          {ok, #good{id = XFrom , num = NumFrom  } = GoodFrom } when NumFrom > Num ->
                case maps:find(GirdTo ,Mybag) of
                      {ok, #good{ id = XTo ,num = NumTo } = GoodTo } when XFrom == XTo ->
                            Mybag1 = maps:update(GirdFrom , GoodFrom#good{ num = NumFrom - Num} , Mybag ),
                            Mybag2 = maps:update(GirdTo,GoodTo#good{num = NumTo + Num },Mybag1),
                            Mybag2;
                      {ok, #good{} } ->
                            Mybag;
                      error  ->
                            Mybag1 = maps:update(GirdFrom , GoodFrom#good{ num = NumFrom - Num},Mybag),
                            Mybag2 = maps:put( GirdTo ,GoodFrom#good{ num = Num}, Mybag1),
                            Mybag2;
                      _T ->
                            Mybag
                end;
          {ok, #good{id = XFrom , num = NumFrom  }= GoodFrom } when NumFrom == Num ->
                case maps:find(GirdTo , Mybag ) of
                      { ok ,  #good{ id = XTo ,num = NumTo } = GoodTo } when XFrom == XTo ->
                            Mybag1 = delete_good(Mybag,GirdFrom ),
                            Mybag2 = maps:update(GirdTo , GoodTo#good{num = NumTo + Num }  , Mybag1 ),
                            Mybag2;
                      {ok, #good{ } = GoodTo } ->
                            Mybag1= maps:update(GirdTo , GoodFrom , Mybag),
                            Mybag2 = maps:update(GirdFrom , GoodTo , Mybag1 ),
                            Mybag2;
                      fasle when Cap >0 ->
                            Mybag1 = delete_good(Mybag,GirdFrom),
                            Mybag2 = maps:put(GirdTo , GoodFrom , Mybag1 ),
                            Mybag2;
                      _ ->
                            Mybag
                end;
          error ->
                Mybag;
          %无匹配
           _ ->
                Mybag
    end.

%%背包中是否有相同物品， 若有-> 修改num \若无 -> 增加物品，修改Cap
%%   找到物品，判断ID是否相同， ->相同，增加num  不相同，返回原背包
%%   没有找到相应的物品 ->将物品放入该格子

%添加物品 ->单元测试通过
add_good(#{cap := Cap } = Mybag , #good{id = X,num = Num} =  Good , Gird) ->
      case maps:find( Gird , Mybag) of
            { ok , #good{id = XTo , num = NumTo}  = GoodTo }  when X == XTo ->
                  Mybag1 = maps:update(Gird , GoodTo#good{num = NumTo + Num } ,Mybag ),
                  Mybag1;
            error  when Cap > 0 ->
                  Mybag1 = maps:update(cap , Cap - 1 ,Mybag ),
                  Mybag2 = maps:put( Gird ,Good, Mybag1),
                  Mybag2;
            _ ->
                  Mybag
      end.



%删除   ->单元测试通过
delete_good(#{cap := Cap } =Mybag , Gird) ->

  %物品存在于背包中 -> 删除
  case maps:find( Gird , Mybag) of
    { ok , #good{}  } ->
      Mybag1 = maps:remove(Gird , Mybag),
      Mybag2 = maps:update(cap , Cap + 1 ,Mybag1 ),
      Mybag2;

    error ->
      Mybag;
    _ ->
      Mybag
  end.

%%物品存在于背包中 -> 修改数量 、数量为0时删除

% 修改 ->单元测试通过
change_good( Mybag ,#good{id = X ,num = Num }=  Good , Gird) ->
      case maps:find( Gird , Mybag) of
            { ok ,#good{id = XTo }  }  when X == XTo ->
                  case Num of
                    Num when Num=<0 ->
                              Mybag1 = delete_good(Mybag,Gird),
                              Mybag1;
                    Num when Num>0 ->
                              Mybag1 = maps:update(Gird , Good ,Mybag ),
                              Mybag1;
                        _ ->
                              Mybag
                  end;
            error ->
                  Mybag
      end.

%查找   ->单元测试通过
find_element( Mybag ,Gird) ->
      case maps:find( Gird , Mybag) of
            { ok , #good{} = TempGood } ->
                  TempGood;
            error ->
                  io:format("there is no this element~n");
            _ ->
                  io:format("illegal Input~n")
      end.