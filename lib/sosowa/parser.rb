# coding: utf-8

module Sosowa
  class Parser
    def initialize
      
    end
    
    def search(query, args={})
      page = Sosowa.send_req({:mode => :search, :type => (args[:type] ? args[:type] : :insubject), :query => query.tosjis})
      parse_index(page)
    end
    
    def fetch_index(log)
      page = Sosowa.send_req({:log => log})
      indexes = parse_index(page)
      abs_log_num = parse_absolute_log_number(page)
      Log.new(indexes, page, abs_log_num)
    end

    def parse_absolute_log_number(page)
      li = page.search(%{ul[@id="pages"] li > *})
      log = li.size
      li.each do |l|
        if l.attributes["id"] && l.attributes["id"].value == "selectedPage"
          return log
        end
        log -= 1
      end
    end
    
    def parse_latest_log_number(page)
      li = page.search(%{ul[@id="pages"] li > *})
      return li.size
    end
    
    def parse_index(page)
      indexes = []
      tr = page.search("tr")
      tr = tr[1, tr.size-1]
      num = 1
      tr.each do |tr|
        unless (tr/%{td[@class="tags"]}).size > 0
          title = tr.search(%{td[@class="title cell_title"] > a})[0].children[0].text.strip
          tags = tr.search(%{td[@class="title cell_title"] > a})[0].attributes["title"].value.split(" / ").reject{|n| n == ""}
          log = parse_absolute_log_number(page)
          key = tr.search(%{td[@class="title cell_title"] > a})[0].attributes["href"].value.gsub(/^.+key=(.+?)&.+$/, '\1').to_i
          author = tr.search(%{td[@class="cell_author"]})[0].inner_html.to_s.strip
          created_at = Time.parse(tr.search(%{td[@class="cell_created"]})[0].inner_html.to_s.strip).strftime("%Y/%m/%d %H:%M:%S")
          updated_at = Time.parse(tr.search(%{td[@class="cell_lastup"]})[0].inner_html.to_s.strip).strftime("%Y/%m/%d %H:%M:%S")
          eval = tr.search(%{td[@class="cell_eval"]})[0].inner_html.to_s.strip.split("/")
          review_count = eval[1].to_i
          comment_count = eval[0].to_i
          point = tr.search(%{td[@class="cell_point"]})[0].inner_html.to_s.strip.to_i
          rate = tr.search(%{td[@class="cell_rate"]})[0].inner_html.to_s.strip.to_f
          size = tr.search(%{td[@class="cell_size"]})[0].inner_html.to_s.strip
          url = tr.search(%{td[@class="title cell_title"] > a})[0].attributes["href"].value
          index = {
            :log => log,
            :key => key,
            :title => title,
            :author => author,
            :created_at => created_at,
            :updated_at => updated_at,
            :review_count => review_count,
            :comment_count => comment_count,
            :point => point,
            :tags => tags,
            :rate => rate,
            :size => size,
            :url => URI.join(Sosowa::BASE_URL, "?mode=read&key=#{key}&log=#{log}").to_s
          }
          indexes << Index.new(index)
        end
        num += 1
      end
      return indexes
    end
    
    def fetch_novel(log, key)
      novel = Novel.new(:log => log, :key => key)
      return novel
    end
  end
end