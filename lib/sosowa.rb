# coding: utf-8

require "kconv"
require "mechanize"
require "time"
require "uri"

$LOAD_PATH.unshift(File.expand_path("../", __FILE__))
require "sosowa/version"
require "sosowa/scheme"
require "sosowa/parser"

module Sosowa
  BASE_URL = "http://coolier.sytes.net:8080/sosowa/ssw_l/"

  protected
  
  # @param [Hash] parameter
  # @return [String] URL Serialized parameters
  def self.serialize_parameter parameter
    return "" unless parameter.class == Hash
    ant = Hash.new
    parameter.each do |key, value|
      ant[key.to_sym] = value.to_s
    end
    param = ant.inject(""){|k,v|k+"&#{v[0]}=#{URI.escape(v[1])}"}.sub!(/^&/,"?")
    return param ? param : ""
  end

  public
  
  def self.get(args={})
    args[:log] ||= 0
    parser = Parser.new
    if args.has_key?(:key)
      parser.fetch_novel(args[:log], args[:key])
    else
      parser.fetch_index(args[:log])
    end
  end
  
  def self.search(query, args={})
    parser = Parser.new
    parser.search(query, args)
  end
end
