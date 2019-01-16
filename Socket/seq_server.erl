

start_seq_server() ->
	{ok ,Listen} = gen_tcp:listen(...),
	seq_loop(Listen).
	
seq_loop(Listen) ->
	{ok , Socket} = gen_tcp:accept(Listen),
	loop(Scoekt),
	seq_loop(Listen).
loop(..) -> %%和之前一样