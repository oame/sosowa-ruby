module Sosowa
  class Parser    
    
    def initialize
      @agent = Mechanize.new
      @agent.user_agent = "Sosowa Ruby #{Sosowa::VERSION}"
    end
    
    def search(query, args={})
      params = Sosowa.serialize_parameter({:mode => :search, :type => (args[:type] ? args[:type] : :insubject), :query => query.tosjis})
      parse_index(@agent.get(URI.join(Sosowa::BASE_URL, params)))
    end
    
    def fetch_index(log)
      params = Sosowa.serialize_parameter({:log => log})
      page = @agent.get(URI.join(Sosowa::BASE_URL, params))
      indexes = parse_index(page)
      abs_log_num = parse_absolute_log_number(page)
      Log.new(indexes, abs_log_num)
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
    
    def parse_index(page)
      indexes = []
      tr = page.search("tr")
      tr = tr[1, tr.size-1]
      num = 1
      tr.each do |tr|
        if (tr/%{td[@class="tags"]}).size > 0
          #tags = (tr/%{td[@class="tags"]})[0].inner_html.to_s.toutf8.strip.gsub(/^.+?: /, "").split(/\s/)
          #indexes[num-1] << tags
        else
          title = tr.search(%{td[@class="title cell_title"] > a}).inner_html.to_s.toutf8.strip
          tags = tr.search(%{td[@class="title cell_title"] > a})[0].attributes["title"].value.split(" / ")
          log = tr.search(%{td[@class="title cell_title"] > a})[0].attributes["href"].value.gsub(/log=(\d+)$/, '\1').to_i
          key = tr.search(%{td[@class="title cell_title"] > a})[0].attributes["href"].value.gsub(/^.+key=(.+?)&.+$/, '\1').to_i
          author = tr.search(%{td[@class="cell_author"]}).inner_html.to_s.toutf8.strip
          created_at = Time.parse(tr.search(%{td[@class="cell_created"]}).inner_html.to_s.toutf8.strip)
          updated_at = Time.parse(tr.search(%{td[@class="cell_lastup"]}).inner_html.to_s.toutf8.strip)
          eval = tr.search(%{td[@class="cell_eval"]}).inner_html.to_s.toutf8.strip.split("/")
          review_count = eval[1].to_i
          comment_count = eval[0].to_i
          point = tr.search(%{td[@class="cell_point"]}).inner_html.to_s.toutf8.strip.to_i
          rate = tr.search(%{td[@class="cell_rate"]}).inner_html.to_s.toutf8.strip.to_f
          size = tr.search(%{td[@class="cell_size"]}).inner_html.to_s.toutf8.strip
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
            :size => size
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