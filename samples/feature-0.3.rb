#!/usr/bin/env ruby
# coding: utf-8

require "sosowa"

# 最新版の作品集を取得
latest = Sosowa.get

# 最新版よりひとつ古い作品集を取得
next_log = latest.next_page

# 最近版から直近3ページまで遡ってSSのタイトルを列挙する
3.times do |n|
  Sosowa.get(:log => latest.log - n).each do |index|
    puts index.title
  end
end  