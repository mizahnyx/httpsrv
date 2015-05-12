-module(httpsrv_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    Env = application:get_all_env(),
    error_logger:info_report(
      ["Environment",
       {environment, Env}
      ]),
    Dispatch =
        cowboy_router:compile(
          [{'_',
            [{"/[...]", cowboy_static,
              {dir, "/home/sam/Sources/BananaBread/cube2"}}
            ]}]),
    DispatchWebSocket =
        cowboy_router:compile(
          [{'_',
            [{"/[...]", httpsrv_ws, []}
            ]}]),
    Dispatch2 =
        cowboy_router:compile(
          [{'_',
            [{"/[...]", cowboy_static,
              {priv_dir, httpsrv, "static"}}
            ]}]),
    DispatchWebSocket2 =
        cowboy_router:compile(
          [{'_',
            [{"/[...]", httpsrv_ws2, []}
            ]}]),
    {ok, _} = cowboy:start_http(
                httpsrv, 
                100, 
                [{port, 8888}],
                [{env, [{dispatch, Dispatch}]}]),
    {ok, _} = cowboy:start_http(
                httpsrv2, 
                100, 
                [{port, 8889}],
                [{env, [{dispatch, Dispatch2}]}]),
    {ok, _} = cowboy:start_http(
                httpsrv_ws, 
                100, 
                [{port, 28785}],
                [{env, [{dispatch, DispatchWebSocket}]}]),
    {ok, _} = cowboy:start_http(
                httpsrv_ws2, 
                100, 
                [{port, 2345}],
                [{env, [{dispatch, DispatchWebSocket2}]}]),
    httpsrv_chat_srv:start_link(),
    httpsrv_sup:start_link().

stop(_State) ->
    ok.
