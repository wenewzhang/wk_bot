%%%-------------------------------------------------------------------
%% @doc wk_bot top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(wk_bot_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).
-export([p/0]).

-define(SERVER, ?MODULE).
-define(CLIENT_ID,<<"21042518-85c7-4903-bb19-f311813d1f51">>).
-define(CLIENT_SECRET,<<"8cc112e77c25457e287b39c786b4e29edd2035a9deb2f658e17c99d56fdfb13a">>).
-define(SCOPE_PROFILE,<<"PROFILE:READ">>).
-define(MXN_OAUTH_STEP_ONE_URL,<<"https://mixin.one/oauth/authorize?client_id=~s&scope=~s">>).
-define(MXN_OAUTH_CLIENT_URL,<<"https://mixin.one/oauth/oauth/token">>).
-define(PIN,232913).
-define(SESSION_ID,<<"4c6bda11-3460-4bc9-9673-996ac34b7907">>).
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

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: #{id => Id, start => {M, F, A}}
%% Optional keys are restart, shutdown, type, modules.
%% Before OTP 18 tuples must be used to specify a child. e.g.
%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    quickrand:seed(),
    {ok, {{one_for_all, 0, 1}, []}}.

signAuthenticationToken(Uid,Sid,PrvKey,Method,Uri) ->
  Iat = os:system_time(seconds),
  % one hour
  Exp = os:system_time(seconds) + (1*60*60),
  Token = [
   {uid,Uid},
   {sid,Sid},
   {iat,Iat},
   {exp,Exp},
   {jti,uuid:uuid_to_string(uuid:get_v5(uuid:get_v4_urandom()))},
   {sig,to_hex(crypto:hash(sha256,Method ++ Uri))}
   ],
  [Entry] = public_key:pem_decode(PrvKey),
  io:format("key:~p~n",[Entry]),
  Key = public_key:pem_entry_decode(Entry),
  io:format("key:~p~n",[Key]),
  % TokenB = list_to_binary(Token),
  % io:format("Token Bin:~p~n",[TokenB]),

  SignDt = jwt:encode(<<"RS256">>,Token,Key),
  io:format("sign data:~p~n",[SignDt]),
  SignDt.

p()->
    % {_,Key,_} = public_key:pem_decode(?PRIVATE_KEY),
    % io:format("Key data:~p",Key),
    signAuthenticationToken(?CLIENT_ID,?SESSION_ID,?PRIVATE_KEY,"GET","/"),
    ok.

to_hex([]) ->
    [];
to_hex(Bin) when is_binary(Bin) ->
    to_hex(binary_to_list(Bin));
to_hex([H|T]) ->
    [to_digit(H div 16), to_digit(H rem 16) | to_hex(T)].

to_digit(N) when N < 10 -> $0 + N;
to_digit(N)             -> $a + N-10.
%%====================================================================
%% Internal functions
%%====================================================================
