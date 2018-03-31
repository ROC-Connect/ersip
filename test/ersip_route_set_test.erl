%%
%% Copyright (c) 2018 Dmitry Poroh
%% All rights reserved.
%% Distributed under the terms of the MIT License. See the LICENSE file.
%%
%% SIP Route Set test
%%

-module(ersip_route_set_test).

-include_lib("eunit/include/eunit.hrl").

%%%===================================================================
%%% Cases
%%%===================================================================

is_empty_test() ->
    Empty = ersip_route_set:new(),
    ?assertEqual(true, ersip_route_set:is_empty(Empty)),
    Route = ersip_hdr_route:make_route(<<"<sip:a@b>">>),
    NotEmpty = ersip_route_set:add_first(Route, Empty),
    ?assertEqual(false, ersip_route_set:is_empty(NotEmpty)),
    ok.

first_and_last_test() ->
    Empty = ersip_route_set:new(),
    ?assertError({ error, _ }, ersip_route_set:last(Empty)),
    ?assertError({ error, _ }, ersip_route_set:first(Empty)),
    Route1 = ersip_hdr_route:make_route(<<"<sip:a@b>">>),
    Len1 = ersip_route_set:add_first(Route1, Empty),
    ?assertEqual(Route1, ersip_route_set:last(Len1)),
    ?assertEqual(Route1, ersip_route_set:first(Len1)),

    Route2 = ersip_hdr_route:make_route(<<"<sip:b@a>">>),
    Len2 = ersip_route_set:add_first(Route2, Len1),
    ?assertEqual(Route1, ersip_route_set:last(Len2)),
    ?assertEqual(Route2, ersip_route_set:first(Len2)),
    ok.
    
