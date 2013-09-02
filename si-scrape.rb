require 'nokogiri'
require 'open-uri'
require 'json'
require 'ruby-progressbar'

OUTPUT = "output.json" # => Insert your desired output file path here

######### Get base url #########

print "Enter query URL: "
base_url = gets.chomp

START_INDEX = 223060
index = START_INDEX

######### Determine number of pages of records to be downloaded #########

puts "Looking up query on collections.si.edu..."
initial = Nokogiri::HTML(open(base_url)).css("#results-paging ul li a")

### Check if there are any additional pages ###
if initial.to_s.include?("last")	## If yes, retrieve the index of the last page ###
	initial.each do |a|
		
		if a.to_s.include?("last")
			$END_INDEX = a.to_s.slice(/(start=)(\d*)\D/,2).to_i
			puts "Total items: #{$END_INDEX}"
			puts "Pages to download: #{$END_INDEX/20}"
		end
	end
else	## If not, set the END_INDEX to 0 ##
	$END_INDEX = 0
	puts "Pages of results: 1"
end

# Set up progress bar to display the results of the download. This will be updated as each page is downloaded and parsed
prog_bar = ProgressBar.create(:title => "Results scraped", :starting_at => START_INDEX, :total => $END_INDEX, :format => '%c |%b>>%i| %p%% %t')	# => Create a progress bar

######### Parse HTML #########

loop do

	output = Hash.new

	sample = Nokogiri::HTML(open("#{base_url}&start=#{index}"))
	sample.css("div.record").each do |record|	# => Pull and write each div with class="record"
		
		###### Special fields that need to be explicitly parsed ######

		# Get SI ID
		si_id = record.at_css("h2").attribute("id").content.to_sym
		
		# Get object title
		item_data = {:title => record.at_css("h2.title").content}

		# Get object image
		img = record.at_css("a img")
		unless img.nil?
			item_data[:image] = img.attribute("src").content.slice(/\&id\=(.*)/,1)
		end

		###### end special fields ######

		###### Loop through every remaining field in the record ######
		record.css("dl").each do |attribute|

			# Check for multiple values in a field, and write appropriately
			heading = attribute.at_css("dt").content.delete(":").downcase.sub(/\W/,"_").to_sym

			# Loop through every value in the field
			attribute_values = Array.new
			attribute.css("dd").each do |value|
				attribute_values << value.content
			end

			# Store the value array in item_data, keyed to the heading name
			item_data[heading] = attribute_values
		end

		# Store item data, keyed to the item ID
		output[si_id] = item_data

		# Write out a temporary JSON representing this page of results. These will later be merged into one master JSON file
		File.open("parts/part_#{index}.json","w") do |file|
			file.write(JSON.generate(output))
		end
	end

	sleep 0 # => Add a sleep timer here if your web requests time out
	index += 20
	break if index > $END_INDEX
	prog_bar.progress += 20
end

######### Concatenate temporary JSON files #########

complete = Hash.new

num = 0
puts "Loading and merging temporary files..."
merge_bar = ProgressBar.create(:title => "Records merged", :starting_at => num, :total => $END_INDEX, :format => '%c |%b>>%i| %p%% %t')	# => Create a progress bar

# For each temporary JSON file created while downloading results
while num <= $END_INDEX
	filename = "parts/part_#{num}.json"
	# Re-load these files into a hash
	current = JSON.parse(File.read(filename), :symbolize_names => true)
	# Merge each file into the master hash
	complete = complete.merge(current)
	num += 20
	merge_bar.progress += 20
end

# Write out the master hash to disk
puts "Writing JSON..."
File.open(OUTPUT,"w") do |file|
	file.write(JSON.pretty_generate(complete))
end

puts "Finished"
