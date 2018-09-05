module QuickSearch
  class ArclightSearcher < QuickSearch::Searcher

    def search
      resp = @http.get(base_url, parameters)
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
          result.title = value['attributes']['title_ssm'][0]
          result.link = value['links']['self']
          if value['attributes'].key?('normalized_date_ssm')
            result.date = value['attributes']['normalized_date_ssm'][0]
          end
          if value['attributes'].key?('collection_ssm')
            result.collection = [value['attributes']['collection_ssm'][0], collection_builder(value['attributes']['ead_ssi']).to_s]
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
      "http://169.226.92.29/catalog"
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
      collection_link = URI::join(base_url, +"/" + uri.tr(".", "-"))

      collection_link
    end

    def total
      @response['meta']['pages']['total_count'].to_i
    end

    def loaded_link
      "http://169.226.92.29?search_field=all_fields&q=" + http_request_queries['not_escaped']
    end

  end
end
