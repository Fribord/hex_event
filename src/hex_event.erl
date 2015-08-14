%%%---- BEGIN COPYRIGHT -------------------------------------------------------
%%%
%%% Copyright (C) 2007 - 2014, Rogvall Invest AB, <tony@rogvall.se>
%%%
%%% This software is licensed as described in the file COPYRIGHT, which
%%% you should have received as part of this distribution. The terms
%%% are also available at http://www.rogvall.se/docs/copyright.txt.
%%%
%%% You may opt to use, copy, modify, merge, publish, distribute and/or sell
%%% copies of the Software, and permit persons to whom the Software is
%%% furnished to do so, under the terms of the COPYRIGHT file.
%%%
%%% This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
%%% KIND, either express or implied.
%%%
%%%---- END COPYRIGHT ---------------------------------------------------------
%%%-------------------------------------------------------------------
%%% @author Tony Rogvall <tony@rogvall.se>
%%% @doc
%%%    Hex event plugin 
%%% @end
%%% Created :  7 Feb 2014 by Tony Rogvall <tony@rogvall.se>
%%%-------------------------------------------------------------------
-module(hex_event).

-behaviour(hex_plugin).

-export([validate_event/2, 
	 event_spec/1,
	 init_event/2,
	 mod_event/2,
	 add_event/3, 
	 del_event/1, 
	 output/2]).

%%
%%  add_event(Flags::[{atom(),term()}, Signal::signal(), Cb::function()) ->    
%%     {ok, Ref:reference()} | {error, Reason}
%%
add_event(_Flags, _Signal, _Cb) ->
    {ok, make_ref()}.

%%
%%  del_event(Ref::reference()) ->
%%     ok.
del_event(_Ref) ->
    ok.

%%
%% output(Flags::[{atom(),term()}], Env::[{atom(),term()}]) ->
%%    ok.
%%
output(Flags, Env) ->
    case lists:keytake(type, 1, Flags) of
	{value,{type,Type},Options} ->
	    hex:inform(Type, expand_env(Options,Env)),
	    ok;
	_ ->
	    lager:error("output has no type", [])
    end.

%%
%% init_event(in | out, Flags::[{atom(),term()}])
%%
init_event(_, _) ->
    ok.

%%
%% mod_event(in | out, Flags::[{atom(),term()}])
%%
mod_event(_, _) ->
    ok.

%%
%% validate_event(in | out, Flags::[{atom(),term()}])
%%
validate_event(_Dir, _Flags) ->
    ok.

%%
%% return event specification in internal YANG format
%% {Type,Value,Stmts}
%%
event_spec(_Dir) ->
    [].


%% expand keys from environment. value on form {env,env_key} will lookup
%% value of env_key in environment.
expand_env([{Key,{env,EKey}}|Flags], Env) when is_atom(Key),is_atom(EKey) ->
    Value = proplists:get_value(EKey, Env, 0),
    [{Key,Value} | expand_env(Flags, Env)];
expand_env([Kv={Key,_Value}|Flags], Env) when is_atom(Key) ->
    [Kv | expand_env(Flags, Env)];
expand_env([], _Env) ->
    [].


    

    
