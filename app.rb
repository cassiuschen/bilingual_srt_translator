#!/usr/bin/env ruby
require "bundler/setup"
require 'yaml'
require 'dotenv'
require 'optparse'
require 'openai'
require 'concurrent'
require 'tty-spinner'

# 加载模块
require_relative 'lib/bilingual_srt' # 入口文件

# 加载环境变量
Dotenv.load

# 执行应用
BilingualSrtApp.new.run