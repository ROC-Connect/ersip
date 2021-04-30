#
# Copyright (c) 2017 Dmitry Poroh
# All rights reserved.
# Distributed under the terms of the MIT License. See the LICENSE file.
#
# Test run simplification
#

#SHELL=/bin/bash

#tests:
#	export ERL_FLAGS=$(ERL_FLAGS) ; rebar3 do eunit -v --cover, cover | sed 's/^_build\/test\/lib\/ersip\///' ; exit "$${PIPESTATUS[0]}"
#	rebar3 dialyzer
#
#
#
#
PROJECT = ersip
PROJECT_DESCRIPTION = sip pure functions handler

COMMIT_ID   = $(shell git log -n 1 |head -n 1| awk '/commit/ {print $$2;}')
COMMIT_DATE = $(shell git log -n 1 | awk '/Date: / {$$1="";gsub(/^ /, "");print}')
BRANCH      = $(shell git describe --all | awk -F"/" '{gsub(/remotes|origin|heads|tags|\//,"");print}')
TIME = $(shell date)
WHO = $(shell whoami)
PCNAME= $(shell hostname)
PROJECT_VERSION=${BRANCH}-${COMMIT_ID}
RELX_OUTPUT_DIR = _rel/$(TYPE)

export ERLC_OPTS ?= -W0 +compressed +no_debug_info +bin_opt_info +warn_export_all +warn_export_vars +warn_shadow_vars +warn_obsolete_guard
include erlang.mk

