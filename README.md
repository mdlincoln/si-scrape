# si-scrape

A ruby script for scraping information from the web portal for the collections of the Smithsonian Institution.

This README assumes basic knowledge of how to run a Ruby script from your command line. Beginner tutorials can be found for [Windows computers](http://www.editrocket.com/articles/ruby_windows.html) and [OS X](http://www.editrocket.com/articles/ruby_mac_os_x.html) You will also need to install the Ruby gems [Nokogiri](http://nokogiri.org/) and [ruby-progressbar](http://rubygems.org/gems/ruby-progressbar) ([Tutorials on adding Ruby gems](http://www.ruby-lang.org/en/libraries/)).

## Generate your query URL

Establish your search parameters on the [SI collection portal](http://collections.si.edu/search/results.htm?q=). You can enter search keywords, as well as narrow your results by various parameters like "date", "culture", or "catalog record source" (this parameter is helpful for limiting your search to a particular museum within the SI.) Once you have entered your terms, copy the URL from your browser's address bar.

My test query is looking for objects of the type `Works of Art` that feature the keyword `space`. The URL for this query looks like this:

	http://collections.si.edu/search/results.htm?tag.cstype=all&q=space&fq=object_type:%22Works+of+art%22

## Run the script

Run `ruby si-scrape.rb` and paste the copied URL when prompted. The script will begin to download from `collections.si.edu`, displaying a rough progress bar like this:

````bash
$ ruby si-scrape.rb 
Enter query URL: http://collections.si.edu/search/results.htm?tag.cstype=all&fq=object_type%3A%22Works+of+art%22
Pages of results: 704
|===>>                                               | 6% Results scraped
````

Currently `si-scrape.rb` will create an HTML file (`output.html`) with all the results of the query concatenated into one long file. You may then run this file through your own HTML parsing script (I recommend using [Nokogiri](http://nokogiri.org/) on Ruby) to pull out the desired information.

# To-Do

I intend to make future versions of this script that will output a flat CSV that you can open and manipulate in Excel, without further Ruby knowledge. However this will need to be flexible enough to accept the huge range of metadata fields that the Smithsonian's expansive and diverse collections demand. More experienced Ruby wranglers are welcome to contribute!


***

[Matthew D. Lincoln](http://matthewlincoln.net) | Ph.D Student, Department of ArtHistory & Archaeology, University of Maryland, College Park
