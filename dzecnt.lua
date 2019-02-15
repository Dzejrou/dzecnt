#!/usr/bin/luajit

local cont = require "cont"
local const = require "const"
local config = require "config"
local pipe = require "pipe"

local conf = config:new():parse(arg)
cont.spawn(conf, const.clone.all)

cont.wait()
