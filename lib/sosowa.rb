# coding: utf-8

require "megalopolis"

$LOAD_PATH.unshift(File.expand_path("../", __FILE__))
require "sosowa/version"

module Sosowa
  BASE_URL = "http://coolier.sytes.net/sosowa/ssw_l/"
  
  def self.get(args={})
    args[:log] ||= 0
    megalopolis = Megalopolis.new(BASE_URL)
    megalopolis.get args
  end
  
  #def self.search(query, args={})
  #  parser = Parser.new
  #  parser.search(query, args)
  #end
end
