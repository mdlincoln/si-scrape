require 'nokogiri'
require 'open-uri'
require 'ruby-progressbar'

######### Get base url #########

print "Enter query URL: "
base_url = gets.chomp

html_out = File.open("output.html", "w")
index = 0

######### Determine number of pages of records to be downloaded #########

puts "Looking up query on collections.si.edu..."
initial = Nokogiri::HTML(open(base_url)).css("#results-paging ul li a")

### Check if there are any additional pages ###
if initial.to_s.include?("last")	## If yes, retrieve the index of the last page ###
	initial.each do |a|
		
		if a.to_s.include?("last")
			items = a.to_s.slice(/(start=)(\d*)\D/,2).to_i
			$END_INDEX = items
			puts "Pages of results: #{$END_INDEX/20}"
		end
	end
else	## If not, set the END_INDEX to 0 ##
	$END_INDEX = 0
	puts "Pages of results: 1"
end


prog_bar = ProgressBar.create(:title => "Results scraped", :starting_at => index, :total => $END_INDEX, :format => '%e |%b>>%i| %p%% %t')	# => Create a progress bar

######### Parse HTML #########

loop do

	sample = Nokogiri::HTML(open("#{base_url}&start=#{index}"))

	sample.css("div.record").each do |record|	# => Pull and write each div with class="record"
		html_out << record.to_s.gsub("\t","")	# => Cleans out excessive indentation
	end

	sleep 0 # => Add a sleep timer here if your web requests time out
	index += 20
	break if index > $END_INDEX
	prog_bar.progress += 20
end

puts "Finished"
