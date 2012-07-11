#!/usr/bin/env ruby
# coding: utf-8
# 創想話の最新版から適当なSSのテキストを取得してMeCab(+ 東方MeCab辞書)を用いて代表キーワード候補を名詞限定で選出し、TF-IDF法による特徴語抽出を行います。
# 注意: ugigi gemが必要です

require "MeCab"
require "kconv"
require "sosowa"
require "ugigi"

module MeCab
  class Tagger
    alias_method :parseToNode_org, :parseToNode
    private :parseToNode_org

    def parseToNode(*args)
      node = parseToNode_org(*args)
      nodes = []
      while node
        nodes.push(node)
        node = node.next
      end
      return nodes[1, nodes.size - 2]
    end
  end
  
  class Node
    alias_method :feature_org, :feature
    alias_method :surface_org, :surface
    private :feature_org
    private :surface_org
    
    def feature ; feature_org.toutf8 end
    def surface ; surface_org.toutf8 end
  end
end

puts "東方MeCab辞書をダウンロード中..."
system("curl -L https://github.com/oame/thdic-mecab/raw/master/pkg/thdic-mecab.dic > thdic-mecab.dic")

puts "完了. MeCab::Taggerを初期化します"
mecab = MeCab::Tagger.new("-u thdic-mecab.dic")

novel = Sosowa.get.sample.fetch
puts "-"*30
puts novel.title
puts "作者: #{novel.author.name}"
puts "-"*30
text = novel.plain
tf = {}
n = 15646.0
puts "代表キーワード候補を抽出中..."
tokens = mecab.parseToNode(text)
tokens.each do |token|
  next unless token.feature =~ /名詞/
  tf[token.surface] ||= 0
  tf[token.surface] += 1
end

puts "代表キーワード候補数: #{tf.size}"

tfidf_list = []
tf.each do |e|
  print "TF: #{e[0]} ... \t"
  df = Ugigi.total_count(:free => e[0], :sswp => 0, :compe => 0)
  if df == 0
    print "N/A\n"
    tfidf_list << [e[0], 0]
    next
  end
  print "DF: #{df} \t"
  tfidf = e[1] * Math.log(n/df)
  print "TF-IDF: #{tfidf}\n"
  tfidf_list << [e[0], tfidf]
end
tfidf_list = tfidf_list.sort{|a, b| b[1] <=> a[1]}

puts "集計終わり！"

10.times do |n|
  l = tfidf_list[n]
  puts "#{n+1}. #{l[0]} \tTF-IDF: #{l[1]}"
end