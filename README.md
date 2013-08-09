# si-scrape

A ruby script for scraping information from the web portal for the collections of the Smithsonian Institution.

This README assumes basic knowledge of how to run a Ruby script from your command line. Beginner tutorials can be found for [Windows computers](http://www.editrocket.com/articles/ruby_windows.html) and [OS X](http://www.editrocket.com/articles/ruby_mac_os_x.html) You will also need to install the Ruby gems [Nokogiri](http://nokogiri.org/) and [ruby-progressbar](http://rubygems.org/gems/ruby-progressbar) ([Tutorials on adding Ruby gems](http://www.ruby-lang.org/en/libraries/)).

## Generate your query URL

Establish your search parameters on the [SI collection portal](http://collections.si.edu/search/results.htm?q=). You can enter search keywords, as well as narrow your results by various parameters like `date`, `culture`, or `catalog record source` (this parameter is particularly helpful for limiting your search to a particular museum within the SI.) Once you have entered your terms, copy the URL from your browser's address bar.

My test query is looking for objects of the type `Works of Art` that feature the keyword `space`. The URL for this query looks like this:

	http://collections.si.edu/search/results.htm?tag.cstype=all&q=space&fq=object_type:%22Works+of+art%22

## Run si-scrape.rb

Run `ruby si-scrape.rb` and paste the copied URL when prompted. The script will begin to download from `collections.si.edu`, displaying a rough progress bar like this:

````bash
$ ruby si-scrape.rb 
Enter query URL: http://collections.si.edu/search/results.htm?tag.cstype=all&fq=object_type%3A%22Works+of+art%22
Looking up query on collections.si.edu...
Pages of results: 704
|===>>                                               | 6% Results scraped
````
This will create an HTML file (`output.html`) with all the results of the query concatenated into one long file.

## Run si-parse.rb

Once you have scraped your data, run `ruby si-parse.rb` to create a JSON file of the scraped data. This script creates a [JSON](http://json.org) file instead of a CSV for two reasons:

1. In order to accomodate the diverse metadata that are present in some Smithsonian object records, but not in others. A CSV file is best suited for rows of data that all share the same columns; this would not work for the output from `collections.si.edu`.
2. Some fields, like those for `Topic` or `Type`, have more than one value, which JSON can handle with nested arrays; a CSV needs an additional delimiter character, and support for reading such complex CSVs is patchy at best.

Records will appear as such:

````json
{
"saam_1978.146.1": {
    "Title": "Slaughterhouse Ruins at Aledo",
    "Image": "http://americanart.si.edu/images/1978/1978.146.1_1a.jpg",
    "Artist": [
      "Gertrude Abercrombie, born Austin, TX 1909-died Chicago, IL 1977"
    ],
    "Medium": [
      "oil on canvas"
    ],
    "Dimensions": [
      "20 x 24 in. (50.9 x 61.0 cm)"
    ],
    "Type": [
      "Painting"
    ],
    "Date": [
      "1937"
    ],
    "Topic": [
      "Landscape",
      "Landscape\\Spain\\Aledo",
      "Architecture Exterior\\ruins",
      "Architecture Exterior\\industry\\slaughterhouse"
    ],
    "Credit Line": [
      "Smithsonian American Art Museum, Gift of the Gertrude Abercrombie Trust"
    ],
    "Object number": [
      "1978.146.1"
    ],
    "See more items in": [
      "Smithsonian American Art Museum Collection"
    ],
    "Data Source": [
      "Smithsonian American Art Museum"
    ],
    "Record ID": [
      "saam_1978.146.1"
    ],
    "Visitor Tag(s)": [
      "\nNo tags yet, be the first!\n\nAdd Your Tags!\n"
    ]
  },
}
````

Every SI object comes with a unique ID (e.g. `saam_1978.146.1`) and title (e.g. `Slaughterhouse Ruins at Aledo`). Other elements could potentially have multiple values, and so they are stored as nested arrays in the JSON output, which can easily be parsed by [Ruby's JSON module](http://www.ruby-doc.org/stdlib-2.0/libdoc/json/rdoc/JSON.html) or other library of your choice.

# To-Do

Fork/[contact me](http://matthewlincoln.net/about) with more suggestions for the project!

***

[Matthew D. Lincoln](http://matthewlincoln.net) | Ph.D Student, Department of Art History & Archaeology, University of Maryland, College Park
