%%
%% Copyright (c) 2018 Dmitry Poroh
%% All rights reserved.
%% Distributed under the terms of the MIT License. See the LICENSE file.
%%
%% SIP message tests
%%

-module(ersip_sipmsg_test).

-include_lib("eunit/include/eunit.hrl").

%%%===================================================================
%%% Cases
%%%===================================================================

-define(crlf, "\r\n").

parse_request_test() ->
    CallId = <<"a84b4c76e66710@pc33.atlanta.com">>,
    Msg = <<"INVITE sip:bob@biloxi.com SIP/2.0"
            ?crlf "Via: SIP/2.0/UDP pc33.atlanta.com;branch=z9hG4bK776asdhds"
            ?crlf "Max-Forwards: 70"
            ?crlf "To: Bob <sip:bob@biloxi.com>"
            ?crlf "From: Alice <sip:alice@atlanta.com>;tag=1928301774"
            ?crlf "Call-ID: ", CallId/binary,
            ?crlf "CSeq: 314159 INVITE"
            ?crlf "Contact: <sip:alice@pc33.atlanta.com>"
            ?crlf "Content-Type: application/sdp"
            ?crlf "Content-Length: 4"
            ?crlf ?crlf "Test"
          >>,
    P  = ersip_parser:new_dgram(Msg),
    { {ok, PMsg}, _P2 } = ersip_parser:parse(P),
    { ok, SipMsg } = ersip_sipmsg:parse(PMsg, all),
    ?assertEqual(ersip_hdr_callid:make(CallId),        ersip_sipmsg:get(callid, SipMsg)),
    ?assertEqual(ersip_hdr_maxforwards:make(<<"70">>), ersip_sipmsg:get(maxforwards, SipMsg)),
    From = ersip_sipmsg:get(from, SipMsg),
    To   = ersip_sipmsg:get(to, SipMsg),
    ?assertEqual({tag, <<"1928301774">>},       ersip_hdr_fromto:tag(From)),
    ?assertEqual({display_name, [ <<"Bob">> ]}, ersip_hdr_fromto:display_name(To)),
    Via  = ersip_sipmsg:get(topmost_via, SipMsg),
    ?assertEqual({sent_by, { hostname, <<"pc33.atlanta.com">> }, 5060 },
                 ersip_hdr_via:sent_by(Via)).

parse_response_test() ->
    CallId = <<"a84b4c76e66710@pc33.atlanta.com">>,
    Msg = <<"SIP/2.0 200 OK"
            ?crlf "Via: SIP/2.0/UDP pc33.atlanta.com;branch=z9hG4bK776asdhds"
            ?crlf "Max-Forwards: 70"
            ?crlf "To: Bob <sip:bob@biloxi.com>"
            ?crlf "From: Alice <sip:alice@atlanta.com>;tag=1928301774"
            ?crlf "Call-ID: ", CallId/binary,
            ?crlf "CSeq: 314159 INVITE"
            ?crlf "Contact: <sip:alice@pc33.atlanta.com>"
            ?crlf "Content-Type: application/sdp"
            ?crlf "Content-Length: 4"
            ?crlf ?crlf "Test"
          >>,
    P  = ersip_parser:new_dgram(Msg),
    { {ok, PMsg}, _P2 } = ersip_parser:parse(P),
    { ok, SipMsg } = ersip_sipmsg:parse(PMsg, all),
    ?assertEqual(ersip_hdr_callid:make(CallId),        ersip_sipmsg:get(callid, SipMsg)),
    ?assertEqual(ersip_hdr_maxforwards:make(<<"70">>), ersip_sipmsg:get(maxforwards, SipMsg)),
    From = ersip_sipmsg:get(from, SipMsg),
    To   = ersip_sipmsg:get(to, SipMsg),
    ?assertEqual({tag, <<"1928301774">>},       ersip_hdr_fromto:tag(From)),
    ?assertEqual({display_name, [ <<"Bob">> ]}, ersip_hdr_fromto:display_name(To)),
    Via  = ersip_sipmsg:get(topmost_via, SipMsg),
    ?assertEqual({sent_by, { hostname, <<"pc33.atlanta.com">> }, 5060 },
                 ersip_hdr_via:sent_by(Via)).

