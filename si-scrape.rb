require 'nokogiri'
require 'open-uri'
require 'json'
require 'ruby-progressbar'

######### Get base url #########

print "Enter query URL: "
base_url = gets.chomp

output = Hash.new
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
		
		###### Special fields that need to be explicitly parsed ######

		# Get SI ID
		si_id = record.at_css("h2").attribute("id").content
		
		# Get object title
		item_data = {"Title" => record.at_css("h2.title").content}

		# Get object image
		img = record.at_css("a img")
		unless img.nil?
			item_data["Image"] = img.attribute("src").content.slice(/\&id\=(.*)/,1)
		end

		###### end special fields ######

		###### Loop through every remaining field in the record ######
		record.css("dl").each do |attribute|

			# Check for multiple values in a field, and write appropriately
			heading = attribute.at_css("dt").content.delete(":")

			# Loop through every value in the field
			attribute_values = Array.new
			attribute.css("dd").each do |value|
				attribute_values << value.content
			end

			item_data[heading] = attribute_values
		end

		# Store info in hash
		output[si_id] = item_data

	end

	# Increment progress bar
	prog_bar.increment

	sleep 0 # => Add a sleep timer here if your web requests time out
	index += 20
	break if index > $END_INDEX
	prog_bar.progress += 20
end

######### Write JSON file #########
puts "Writing JSON..."
File.open("output.json","w") do |file|
	file.write(JSON.pretty_generate(output))
end

puts "Finished"
