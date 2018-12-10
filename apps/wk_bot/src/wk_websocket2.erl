-module(wk_websocket2).

-behaviour(websocket_client).

-export([
         start_link/0,
         init/1,
         onconnect/2,
         ondisconnect/2,
         websocket_handle/3,
         websocket_info/3,
         websocket_terminate/3
        ]).

-include("wk_bot.hrl").

start_link() ->
    crypto:start(),
    ssl:start(),
    Token = signAuthenticationToken(?CLIENT_ID,?SESSION_ID,?PRIVATE_KEY,"GET","/"),
    Header = [{<<"Sec-WebSocket-Protocol">>,<<"Mixin-Blaze-1">>},
              {<<"Authorization">>,iolist_to_binary([<<"Bearer ">>,Token])}],
    websocket_client:start_link("ws://127.0.0.1", ?MODULE, [Header]).
    % websocket_client:start_link("wss://blaze.mixin.one", ?MODULE, []).

init([]) ->
    io:format("init 2~n"),
    {once, 2}.

onconnect(WSReq, State) ->
    io:format("onconnect~n"),
    % Token = signAuthenticationToken(?CLIENT_ID,?SESSION_ID,?PRIVATE_KEY,"GET","/"),
    % % Token = <<"eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIzYmFjZDZkZi1jZWIwLTQ4NTgtYTc2MS0zYzE1MzViMzM3ZjIiLCJ1aWQiOiIyMTA0MjUxOC04NWM3LTQ5MDMtYmIxOS1mMzExODEzZDFmNTEiLCJzaWciOiJmODM3ZWJlYjRjMjk4MWFkOWM2NGI3MGQwYjBkMTg3MjRjNzZjNjA3ODFiOWU0YmY3YTU4MjUxMGRmN2FkYTM5IiwiZXhwIjoxNTQ0MzQyMTI2LCJzaWQiOiI0YzZiZGExMS0zNDYwLTRiYzktOTY3My05OTZhYzM0Yjc5MDciLCJpYXQiOjE1NDQzMzEzMjZ9.Ua3OjojMaCVcUFQKIyG9jz7NLGSeC3LGtDnwCoS3BMBVslGk-qAvM3S2Je4YQKJHqti3KLn_3NKyQJ1_ohl5x88WbzYlO33eFG8ChnEhgvwl68lhq6qGDTJy4Ui20D32EllxGsfw1BnuElXSDpMhprXJkzRMEmNsF_tjacUlmlI">>,
    % Header = [{<<"Sec-WebSocket-Protocol">>,<<"Mixin-Blaze-1">>},
    %           {<<"Authorization">>,iolist_to_binary([<<"Bearer ">>,Token])}],
    % wsc_lib:create_handshake(WSReq,Header),
    % websocket_client:cast(self(), {text, <<"message 1">>}),
    {ok, State}.

ondisconnect({remote, closed}, State) ->
    io:format("ondisconnect~n"),
    {reconnect, State}.

websocket_handle({pong, _}, _ConnState, State) ->
    io:format("websocket_handle pong~n"),
    {ok, State};

websocket_handle({text, Msg}, _ConnState, 5) ->
    io:format("Received msg ~p~n", [Msg]),
    {close, <<>>, "done"};
websocket_handle({text, Msg}, _ConnState, State) ->
    io:format("Received msg ~p~n", [Msg]),
    timer:sleep(1000),
    BinInt = list_to_binary(integer_to_list(State)),
    {reply, {text, <<"hello, this is message #", BinInt/binary >>}, State + 1};

websocket_handle(Info, _ConnState, State) ->
    io:format("info:~p~n",[Info]),
    {ok, State}.

websocket_info(start, _ConnState, State) ->
    {reply, {text, <<"erlang message received">>}, State}.

websocket_terminate(Reason, _ConnState, State) ->
    io:format("Websocket closed in state ~p wih reason ~p~n",
              [State, Reason]),
    ok.

signAuthenticationToken(Uid,Sid,PrvKey,Method,Uri) ->
  Iat = os:system_time(seconds),
  % one hour
  Exp = os:system_time(seconds) + (3*60*60),
  Token = [
   {jti,list_to_binary("3bacd6df-ceb0-4858-a761-3c1535b337f2")},
   {uid,list_to_binary(Uid)},
   {sig,list_to_binary("f837ebeb4c2981ad9c64b70d0b0d18724c76c60781b9e4bf7a582510df7ada39")},
   {exp,Exp},
   {sid,list_to_binary(Sid)},
   {iat,Iat}
   ],
      % {sig,to_hex(crypto:hash(sha256,Method ++ Uri))}
  [Entry] = public_key:pem_decode(PrvKey),
  % io:format("key:~p~n",[Entry]),
  Key = public_key:pem_entry_decode(Entry),
  % io:format("key:~p~n",[Key]),
  % TokenB = list_to_binary(Token),
  % io:format("Token Bin:~p~n",[TokenB]),
  % io:format("rsa test:~p~n",[public_key:sign(<<"test">>,sha512,Key)]),
  {ok,SignDt} = jwt:encode(<<"RS512">>,Token,Key),
  % io:format("sign data:~p~n",[SignDt]),
  Dt = jwt:decode(SignDt,Key),
  % io:format("sign data:~p~n",[Dt]),
  SignDt.
