# coding: utf-8

module Sosowa
  class Scheme
    attr_reader :element
    
    def initialize(element)
      @element = element  
    end
    
    def method_missing(action, *args)
      return @element[action.to_s.to_sym] rescue nil
    end
    
    def params() @element.keys.map{|k|k.to_sym} ; end
    alias_method :available_methods, :params
    
    def to_hash
      @element
    end
  end
  
  class Novel < Scheme
    attr_reader :log
    attr_reader :key
    attr_reader :page

    def initialize(args)
      @log = args[:log] || 0
      @key = args[:key]
      @page = nil
      super(fetch(@log, @key))
    end
    
    def fetch(log, key)
      @page = Sosowa.send_req({:mode => :read, :log => log, :key => key})
      title = (@page/%{div[@class="header"] > h1})[0].inner_html.to_s.toutf8.strip
      tags = (@page/%{dl[@class="info"][1] > dd > a}).map{|t| t.inner_html.to_s.toutf8 }
      text = ""
      text_node = @page/%{div[@class="contents ss"]}
      text_node.children.each do |node|
        text += node.inner_html.to_s.toutf8.strip
      end
      aft = @page/%{div[@class="aft"]}
      ps = (aft.size > 0) ? aft[0].inner_html.to_s.toutf8 : ""
      author_name = (@page/%{div[@class="author"] b})[0].inner_html.to_s.toutf8
      author_email, author_website = (@page/%{div[@class="author"] a}).map{|e| e.attributes["href"].value}
      author = Author.new(:name => author_name, :email => (author_email ? author_email.gsub(/^mailto:/, "") : nil), :website => author_website)
      header = (@page/%{div[@class="header"] > span})[0].inner_html.to_s.toutf8.split(/\r?\n/).map{|n| n.strip}.reject{|n| n == ""}.map{|n| n.split(": ")}
      review = header[3][1].split("/")
      comments = []
      comment_element = (@page/%{div[@class="comments"] > dl > *})
      if comment_element.size > 0
        comment_element[1, comment_element.size-1].each_slice(2) do |element|
          bobj = element[0].search("b").map{|n| n.inner_html.to_s.toutf8.strip}
          point = element[0].search("span").inner_html.to_s.toutf8.to_i
          id = element[0].inner_html.to_s.toutf8.split(/\r?\n/).map{|n| n.strip}[1].to_i
          comment = Comment.new(
            :id => id,
            :point => point,
            :name => bobj[0],
            :created_at => bobj[1] ? Time.parse(bobj[1].gsub(/[^\/\d\s:]/, "")) : nil,
            :text => element[1] ? element[1].inner_html.to_s.toutf8.strip : nil
          )
          comments << comment
        end
      end
      novel = {
        :title => title,
        :text => text,
        :ps => ps,
        :author => author,
        :tags => tags,
        :log => log,
        :key => key,
        :created_at => Time.parse(header[1][1]).strftime("%Y/%m/%d %H:%M:%S"),
        :updated_at => Time.parse(header[2][1]).strftime("%Y/%m/%d %H:%M:%S"),
        :review_count => review[1].to_i,
        :comment_count => review[0].to_i,
        :point => header[4][1].to_i,
        :rate => header[5][1].to_f,
        :comments => comments
      }
      return novel
    end
    
    def simple_rating(point)
      # Get cookie
      get_params = Sosowa.serialize_parameter({
        :mode => :read,
        :key => @key,
        :log => @log
      })
      http = Net::HTTP.new(BASE_URL.host, BASE_URL.port)
      req = Net::HTTP::Get.new(BASE_URL.path)
      req["User-Agent"] = "Sosowa Ruby Wrapper #{Sosowa::VERSION}"
      res = http.request(req, get_params)
      cookie = res["Set-Cookie"]

      # Post Comment
      post_uri_params = Sosowa.serialize_parameter({
        :mode => :update,
        :key => @key,
        :log => @log,
        :target => :res
      })
      post_params = Sosowa.serialize_parameter({:body => "#EMPTY#".tosjis, :point => point}, false)
      req = Net::HTTP::Post.new(File.join(BASE_URL.path, post_uri_params))
      req["Cookie"] = cookie
      req["User-Agent"] = "Sosowa Ruby Wrapper #{Sosowa::VERSION}"
      res = http.request(req, post_params)
      return res
    end
    
    def comment(text, params={})
      # Get cookie
      get_params = Sosowa.serialize_parameter({
        :mode => :read,
        :key => @key,
        :log => @log
      })
      http = Net::HTTP.new(BASE_URL.host, BASE_URL.port)
      req = Net::HTTP::Get.new(BASE_URL.path)
      req["User-Agent"] = "Sosowa Ruby Wrapper #{Sosowa::VERSION}"
      res = http.request(req, get_params)
      cookie = res["Set-Cookie"]

      # Post Comment
      post_uri_params = Sosowa.serialize_parameter({
        :mode => :update,
        :key => @key,
        :log => @log,
        :target => :res
      })
      params.each do |k, v|
        params[k] = v.tosjis
      end
      post_params = Sosowa.serialize_parameter({:body => text.tosjis}.update(params), false)
      req = Net::HTTP::Post.new(File.join(BASE_URL.path, post_uri_params))
      req["Cookie"] = cookie
      req["User-Agent"] = "Sosowa Ruby Wrapper #{Sosowa::VERSION}"
      res = http.request(req, post_params)
      return res
    end
    
    def plain
      return @element[:text].gsub(/(<br>|\r?\n)/, "")
    end
  end
  
  class Comment < Scheme
    
  end
  
  class Author < Scheme
    
  end
  
  class Index < Scheme    
    def fetch
      Novel.new(:log => @element[:log], :key => @element[:key])
    end
    alias_method :get, :fetch
  end

  class Log < Array
    attr_accessor :element
    attr_reader :log
    
    def initialize(element, page, log=0)
      super(element)
      @element = element
      @page = page
      @log = log
    end

    def next_page
      parser = Parser.new
      parser.fetch_index(@log-1)
    end
    alias_method :next, :next_page

    def prev_page
      parser = Parser.new
      parser.fetch_index(@log+1)
    end
    alias_method :prev, :prev_page
    
    def latest_log
      parser = Parser.new
      parser.parse_latest_log_number(@page)
    end
  end
end