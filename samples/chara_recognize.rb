#!/usr/bin/env ruby
# coding: utf-8
# 創想話の最新版から適当なSSのテキストを取得してMeCab(+ 東方MeCab辞書)を用いてテキスト中のセリフの発言者を予測します。
# 精度低いので誰かちゃんとしたの作ってください！

require "mecab-modern"
require "kconv"
require "sosowa"
require "pp"

puts "東方MeCab辞書をダウンロード中..."
system("curl -L https://github.com/oame/thdic-mecab/raw/master/pkg/thdic-mecab.dic > thdic-mecab.dic") unless FileTest.exists? "thdic-mecab.dic"

puts "完了. MeCab::Taggerを初期化します"
mecab = MeCab::Tagger.new#("-u thdic-mecab.dic")

#novel = Sosowa.get.sample.fetch
novel = Sosowa.get(:log => 170, :key => 1342037924)
puts "-"*30
puts novel.title
puts "作者: #{novel.author.name}"
puts "-"*30
lines = novel.text.gsub(/\r?\n/, "").split("<br>").reject{|t| t == ""}.map{|n| n.strip}
num = 0
lines.each do |line|
  name_nodes = mecab.parseToNode(line).select{|n| n.feature =~ /名詞,固有名詞,人名/}
  unless name_nodes[0]
    num += 1
    next
  end
  unless lines[num+1] =~ /(「|」)/
    num += 1
    next
  end
  puts "#{name_nodes[0].surface}: #{lines[num+1]}"
  num += 1
end