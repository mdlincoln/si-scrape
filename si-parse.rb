require 'nokogiri'
require 'json'
require 'ruby-progressbar'

######### Initialize files #########
print "Loading scraped HTML into memory..."
html_records = Nokogiri::HTML(open("output.html")).css("div.record")
num_records = html_records.count
puts "#{num_records} records loaded."

puts "Parsing HTML..."
output = Hash.new

prog_bar = ProgressBar.create(:title => "Records processed", :starting_at => 0, :total => num_records, :format => '|%b>>%i| %p%% %t')

######### Loop through records #########
html_records.each do |record|

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

	# Increment progress bar
	prog_bar.increment

end

######### Write JSON file #########
puts "Writing JSON..."
File.open("output.json","w") do |file|
	file.write(JSON.pretty_generate(output))
end
puts "Finished."
