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
print "Loading scraped HTML..."
html_records = Nokogiri::HTML(open("output.html")).css("div.record")
num_records = html_records.count
puts "#{num_records} records loaded."

puts "Writing CSV"
csv_out = CSV.open("output.csv","w")

######### Loop through records #########
html_records.each_with_index do |record, index|

	# Increment progress bar
	ProgressBar.create(:title => "Records processed", :starting_at => index, :total => num_records, :format => '|%b>>%i| %p%% %t', :throttle_rate => 0.2)
end

puts "Finished."
