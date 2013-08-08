require 'nokogiri'
require 'open-uri'

######### Get base url #########

print "Enter query URL: "
base_url = gets.chomp

html_out = File.open("output.html", "w")
index = 0

######### Determine number of pages of records to be downloaded #########

Nokogiri::HTML(open(base_url)).css("#results-paging ul li a").each do |a|
	if a.to_s.include?("last")
		items = a.to_s.slice(/(start=)(\d*)\D/,2).to_i
		if items.nil?
			$END_INDEX = 0
			puts "Less than 20 items to download"
		else
			$END_INDEX = items
			puts "Items to download: #{$END_INDEX}"
		end
	end
end


######### Parse HTML #########

loop do
	puts "At item #{index}"

	sample = Nokogiri::HTML(open("#{BASE_URL}&start=#{index}")) do |config|
	end

	sample.css("div.record").each do |record|
		html_out << record.to_s.gsub("\t","")
	end

	sleep 0
	index += 20
	break if index > $END_INDEX
end

puts "Finished"
