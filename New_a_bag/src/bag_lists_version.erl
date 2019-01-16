%%%-------------------------------------------------------------------
%%% @author songsaifei
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 实现背包中物品的：增加、删除、修改、查找、排序（按照ID/按照NUM）
%%% @end
%%% Created : 05. 一月 2019 15:07
%%%-------------------------------------------------------------------
-module(bag_lists_version).
-author("songsaifei").
%% API
-export([  move_good/4, add_good/3, delete_good/2 , change_good/3, find_element/2,sort_Num/1]).
-define (false ,false).
-define (MAXCAP ,50).
-record(bag,{
  cap =?MAXCAP,
  goods = [{gird ,good}]
}).

-record(good,{
  id,
  num = 1,
  name,
  des
}).


%%将背包 GirdFrom 号格子中的物品的 Num 个移动到 GirdTo 格子中
%%  查看要操作的格子中是否是指定的物品
%%      待操作格子中有物品 ，且支持 相应数量 的操作（拆分、叠加） （不支持交换、移动）TempNum_From < Num
%%          目标格子是否合法
%%              目标格子中有物品而且与待操作格子中的 物品id 相同  ->先拆分 后叠加
%%              目标格子中有物品而且与待操作格子中的 物品id 不相同    数量不合法不可交换
%%              目标格子没有物品  ->拆分(cap-1)
%%              无效操作，返回原背包
%%
%%      待操作格子中有物品 ，且支持 相应数量 的操作（交换、叠加、移动） （不支持拆分）TempNum_From == Num
%%          目标格子是否合法
%%              目标格子中有物品而且与待操作格子中的 物品id 相同  ->叠加(cap+1)
%%              目标格子中有物品而且与待操作格子中的 物品id 不相同    交换
%%              目标格子没有物品  ->移动
%%              无效操作，返回原背包
%%      待操作格子中没有物品
%%          无效操作，返回原背包


%%    拆分、叠加、交换、移动
%%    将背包 GirdFrom 号格子中的物品的 Num 个移动到 GirdTo 格子中 --> 单元测试通过
move_good(#bag{cap = Cap, goods = GoodList} = Mybag ,GirdFrom , Num , GirdTo) ->
      case lists:keyfind( GirdFrom , 1 ,GoodList ) of
            { _ , #good{id = XFrom , num = NumFrom } = GoodFrom} when NumFrom > Num ->
                  case lists:keyfind( GirdTo , 1 ,GoodList ) of
                        { _ , #good{id = XTo , num = NumTo } = GoodTo } when  XFrom == XTo ->
                              %%目标格子中有物品而且与待操作格子中的 物品id 相同  ->先拆分 后叠加
                              GoodList1= lists:keyreplace(GirdFrom , 1, GoodList, { GirdFrom , GoodFrom#good{ num = NumFrom - Num }}),
                              Mybag#bag{goods = lists:keyreplace(GirdTo , 1, GoodList1, {GirdTo , GoodTo#good{ num = NumTo + Num } })};
%%                              Mybag1 = add_good(Mybag ,GoodFrom#good{ num = -Num },GirdFrom),
%%                              add_good(Mybag1,GoodTo#good{ num = Num },GirdTo );
                        {_ , #good{ } }  ->
                              Mybag;
                        ?false when Cap > 0 ->
                              %%目标格子没有物品  ->拆分(cap-1)
                              TempGoodList = lists:keyreplace(GirdFrom , 1, GoodList, { GirdFrom , GoodFrom#good{ num = NumFrom - Num }} ),
                              Mybag#bag{cap = Cap-1,goods = [  {GirdTo , GoodFrom#good{num = Num}} | TempGoodList ] };
                        _T ->
                              Mybag
                  end;
            { _ , #good{id = XFrom , num = NumFrom } = GoodFrom} when NumFrom =< Num ->
                  case lists:keyfind( GirdTo , 1 ,GoodList ) of
                        %目标格子中有物品而且与待操作格子中的 物品id 相同  ->叠加(cap+1)
                        { _ , #good{id = XTo , num = NumTo } = GoodTo } when XFrom == XTo ->
                              Mybag1 = delete_good(Mybag , GirdFrom),
%%                              add_good(Mybag1,GoodTo#good{ num =  Num },GirdTo);
                              GoodList1 = lists:keyreplace(GirdTo ,1, Mybag1#bag.goods ,  {GirdTo , GoodTo#good{ num = NumTo + Num } }),
                              Mybag#bag{ cap = Cap+1 , goods = GoodList1};
                        %目标格子中有物品而且与待操作格子中的 物品id 不相同    交换
                        { _ , #good{ } = GoodTo } ->
                              GoodList1 = lists:keyreplace(GirdTo , 1, GoodList,{ GirdTo , GoodFrom } ),
                              Mybag#bag{goods = lists:keyreplace(GirdFrom , 1, GoodList1, { GirdFrom , GoodTo })};
                        %目标格子没有物品  ->移动
                        false when Cap >0 ->
                              GoodList1 = [{GirdTo , GoodFrom}| lists:keydelete(GirdFrom , 1 , GoodList) ],
                              Mybag#bag{goods = GoodList1};
                        _ ->
                              Mybag
                      end;
            false ->
                  Mybag;
            _ ->
                  Mybag
      end.




%添加物品 ->单元测试通过
add_good( #bag{ cap = Cap, goods = GoodList } = Mybag , #good{id = X,num = Num} =  Good , Gird)->
      case lists:keyfind(Gird ,1 , GoodList ) of
            { _ , #good{id = XTo , num = NumTo } = GoodTo } when X == XTo ->
                  GoodFin = GoodTo#good{num = NumTo + Num },
                  Mybag#bag{goods = lists:keyreplace(Gird , 1, GoodList ,{Gird , GoodFin})};
            false when Cap > 0 ->
                  #bag{ cap = Cap-1, goods = [ {Gird , Good } | GoodList ] };
            _ ->
                  Mybag
      end.


%删除   ->单元测试通过
delete_good(#bag{ cap = Cap, goods = GoodList } = _Mybag , Gird ) ->
      TempList = lists:keydelete( Gird , 1 , GoodList ),
      #bag{ cap = Cap+1, goods = TempList }.



% 修改   ->单元测试通过
change_good( #bag{ goods = GoodList } = Mybag , #good{id =X,num = Num } =Good ,Gird) ->
      case lists:keyfind(Gird ,1 , GoodList ) of
            { _ , #good{id = XTo }  } when XTo == X ->
                  case Num of
                        Num when Num=<0 ->
                              delete_good(Mybag,Gird);
                        Num when Num>0 ->
                              Mybag#bag{goods = lists:keyreplace(Gird,1,GoodList, Good) }
                  end;
            false ->
                  io:format("there is no this element~n"),
                  Mybag;
            _ ->
              Mybag
      end.

%查找   ->单元测试通过
find_element( #bag{goods = GoodList} = _Mybag , Gird) ->
      case lists:keyfind(Gird ,1 , GoodList ) of
            { _ , #good{ } = GoodTo } ->
                  GoodTo;
      false ->
        io:format("there is no this element~n")
  end.

%整理背包   -> 按照Gird排序
% 默认已按照ID排序

%整理背包  -> 按照num排序  ->单元测试通过
sort_Num(#bag{goods = GoodList} = Mybag) ->
  TempList = lists:keysort(1 , GoodList),
  Mybag#bag{goods = TempList}.





