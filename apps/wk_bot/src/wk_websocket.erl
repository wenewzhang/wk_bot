%%%-------------------------------------------------------------------
%%% File    : wk_websocket_server.erl
%%% Author  : wenewzhang
%%% Description : <Add description here>
%%%
%%% Created : 05.12.2018
%%%-------------------------------------------------------------------
-module(wk_websocket).

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {conn
              }).
-define(SERVER, ?MODULE).
-define(CLIENT_ID,"21042518-85c7-4903-bb19-f311813d1f51").
-define(CLIENT_SECRET,"8cc112e77c25457e287b39c786b4e29edd2035a9deb2f658e17c99d56fdfb13a").
-define(SCOPE_PROFILE,<<"PROFILE:READ">>).
-define(MXN_OAUTH_STEP_ONE_URL,<<"https://mixin.one/oauth/authorize?client_id=~s&scope=~s">>).
-define(MXN_OAUTH_CLIENT_URL,<<"https://mixin.one/oauth/oauth/token">>).
-define(PIN,232913).
-define(SESSION_ID,"4c6bda11-3460-4bc9-9673-996ac34b7907").
-define(PIN_TOKEN,<<"
IMnZTGJmqdA8Lax81+10ltmVQVRAug+u/Qsv3VRB7QEJgFYJ9WL8PQG1e4wdZwym2bCYheHkUTaLbSWVI6o2FEXoHBfftnOYzN1et9JCJwYfPCfDmBCQ2FWKXjhGXy6huqsUMRTErROpsSkRkQskeSudFwJrurnRsdgQyvzdVHw=
">>).
-define(PRIVATE_KEY,<<"
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQCfaMTR0HBsRr3MVMTACVCYWCx6cSdC9c4q2H3kUD7KjS5VuCXR
eT4aBY1fk5s4icurxutEaVt1V2M1DyDqy7EJO7nNL7hUz6iCZ0REpr6D6FviE5BD
TCwX1unNF0QLHi3wbHRDHt+0evlawujopM/H+BXkxNdVaHpqeunj7C1sXwIDAQAB
AoGAPufTM5DzrGbGI0oYUkfavCOfeboJak0hzJqeI2jfPoM0E7OViPI1ZYNnZJ4V
FNybuO/Ii7if1NBlX9zWepFjDMamDoVpL5bTUL8eQ4lfr80boWrF1AOnYBM4Xp5Q
n0pmtp5nFRCwL1lnRF702eXxwmn6hURTnYCcb9VybMLftWECQQDpL4Wc2uJgGsux
8oBBL41K64j4rxWeOARsrS56bTseqUT16hByfV7PVPMc8kpupY+P3iuQhCBOSJTa
CW5h417ZAkEArwFonuyuXMHD6KnwMS6oP8NklV+d1joza+U3OVM+MzWMoKHNO9z6
pWtzNS9ypkLYQPhR5KvhsZX8LNJrtTSR9wJBAIvM5OMMS2noxrRxubjbBG+lVGIb
ve80kFqDXXkioa4ZN3HjmWa6iSvuNy7kiAFcGvza6u1ieWfVlgA+ZUIkqckCQA1u
iD8aX0+TN5wV3u+HazZposCsNAsLMIMpdpGZx/5aL87sXDop/brQgmkkmSIVo09p
P6/TWWEt58rw439m54UCQQDN0F6oGJzR/RX6FhEpt6zge+8Kpv6IaeHbUpQ0uaEp
TTi81xsOsJoFhTUOyzsQVA2doGV7D9ptfekMCeJrbabM
-----END RSA PRIVATE KEY-----
">>).
-define(PTL_LIST_PENDING_MESSAGES,"id:~s,action:LIST_PENDING_MESSAGES").
%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start_link() -> {ok,Pid} | ignore | {error,Error}
%% Description: Starts the server
%%--------------------------------------------------------------------
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%====================================================================
%% gen_server callbacks
%%====================================================================

%%--------------------------------------------------------------------
%% Function: init(Args) -> {ok, State} |
%%                         {ok, State, Timeout} |
%%                         ignore               |
%%                         {stop, Reason}
%% Description: Initiates the server
%%--------------------------------------------------------------------
init([]) ->
  % Token = signAuthenticationToken(?CLIENT_ID,?SESSION_ID,?PRIVATE_KEY,"GET","/"),
  % Header = [{<<"Upgrade">>,<<"websocket">>},
  %           {<<"Connection">>,<<"Upgrade">>},
  %           {<<"Sec-WebSocket-Key">>,<<"Q+0VrkMrRk/ymTOLNcc9xw==">>},
  %           {<<"Sec-WebSocket-Protocol">>,<<"Mixin-Blaze-1">>},
  %           {<<"Sec-WebSocket-Version">>,<<"13">>},
  %           {<<"Authorization">>,iolist_to_binary([<<"Bearer ">>,Token])}],
  % io:format("Header:~p~n",[Header]),
  % SteamRef = gun:get(ConnPid,"/",Header),
  {ok, ConnPid} = gun:open("blaze.mixin.one", 443,#{transport => tls,protocols =>[http]}),
  % {ok, ConnPid} = gun:open("127.0.0.1", 80),
  % case gun:await_up(ConnPid) of
  % % gun:ws_upgrade(ConnPid, "/websocket"),
  % {ok, Protocol} ->
  %    io:format("await_up:~p~n",[Protocol]),
  %    io:format("connected"),
  %    Token = signAuthenticationToken(?CLIENT_ID,?SESSION_ID,?PRIVATE_KEY,"GET","/"),
  %    Header = [{<<"Upgrade">>,<<"websocket">>},
  %             {<<"Connection">>,<<"Upgrade">>},
  %             {<<"Sec-WebSocket-Key">>,<<"Q+0VrkMrRk/ymTOLNcc9xw==">>},
  %             {<<"Sec-WebSocket-Protocol">>,<<"Mixin-Blaze-1">>},
  %             {<<"Sec-WebSocket-Version">>,<<"13">>},
  %             {<<"Authorization">>,iolist_to_binary([<<"Bearer ">>,Token])}],
  %    io:format("Header:~p~n",[Header]),
  %    SteamRef = gun:get(ConnPid,"/",Header),
  %    Msg = io_lib:format(?PTL_LIST_PENDING_MESSAGES,[uuid:uuid_to_string(uuid:get_v5(uuid:get_v4_urandom()))]),
  %    % Msg = ["id",uuid:uuid_to_string(uuid:get_v5(uuid:get_v4_urandom()))},{"action","LIST_PENDING_MESSAGES"}],
  %    io:format("msg ~p~n",[Msg]),
  %    MsgB = zlib:gzip(iolist_to_binary(Msg)),
  %    io:format("msg b:~p~n",[MsgB]),
  %    gun:ws_send(ConnPid, MsgB);
  % {error, Reason} ->
  %     io:format("error :~p~n",[Reason])
  % end,
  % decode_python_data(?PRIVATE_KEY),
  {ok, #state{conn = ConnPid}}.

%%--------------------------------------------------------------------
%% Function: %% handle_call(Request, From, State) -> {reply, Reply, State} |
%%                                      {reply, Reply, State, Timeout} |
%%                                      {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, Reply, State} |
%%                                      {stop, Reason, State}
%% Description: Handling call messages
%%--------------------------------------------------------------------
handle_call(Request, _From, State) ->
  Reply = ok,
  io:format("handle call:~p~n",[Request]),
  {reply, Reply, State}.

%%--------------------------------------------------------------------
%% Function: handle_cast(Msg, State) -> {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, State}
%% Description: Handling cast messages
%%--------------------------------------------------------------------
handle_cast(Msg, State) ->
  io:format("handle cast:~p~n",[Msg]),
  {noreply, State}.

%%--------------------------------------------------------------------
%% Function: handle_info(Info, State) -> {noreply, State} |
%%                                       {noreply, State, Timeout} |
%%                                       {stop, Reason, State}
%% Description: Handling all non call/cast messages
%%--------------------------------------------------------------------
handle_info({gun_up,ConnPid,HttpVersion}, State) ->
  % io:format("handle info:~p~n",[Info]),
  Token = signAuthenticationToken(?CLIENT_ID,?SESSION_ID,?PRIVATE_KEY,"GET","/"),
  % Token = <<"eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIzYmFjZDZkZi1jZWIwLTQ4NTgtYTc2MS0zYzE1MzViMzM3ZjIiLCJ1aWQiOiIyMTA0MjUxOC04NWM3LTQ5MDMtYmIxOS1mMzExODEzZDFmNTEiLCJzaWciOiJmODM3ZWJlYjRjMjk4MWFkOWM2NGI3MGQwYjBkMTg3MjRjNzZjNjA3ODFiOWU0YmY3YTU4MjUxMGRmN2FkYTM5IiwiZXhwIjoxNTQ0MzQyMTI2LCJzaWQiOiI0YzZiZGExMS0zNDYwLTRiYzktOTY3My05OTZhYzM0Yjc5MDciLCJpYXQiOjE1NDQzMzEzMjZ9.Ua3OjojMaCVcUFQKIyG9jz7NLGSeC3LGtDnwCoS3BMBVslGk-qAvM3S2Je4YQKJHqti3KLn_3NKyQJ1_ohl5x88WbzYlO33eFG8ChnEhgvwl68lhq6qGDTJy4Ui20D32EllxGsfw1BnuElXSDpMhprXJkzRMEmNsF_tjacUlmlI">>,
  Header = [{<<"Sec-WebSocket-Protocol">>,<<"Mixin-Blaze-1">>},
            {<<"Authorization">>,iolist_to_binary([<<"Bearer ">>,Token])}],
  io:format("Header:~p HttpVersion:~p~n",[Header,HttpVersion]),
  Key = cow_ws:key(),
  Headers = [
    {<<"Connection">>, <<"Upgrade">>},
    {<<"Upgrade">>, <<"websocket">>},
    {<<"Sec-websocket-version">>, <<"13">>},
    {<<"Sec-websocket-key">>, Key}
    |Header
  ],
  % SteamRef = gun:get(ConnPid,"/",Headers),
  gun:ws_upgrade(ConnPid, "/",Header),
  {noreply, State#state{conn = ConnPid}};

handle_info({gun_upgrade, ConnPid, _StreamRef, _Websocket, _}, State) ->
  Msg = io_lib:format(?PTL_LIST_PENDING_MESSAGES,[uuid:uuid_to_string(uuid:get_v5(uuid:get_v4_urandom()))]),
  % Msg = ["id",uuid:uuid_to_string(uuid:get_v5(uuid:get_v4_urandom()))},{"action","LIST_PENDING_MESSAGES"}],
  io:format("msg ~p~n",[Msg]),
  MsgB = zlib:gzip(iolist_to_binary(Msg)),
  io:format("msg b:~p~n",[MsgB]),
  gun:ws_send(ConnPid, MsgB),
  {noreply, State};

handle_info({gun_response, _ConnPid, _StreamRef, Nofin,StatCode,_Meta}, #state{conn = ConnPid} = State) when Nofin =:= nofin andalso StatCode =:= 200 ->
  % Msg = <<"id:b2efacbd-fba9-11e8-bd49-20c9d08850cd","action:LIST_PENDING_MESSAGES">>,
  % % uuid:uuid_to_string(uuid:get_v5(uuid:get_v4_urandom()))/binary
  % % Msg = ["id",uuid:uuid_to_string(uuid:get_v5(uuid:get_v4_urandom()))},{"action","LIST_PENDING_MESSAGES"}],
  % io:format("msg ~p~n",[Msg]),
  % MsgB = zlib:gzip(iolist_to_binary(Msg)),
  % io:format("msg b:~p~n",[MsgB]),
  % gun:ws_send(ConnPid, MsgB),
  % gun:ws_upgrade(ConnPid, "/"),
  io:format("gun_response"),
  {noreply, State};

handle_info({gun_inform,_ConPid,_StreamRef,StateCode,_CDN},#state{conn = ConnPid} = State) when StateCode =:= 101 ->
  io:format("send action "),
  % Msg = io_lib:format(?PTL_LIST_PENDING_MESSAGES,[uuid:uuid_to_string(uuid:get_v5(uuid:get_v4_urandom()))]),
  % % Msg = ["id",uuid:uuid_to_string(uuid:get_v5(uuid:get_v4_urandom()))},{"action","LIST_PENDING_MESSAGES"}],
  % io:format("msg ~p~n",[Msg]),
  % MsgB = zlib:gzip(iolist_to_binary(Msg)),
  % io:format("msg b:~p~n",[MsgB]),
  % gun:ws_send(ConnPid, MsgB),
  % gun:ws_upgrade(ConnPid, "/",[],#{compress => true}),
  {noreply, State};
handle_info({gun_data,_,_,Fin,Meta},#state{conn = ConnPid} = State) when Fin =:= fin ->
  io:format("gun_data:~p~n",[Meta]),
  % gun:ws_upgrade(ConnPid, "/"),
  {noreply, State};

handle_info({gun_error,_,_,Reason},State) ->
  io:format("gun_error:~p~n",[Reason]),
  {noreply, State};

handle_info(Info, State) ->
  io:format("handle info:~p~n",[Info]),
  {noreply, State}.

%%--------------------------------------------------------------------
%% Function: terminate(Reason, State) -> void()
%% Description: This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any necessary
%% cleaning up. When it returns, the gen_server terminates with Reason.
%% The return value is ignored.
%%--------------------------------------------------------------------
terminate(_Reason,#state{conn = ConnPid}) ->
  gun:shutdown(ConnPid),
  ok.

%%--------------------------------------------------------------------
%% Func: code_change(OldVsn, State, Extra) -> {ok, NewState}
%% Description: Convert process state when code is changed
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------

signAuthenticationToken(Uid,Sid,PrvKey,Method,Uri) ->
  Iat = os:system_time(seconds),
  % three hour
  Exp = os:system_time(seconds) + (3*60*60),
  Token = [
   {jti,list_to_binary(uuid:uuid_to_string(uuid:get_v5(uuid:get_v4_urandom())))},
   {uid,list_to_binary(Uid)},
   {sig,list_to_binary(to_hex(crypto:hash(sha256,Method ++ Uri)))},
   {exp,Exp},
   {sid,list_to_binary(Sid)},
   {iat,Iat}
   ],
  [Entry] = public_key:pem_decode(PrvKey),
  Key = public_key:pem_entry_decode(Entry),
  {ok,SignDt} = jwt:encode(<<"RS512">>,Token,Key),
  Dt = jwt:decode(SignDt,Key),
  SignDt.

to_hex([]) ->
    [];
to_hex(Bin) when is_binary(Bin) ->
    to_hex(binary_to_list(Bin));
to_hex([H|T]) ->
    [to_digit(H div 16), to_digit(H rem 16) | to_hex(T)].

to_digit(N) when N < 10 -> $0 + N;
to_digit(N)             -> $a + N-10.

decode_python_data(PrvKey) ->
  Dt = <<"eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIzYmFjZDZkZi1jZWIwLTQ4NTgtYTc2MS0zYzE1MzViMzM3ZjIiLCJ1aWQiOiIyMTA0MjUxOC04NWM3LTQ5MDMtYmIxOS1mMzExODEzZDFmNTEiLCJzaWciOiJmODM3ZWJlYjRjMjk4MWFkOWM2NGI3MGQwYjBkMTg3MjRjNzZjNjA3ODFiOWU0YmY3YTU4MjUxMGRmN2FkYTM5IiwiZXhwIjoxNTQ0MjY3NTI1LCJzaWQiOiI0YzZiZGExMS0zNDYwLTRiYzktOTY3My05OTZhYzM0Yjc5MDciLCJpYXQiOjE1NDQxNjc1MjV9.JiphZRWS3siHinAwphYe4rfZUHruE0Hzgou0mUWw82y_3GycCGA_HX85pnCNqt4zijRyvxcf2TeR1nbT9ab8oL5p0iZJeebBdS6nzw8J4jTgLJw7GinIgtxpJTm0OpVr5-chCP7is5t2RkLhQGDVYvfySejnkpG5PK-sv_9-UgY">>,
  [Entry] = public_key:pem_decode(PrvKey),
  % io:format("key:~p~n",[Entry]),
  Key = public_key:pem_entry_decode(Entry),
  DtN = jwt:decode(Dt,Key),
  io:format("python:~p~n",[DtN]).