parse_response_error_test() ->
    CallId = <<"a84b4c76e66710@pc33.atlanta.com">>,
    Msg = <<"SIP/2.0 200 OK"
            ?crlf "Via: SIP/2.0/UDP pc33.atlanta.com;branch=z9hG4bK776asdhds"
            ?crlf "Max-Forwards: 70"
            ?crlf "To: Bob <sip:bob@biloxi.com>"
            ?crlf "From: Alice <sip:alice@atlanta.com>;tag=1928301774"
            ?crlf "Call-ID: ", CallId/binary,
            ?crlf "CSeq: x"
            ?crlf "Contact: <sip:alice@pc33.atlanta.com>"
            ?crlf "Content-Type: application/sdp"
            ?crlf "Content-Length: 4"
            ?crlf ?crlf "Test"
          >>,
    P  = ersip_parser:new_dgram(Msg),
    { {ok, PMsg}, _P2 } = ersip_parser:parse(P),
    ?assertMatch({ error, { invalid_cseq, _ } }, ersip_sipmsg:parse(PMsg, [ content_type ])).

parse_request_without_body_test() ->
    CallId = <<"a84b4c76e66710@pc33.atlanta.com">>,
    Msg = <<"INVITE sip:bob@biloxi.com SIP/2.0"
            ?crlf "Via: SIP/2.0/UDP pc33.atlanta.com;branch=z9hG4bK776asdhds"
            ?crlf "Max-Forwards: 70"
            ?crlf "To: Bob <sip:bob@biloxi.com>"
            ?crlf "From: Alice <sip:alice@atlanta.com>;tag=1928301774"
            ?crlf "Call-ID: ", CallId/binary,
            ?crlf "CSeq: 314159 INVITE"
            ?crlf "Contact: <sip:alice@pc33.atlanta.com>"
            ?crlf "Content-Length: 0"
            ?crlf ?crlf
          >>,
    P  = ersip_parser:new_dgram(Msg),
    { {ok, PMsg}, _P2 } = ersip_parser:parse(P),
    { ok, SipMsg } = ersip_sipmsg:parse(PMsg, all),
    ?assertEqual(ersip_hdr_callid:make(CallId),        ersip_sipmsg:get(callid, SipMsg)),
    ?assertEqual(ersip_hdr_maxforwards:make(<<"70">>), ersip_sipmsg:get(maxforwards, SipMsg)),
    From = ersip_sipmsg:get(from, SipMsg),
    To   = ersip_sipmsg:get(to, SipMsg),
    ?assertEqual({tag, <<"1928301774">>},       ersip_hdr_fromto:tag(From)),
    ?assertEqual({display_name, [ <<"Bob">> ]}, ersip_hdr_fromto:display_name(To)),
    Via  = ersip_sipmsg:get(topmost_via, SipMsg),
    ?assertEqual({sent_by, { hostname, <<"pc33.atlanta.com">> }, 5060 },
                 ersip_hdr_via:sent_by(Via)),
    ?assertError({error, _}, ersip_sipmsg:get(content_type, SipMsg)). 

parse_request_with_body_no_content_type_test() ->
    CallId = <<"a84b4c76e66710@pc33.atlanta.com">>,
    Msg = <<"INVITE sip:bob@biloxi.com SIP/2.0"
            ?crlf "Via: SIP/2.0/UDP pc33.atlanta.com;branch=z9hG4bK776asdhds"
            ?crlf "Max-Forwards: 70"
            ?crlf "To: Bob <sip:bob@biloxi.com>"
            ?crlf "From: Alice <sip:alice@atlanta.com>;tag=1928301774"
            ?crlf "Call-ID: ", CallId/binary,
            ?crlf "CSeq: 314159 INVITE"
            ?crlf "Contact: <sip:alice@pc33.atlanta.com>"
            ?crlf "Content-Length: 4"
            ?crlf ?crlf "Test"
          >>,
    P  = ersip_parser:new_dgram(Msg),
    { {ok, PMsg}, _P2 } = ersip_parser:parse(P),
    ?assertEqual({error,{ header_error,
                          { content_type, 
                            {no_required_header,<<"content-type">>}}}},
                 ersip_sipmsg:parse(PMsg, all)).

parse_request_with_invalid_ruri_test() ->
    Msg = <<"INVITE bob@biloxi.com SIP/2.0"
            ?crlf "Via: SIP/2.0/UDP pc33.atlanta.com;branch=z9hG4bK776asdhds"
            ?crlf "Max-Forwards: 70"
            ?crlf "To: Bob <sip:bob@biloxi.com>"
            ?crlf "From: Alice <sip:alice@atlanta.com>;tag=1928301774"
            ?crlf "Call-ID: a84b4c76e66710@pc33.atlanta.com",
            ?crlf "CSeq: 314159 INVITE"
            ?crlf "Contact: <sip:alice@pc33.atlanta.com>"
            ?crlf "Content-Length: 4"
            ?crlf ?crlf "Test"
          >>,
    P  = ersip_parser:new_dgram(Msg),
    { {ok, PMsg}, _P2 } = ersip_parser:parse(P),
    ?assertMatch({error,{ invalid_ruri, _}},
                 ersip_sipmsg:parse(PMsg, all)).

