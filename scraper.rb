#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('.circonscrption h1').each do |h1|
    matched = h1.text.match(/No. (\d+) - (.*)/) or raise "Odd area: #{h1.text}" 
    area_id, area = matched.captures

    winners = (area_id.to_i == 21) ? 2 : 3
    h1.xpath('./following-sibling::table//tr[td]').take(winners).each do |winner|
      tds = winner.css('td')
      sort_name = tds[0].text.tidy.sub(/^\d+\. /,'')
      family_name, given_name = sort_name.split(', ', 2)

      data = { 
        name: "#{given_name} #{family_name}",
        sort_name: sort_name,
        given_name: given_name,
        sort_name: sort_name,
        party: tds[2].text.tidy,
        area_id: area_id,
        area: area,
        term: 2014,
        source: url,
      }
      # puts data
      ScraperWiki.save_sqlite([:name, :area, :term], data)
    end
  end
end

scrape_list('http://www.lexpress.mu/resultats')
