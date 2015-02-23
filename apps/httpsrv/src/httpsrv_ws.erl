-module(httpsrv_ws).

%-behaviour(cowboy_http_handler).
%-behaviour(cowboy_websocket_handler).

-export([init/2, handle/2, terminate/3]).  
-export(
   [websocket_init/3, websocket_handle/3,  
    websocket_info/3, websocket_terminate/3]).

init(Req, Opts) -> 
    {cowboy_websocket, Req, Opts}.

handle(Req, State) ->
    error_logger:info_report(
      ["HTTP Request",
       {request, Req}]),
    {ok, Req2} = cowboy_http_req:reply(
                   400, [{'Content-Type', <<"text/html">>}]),
    {ok, Req2, State}.  

websocket_init(_TransportName, Req, _Opts) ->
    error_logger:info_report(
      ["Init Websocket"]),
    {ok, Req, undefined_state}.  
  
%websocket_handle({text, Msg}, Req, State) ->  
    %lager:log(debug, self(), "Got Data: ~p", [Msg]),  
%    {reply, {text, << "responding to ", Msg/binary >>}, Req, State, hibernate };  
websocket_handle({binary, Data}, Req, State) ->
    Tuple = enet_decode(Data),
    {PeerId, SentTime, Command, ChannelId, ReliableSequenceNumber, Rest} =
        Tuple,
    error_logger:info_report(
      ["Incoming Data",
       {peer_id, PeerId},
       {sent_time, SentTime},
       {command, Command},
       {channel_id, ChannelId},
       {reliable_sequence_number, ReliableSequenceNumber},
       {rest, Rest},
       {state, State}
      ]),
    {reply, {binary, enet_handle(Tuple)}, Req, State, hibernate }.

websocket_info({timeout, _Ref, Msg}, Req, State) ->  
    {reply, {text, Msg}, Req, State};  
  
websocket_info(_Info, Req, State) ->  
    %lager:log(debug, self(), "websocket info"),
    {ok, Req, State, hibernate}.  
  
websocket_terminate(_Reason, _Req, _State) ->  
    ok.  

terminate(_Reason, _Req, _State) ->  
    ok.

%-enum({enet_command,[
%                     ]}).
enet_decode_command(0) -> {ok, none};
enet_decode_command(1) -> {ok, acknowledge};
enet_decode_command(2) -> {ok, connect};
enet_decode_command(3) -> {ok, verify_connect};
enet_decode_command(4) -> {ok, disconnect};
enet_decode_command(5) -> {ok, ping};
enet_decode_command(6) -> {ok, send_reliable};
enet_decode_command(7) -> {ok, send_unreliable};
enet_decode_command(8) -> {ok, send_fragment};
enet_decode_command(9) -> {ok, send_unsequenced};
enet_decode_command(10) -> {ok, bandwidth_limit};
enet_decode_command(11) -> {ok, throttle_configure};
enet_decode_command(12) -> {ok, send_unreliable_fragment};
enet_decode_command(_) -> {error, unknown_command}.
    
enet_decode(Binary) ->
    <<PeerId:16,
      SentTime:16,
      CommandId:8,
      ChannelId:8,
      ReliableSequenceNumber:8,
      Rest/binary>> = Binary,
    {ok, Command} = enet_decode_command(CommandId band 16#f),
    Data = enet_decode_rest(Command, Rest),
    {PeerId, SentTime, Command, ChannelId, ReliableSequenceNumber, Data}.
    
enet_decode_rest(connect, Rest0) ->
    <<OutgoingPeerID:16,
      IncomingSessionID:8,
      OutgoingSessionID:8,
      MTU:32,
      WindowSize:32,
      ChannelCount:32,
      IncomingBandwidth:32,
      OutgoingBandwidth:32,
      PacketThrottleInterval:32,
      PacketThrottleAcceleration:32,
      PacketThrottleDeceleration:32,
      ConnectID:32,
      Data:32,
      Rest/binary>> = Rest0,
    [{outgoing_peer_id, OutgoingPeerID},
     {incoming_session_id, IncomingSessionID},
     {outgoing_session_id, OutgoingSessionID},
     {mtu, MTU},
     {window_size, WindowSize},
     {channel_count, ChannelCount},
     {incoming_bandwidth, IncomingBandwidth},
     {outgoing_bandwidth, OutgoingBandwidth},
     {packet_throttle_interval, PacketThrottleInterval},
     {packet_throttle_acceleration, PacketThrottleAcceleration},
     {packet_throttle_deceleration, PacketThrottleDeceleration},
     {connect_id, ConnectID},
     {data, Data},
     {rest, Rest}].

enet_command_flags(Command, Flags) ->
    ok.

enet_handle({PeerId, SentTime, connect,
             ChannelId, ReliableSequenceNumber, Data}) ->
    HeaderCommand = enet_command_flags(verify_connect, [acknowledge]),
    ok.
    
    
