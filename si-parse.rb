require 'nokogiri'
require 'csv'
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

puts "Writing CSV"
csv_out = CSV.open("output.csv","w")

######### Loop through records #########
html_records.each_with_index do |record, index|

	# Loop through every field in the record
	row = Array.new
	record.css("dl").each do |attribute|
		col_header = getContent(attribute.at_css("dt")).delete(":")

		# Loop through every value in the field
		values = String.new
		attribute.css("dd").each do |value|
			values << "#{getContent(value)}|"
		end
		row << values
	end

	csv_out << row

	# Increment progress bar
	ProgressBar.create(:title => "Records processed", :starting_at => index+1, :total => num_records, :format => '|%b>>%i| %p%% %t')
end

puts "Finished."
