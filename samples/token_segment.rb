#!/usr/bin/env ruby
# coding: utf-8
# 創想話の最新版から適当なSSを取得してMeCab(+ 東方MeCab辞書)を用いてトークナイズします。

require "MeCab"
require "sosowa"

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
end

puts "Fetching thdic-mecab..."
system("curl -L https://github.com/oame/thdic-mecab/raw/master/pkg/thdic-mecab.dic > thdic-mecab.dic")

puts "Done. Initialize MeCab::Tagger"
mecab = MeCab::Tagger.new("-u thdic-mecab.dic")

text = Sosowa.get.sample.fetch.text.gsub(/(<br>|\r?\n)/, "")
tokens = mecab.parseToNode(text)
tokens.each do |token|
  puts token.feature
end