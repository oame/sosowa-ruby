#!/usr/bin/env ruby
# coding: utf-8
# 創想話の最新版から適当なSSを取得してMeCab(+ 東方MeCab辞書)を用いてトークナイズします。
# mecab-modern gemが必要です

require "mecab-modern"
require "sosowa"

puts "Fetching thdic-mecab..."
system("curl -L https://github.com/oame/thdic-mecab/raw/master/pkg/thdic-mecab.dic > thdic-mecab.dic") unless FileTest.exists? "thdic-mecab.dic"

puts "Done. Initialize MeCab::Tagger"
mecab = MeCab::Tagger.new("-u thdic-mecab.dic")

text = Sosowa.get.sample.fetch.text.gsub(/(<br>|\r?\n)/, "")
tokens = mecab.parseToNode(text)
tokens.each do |token|
  puts token.feature
end