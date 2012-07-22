#!/usr/bin/env ruby
# coding: utf-8

require "sosowa"

# 最初の作品集を取得
log = Sosowa.get :log => 1

# 最新版の作品集番号を取得
latest_log = log.latest_log

# 作品集に入っているSSの数を返す
puts log.size