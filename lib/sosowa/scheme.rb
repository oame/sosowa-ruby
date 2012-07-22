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
    def initialize(args)
      @log = args[:log] || 0
      @key = args[:key]
      @agent = Mechanize.new
      @page = nil
      super(fetch(@log, @key))
    end
    
    def fetch(log, key)
      params = Sosowa.serialize_parameter({:mode => :read, :log => log, :key => key})
      @page = @agent.get(URI.join(Sosowa::BASE_URL, params))
      title = (@page/%{div[@class="header"] > h1})[0].inner_html.to_s.toutf8.strip
      tags = (@page/%{dl[@class="info"][1] > dd > a}).map{|t| t.inner_html.to_s.toutf8 }
      text = (@page/%{div[@class="contents ss"]})[0].inner_html.to_s.toutf8
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
            :created_at => Time.parse(bobj[1].gsub(/[^\/\d\s:]/, "")),
            :text => element[1].inner_html.to_s.toutf8.strip
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
        :created_at => Time.parse(header[1][1]),
        :updated_at => Time.parse(header[2][1]),
        :review_count => review[1].to_i,
        :comment_count => review[0].to_i,
        :point => header[4][1].to_i,
        :rate => header[5][1].to_f,
        :comments => comments
      }
      return novel
    end
    
    def simple_rating(point)
      form = @page.forms[0]
      form.click_button(form.button_with(:value => point.to_s))
    end
    
    def comment(text, params)
      form = @page.forms[1]
      form.field_with(:name => "name").value = params[:name] || nil
      form.field_with(:name => "body").value = text
      form.field_with(:name => "pass").value = params[:pass] || nil
      form.field_with(:name => "mail").value = params[:mail] || nil
      form.field_with(:name => "point").option_with(:value => (params[:point].to_s || "0")).select
      form.click_button
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
    attr_reader :element
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