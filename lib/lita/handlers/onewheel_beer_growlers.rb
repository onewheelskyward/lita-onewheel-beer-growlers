require 'rest-client'
require 'nokogiri'
require 'sanitize'
require 'lita-onewheel-beer-base'

module Lita
  module Handlers
    class OnewheelBeerGrowlers < OnewheelBeerBase
      route /^growlers/i,
            :taps_list,
            command: true,
            help: {'growlers' => 'Display the current Apex Bar taps.'}

      route /^growlers ([\w ]+)$/i,
            :taps_deets,
            command: true,
            help: {'growlers 4' => 'Display the tap 4 deets, including prices.'}

      route /^growlers ([<>=\w.\s]+)%$/i,
            :taps_by_abv,
            command: true,
            help: {'growlers >4%' => 'Display beers over 4% ABV.'}

      route /^growlers ([<>=\$\w.\s]+)$/i,
            :taps_by_price,
            command: true,
            help: {'growlers <$5' => 'Display beers under $5.'}

      route /^growlers (roulette|random)$/i,
            :taps_by_random,
            command: true,
            help: {'growlers roulette' => 'Can\'t decide?  Let me do it for you!'}

      route /^growlersabvlow$/i,
            :taps_low_abv,
            command: true,
            help: {'growlersabvlow' => 'Show me the lowest abv keg.'}

      route /^growlersabvhigh$/i,
            :taps_high_abv,
            command: true,
            help: {'growlersabvhigh' => 'Show me the highest abv keg.'}

      def send_response(tap, datum, response)
        reply = "Growlers tap #{tap}) #{get_tap_type_text(datum[:type])}"
        # reply += "#{datum[:brewery]} "
        reply += "#{datum[:name]} "
        # reply += "- #{datum[:desc]}, "
        # reply += "Served in a #{datum[1]['glass']} glass.  "
        # reply += "#{datum[:remaining]}"
        # reply += "#{datum[:abv]}%, "
        reply += "$#{datum[:price].to_s.sub '.0', ''}"

        Lita.logger.info "send_response: Replying with #{reply}"

        response.reply reply
      end

      def get_source
        Lita.logger.debug 'get_source started'
        unless (response = redis.get('page_response'))
          Lita.logger.info 'No cached result found, fetching.'
          response = RestClient.get('http://visualizeapi.com/api/hawthorne')
          redis.setex('page_response', 1800, response)
        end
        parse_response response
      end

      # This is the worker bee- decoding the html into our "standard" document.
      # Future implementations could simply override this implementation-specific
      # code to help this grow more widely.
      def parse_response(response)
        gimme_what_you_got = {}
        response_doc = JSON.parse(response)
        response_doc['data'].each do |id, tap|
          tap_name = id

          brewery = tap['brewery']
          beer_name = tap['beer']

          beer_type = tap['style']
          # beer_type.sub! /\s+-\s+/, ''

          # abv = beer_node.css('td')[4].children.to_s
          full_text_search = "#{brewery} #{beer_name.to_s.gsub /(\d+|')/, ''}"  # #{beer_desc.to_s.gsub /\d+\.*\d*%*/, ''}

          price = (tap['prices'][0].sub /\$/, '').to_f

          gimme_what_you_got[tap_name] = {
          #     type: tap_type,
          #     remaining: remaining,
              brewery: brewery.to_s,
              name: beer_name.to_s,
              desc: beer_type.to_s,
              # abv: abv.to_f,
              price: price,
              search: full_text_search
          }
        end

        gimme_what_you_got
      end

      Lita.register_handler(self)
    end
  end
end
