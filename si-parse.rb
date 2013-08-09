require 'nokogiri'
require 'json'
require 'ruby-progressbar'


######### Method to avoid exceptions when getting the content of empty nodes using Nokogiri #########
def getContent(input)
	if input == nil
		return nil
	else
		return input.content
	end
end

######### Initialize files #########
print "Loading scraped HTML into memory..."
html_records = Nokogiri::HTML(open("output.html")).css("div.record")
num_records = html_records.count
puts "#{num_records} records loaded."

puts "Parsing HTML..."
output = Hash.new

prog_bar = ProgressBar.create(:title => "Records processed", :starting_at => 0, :total => num_records, :format => '|%b>>%i| %p%% %t')

######### Loop through records #########
html_records.each_with_index do |record, index|

	# Get SI ID
	si_id = record.at_css("h2").attribute("id").content
	item_data = Hash.new
	
	# Get object title
	item_data.store("Title", getContent(record.at_css("h2.title")))

	# Get object image
	img = record.at_css("a img")
	unless img.nil?
		img_path = img.attribute("src").content.slice(/\&id\=(.*)/,1)
		item_data.store("Image", img_path)
	end

	# Loop through every field in the record
	record.css("dl").each do |attribute|

		attribute_title = getContent(attribute.at_css("dt")).delete(":").to_sym

		# Check for multiple values in a field, and write appropriately
		values = attribute.css("dd")
		if values.count > 1
			attribute_values = Array.new
			values.each do |value|
				attribute_values << getContent(value)
			end
		else
			attribute_values = values.first.content
		end
		item_data.store(attribute_title,attribute_values)
	end

	# Store info in hash
	output.store(si_id, item_data)

	# Increment progress bar
	prog_bar.increment

end

# Write JSON file
puts "Writing JSON..."
File.open("output.json","w") do |file|
	file.write(JSON.pretty_generate(output))
end
puts "Finished."
