$LOAD_PATH.unshift(File.expand_path("../", __FILE__))
require "kconv"
require "mechanize"
require "time"
require "cgi"
require "sosowa/version"
require "sosowa/scheme"
require "sosowa/parser"

module Sosowa
  BASE_URL = "http://coolier.sytes.net:8080/sosowa/ssw_l"
  
  def self.get(args={})
    args[:log] ||= 0
    parser = Parser.new
    if args.has_key?(:key)
      parser.fetch_novel(args[:log], args[:key])
    else
      parser.fetch_index(args[:log])
    end
  end
end
