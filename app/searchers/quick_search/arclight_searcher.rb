module QuickSearch
  class ArclightSearcher < QuickSearch::Searcher

    def search
      @http.ssl_config.verify_mode=(OpenSSL::SSL::VERIFY_NONE)
      resp = @http.get(base_url, parameters.to_query)
      @response = JSON.parse(resp.body)
    end

    def results
      
      if results_list
        results_list

      else
        @results_list = []

        #@match_fields = ['title_ssm', ]
        @response['data'].each do |value|
          result = OpenStruct.new
          result.title = value['attributes']['title_ssm']['attributes']['value']
          result.link = value['links']['self']
          if value['attributes'].key?('normalized_date_ssm')
            result.date = value['attributes']['normalized_date_ssm']['attributes']['value']
          end
          if value['attributes'].key?('collection_ssim')
            if value['attributes'].key?('ead_ssi')
              result.collection = [value['attributes']['collection_ssim']['attributes']['value'], collection_builder(value['attributes']['ead_ssi']['attributes']['value']).to_s]
            else
              result.collection = [value['attributes']['collection_ssim']['attributes']['value'], collection_builder(value['attributes']['parent_ssim']['attributes']['value'][0]).to_s]
            end
          end
          puts result
          if value['attributes'].key?('parent_unittitles_ssm')
              if value['attributes']['parent_unittitles_ssm']['attributes']['value'].length > 1
                result.series = value['attributes']['parent_unittitles_ssm']['attributes']['value'][1]       
                result.series_url = URI::join(base_url, +"/description/catalog/" + value['attributes']['parent_ssim']['attributes']['value'][0] + value['attributes']['parent_ssim']['attributes']['value'][1])         
              end
              if value['attributes']['parent_unittitles_ssm']['attributes']['value'].length > 2
                result.subseries = value['attributes']['parent_unittitles_ssm']['attributes']['value'][2]       
                result.subseries_url = URI::join(base_url, +"/description/catalog/" + value['attributes']['parent_ssim']['attributes']['value'][0] + value['attributes']['parent_ssim']['attributes']['value'][2])         
              end 
              if value['attributes']['parent_unittitles_ssm']['attributes']['value'].length > 3
                result.subsubseries = value['attributes']['parent_unittitles_ssm']['attributes']['value'][2]       
                result.subsubseries_url = URI::join(base_url, +"/description/catalog/" + value['attributes']['parent_ssim']['attributes']['value'][0] + value['attributes']['parent_ssim']['attributes']['value'][2])         
              end 
              if value['attributes']['parent_unittitles_ssm']['attributes']['value'].length > 4
                result.subsubsubseries = value['attributes']['parent_unittitles_ssm']['attributes']['value'][2]       
                result.subsubsubseries_url = URI::join(base_url, +"/description/catalog/" + value['attributes']['parent_ssim']['attributes']['value'][0] + value['attributes']['parent_ssim']['attributes']['value'][2])         
              end 
          end
          
          if value['attributes'].key?('repository_ssim')
            result.collecting_area = value['attributes']['repository_ssim']['attributes']['value']
            if result.collecting_area == "University Archives"
              result.collecting_area_url = URI::join(base_url, +"/description/repositories/ua")
            elsif result.collecting_area == "New York State Modern Political Archive"
              result.collecting_area_url = URI::join(base_url, +"/description/repositories/apap")
            elsif result.collecting_area == "National Death Penalty Archive"
              result.collecting_area_url = URI::join(base_url, +"/description/repositories/ndpa")
            elsif result.collecting_area == "Business, Literary, and Local History Manuscripts"
              result.collecting_area_url = URI::join(base_url, +"/description/repositories/mss")
            else
              result.collecting_area_url = URI::join(base_url, +"/description/repositories/ger")
            end
          end
          
          if value['attributes']['has_online_content_ssim'][0] == "true"
            result.availability = "online content"
          end

          @results_list << result
        end
	
        @results_list
      end

    end

    def base_url
      "https://archives.albany.edu/description/catalog"
    end

    def parameters
      {
        'search_field' => 'all_fields',
        'q' => http_request_queries['not_escaped'],
        'utf8' => true,
        'per_page' => @per_page,
        'format' => 'json'
      }
    end

    def collection_builder(uri)
      collection_link = URI::join(base_url, +"/description/catalog/" + uri.tr(".", "-"))

      collection_link
    end

    def total
      @response['meta']['pages']['total_count'].to_i
    end

    def loaded_link
      "https://archives.albany.edu/description/catalog?search_field=all_fields&group=true&q=" + http_request_queries['not_escaped']
    end

  end
end
