-module(httpsrv_ws2).

-export([init/2]).
-export([websocket_handle/3]).
-export([websocket_info/3]).

init(Req, Opts) ->
    gen_server:call(httpsrv_chat_srv, join),
    case cowboy_req:parse_header(<<"sec-websocket-protocol">>, Req) of
        undefined ->
            {cowboy_websocket, Req, Opts};
        %% Chrome se pone loco si manda subprotocolos y no se los responden
        [<<"binary">>] ->
            Req2 = cowboy_req:set_resp_header(<<"sec-websocket-protocol">>,
                                              <<"binary">>, Req),
            {cowboy_websocket, Req2, Opts}
    end.
    %% %erlang:start_timer(1000, self(), <<"Hello!">>),
    %% gen_server:call(httpsrv_chat_srv, join),
    %% {cowboy_websocket, Req, Opts}.

websocket_handle({text, Msg}, Req, State) ->
    {reply, {text, << "That's what she said! ", Msg/binary >>}, Req, State};
websocket_handle({binary, Data}, Req, State) ->
    gen_server:cast(httpsrv_chat_srv, {message, Data}),
    {ok, Req, State}.
    %% error_logger:info_report(
    %%   [{binary, Data},
    %%    {req, Req}]),
    %% {reply, {binary, Data}, Req, State}.
%    {ok, Req, State}.
websocket_info({message, Msg}, Req, State) ->
    {reply, {binary, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
    {ok, Req, State}.
