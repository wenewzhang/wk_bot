all:
	rebar3 compile
debug:
	rebar3 as test shell
tar:
	rebar3 as prod release
	rebar3 as prod tar
run:
	rebar3 tar
	/Users/wenewzhang/Documents/sl/wk_bot/_build/default/rel/wk_bot/bin/wk_bot console