parse_on_demand_test() ->
    CallId = <<"a84b4c76e66710@pc33.atlanta.com">>,
    Msg = <<"INVITE sip:bob@biloxi.com SIP/2.0"
            ?crlf "Via: SIP/2.0/UDP pc33.atlanta.com;branch=z9hG4bK776asdhds"
            ?crlf "Max-Forwards: 70"
            ?crlf "To: Bob <sip:bob@biloxi.com>"
            ?crlf "From: Alice <sip:alice@atlanta.com>;tag=1928301774"
            ?crlf "Call-ID: ", CallId/binary,
            ?crlf "CSeq: 314159 INVITE"
            ?crlf "Contact: <sip:alice@pc33.atlanta.com>"
            ?crlf "Content-Type: application/sdp"
            ?crlf "Content-Length: 4"
            ?crlf ?crlf "Test"
          >>,
    P  = ersip_parser:new_dgram(Msg),
    { {ok, PMsg}, _P2 } = ersip_parser:parse(P),
    { ok, SipMsg } = ersip_sipmsg:parse(PMsg, []),
    ?assertEqual(ersip_hdr_callid:make(CallId),        ersip_sipmsg:get(callid, SipMsg)),
    ?assertEqual(ersip_hdr_maxforwards:make(<<"70">>), ersip_sipmsg:get(maxforwards, SipMsg)),
    From = ersip_sipmsg:get(from, SipMsg),
    To   = ersip_sipmsg:get(to, SipMsg),
    ?assertEqual({tag, <<"1928301774">>},       ersip_hdr_fromto:tag(From)),
    ?assertEqual({display_name, [ <<"Bob">> ]}, ersip_hdr_fromto:display_name(To)),
    Via  = ersip_sipmsg:get(topmost_via, SipMsg),
    ?assertEqual({sent_by, { hostname, <<"pc33.atlanta.com">> }, 5060 },
                 ersip_hdr_via:sent_by(Via)).

parse_no_required_field_test() ->
    CallId = <<"a84b4c76e66710@pc33.atlanta.com">>,
    Msg = <<"INVITE sip:bob@biloxi.com SIP/2.0"
            ?crlf "Via: SIP/2.0/UDP pc33.atlanta.com;branch=z9hG4bK776asdhds"
            ?crlf "Max-Forwards: 70"
            ?crlf "To: Bob <sip:bob@biloxi.com>"
            ?crlf "Call-ID: ", CallId/binary,
            ?crlf "CSeq: 314159 INVITE"
            ?crlf "Contact: <sip:alice@pc33.atlanta.com>"
            ?crlf "Content-Type: application/sdp"
            ?crlf "Content-Length: 4"
            ?crlf ?crlf "Test"
          >>,
    P  = ersip_parser:new_dgram(Msg),
    { {ok, PMsg}, _P2 } = ersip_parser:parse(P),
    ?assertMatch({ error, _ }, ersip_sipmsg:parse(PMsg, all)).


parse_on_demand_parse_erorr_test() ->
    CallId = <<"a84b4c76e66710@pc33.atlanta.com">>,
    Msg = <<"INVITE sip:bob@biloxi.com SIP/2.0"
            ?crlf "Via: SIP/2.0/UDP pc33.atlanta.com;branch=z9hG4bK776asdhds"
            ?crlf "Max-Forwards: 70"
            ?crlf "To: Bob <sip:bob@biloxi.com>"
            ?crlf "From: Alice <sip:alice@atlanta.com>;tag=1928301774"
            ?crlf "Call-ID: ", CallId/binary,
            ?crlf "CSeq: 314159 INVITE"
            ?crlf "Contact: <sip:alice@pc33.atlanta.com>"
            ?crlf "Content-Type: x"
            ?crlf "Content-Length: 4"
            ?crlf ?crlf "Test"
          >>,
    P  = ersip_parser:new_dgram(Msg),
    { {ok, PMsg}, _P2 } = ersip_parser:parse(P),
    { ok, SipMsg } = ersip_sipmsg:parse(PMsg, []),
    ?assertEqual(ersip_hdr_callid:make(CallId), ersip_sipmsg:get(callid, SipMsg)),
    ?assertError({error, _ }, ersip_sipmsg:get(content_type, SipMsg)).