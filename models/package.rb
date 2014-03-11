require 'csv'

class Package < ActiveRecord::Base
  validates :email_address, presence: true

  def quotes_as_csv=(text)
    map = %w(quote, author, tagline)

    quotes = CSV.parse(text)
    quotes.map do |quote|
      Hash.new(map.zip quote)
    end

    write_attribute(:quotes, quotes.to_json)
  end

  def quotes_as_csv
    CSV.generate do |csv|
      JSON.parse(quotes).each do |row|
        csv << row
      end
    end
  end
end
