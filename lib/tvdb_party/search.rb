module TvdbParty
  class Search
    include HTTParty
    include HTTParty::Icebox
    attr_accessor :language
    cache :store => 'file', :timeout => 120, :location => Dir.tmpdir
    
    base_uri 'www.thetvdb.com/api'

    def initialize(the_api_key, language = 'en')
      @api_key = the_api_key
      @language = language
    end
    
    def search(series_name)
      response = self.class.get("/GetSeries.php", {:query => {:seriesname => series_name, :language => @language}})
      return [] unless response["Data"]
      
      case response["Data"]["Series"]
      when Array
        response["Data"]["Series"]
      when Hash
        [response["Data"]["Series"]]
      else
        []
      end
    end

    def get_series_by_id(series_id, language = self.language)
      response = self.class.get("/#{@api_key}/series/#{series_id}/#{language}.xml")
      if response["Data"] && response["Data"]["Series"]
        Series.new(self, response["Data"]["Series"])
      else
        nil
      end
    end
    
    def get_episode(series, season_number, episode_number, language = self.language)
      response = self.class.get("/#{@api_key}/series/#{series.id}/default/#{season_number}/#{episode_number}/#{language}.xml")
      if response["Data"] && response["Data"]["Episode"]
        Episode.new(response["Data"]["Episode"])
      else
        nil
      end
    end

    def get_banners(series)
      response = self.class.get("/#{@api_key}/series/#{series.id}/banners.xml")
      return [] unless response["Banners"] && response["Banners"]["Banner"]
      case response["Banners"]["Banner"]
      when Array
        response["Banners"]["Banner"].map{|result| Banner.new(result)}
      when Hash
        [Banner.new(response["Banners"]["Banner"])]
      else
        []
      end
    end

  end
end