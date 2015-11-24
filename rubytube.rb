require "nokogiri"
require "open-uri"

class Video
  attr_accessor :title, :length, :url

  def initialize (title, length, url)
    self.title= title
    self.length= length
    self.url= url
  end

  # Launches VLC with Youtube URL
  def watch

    `vlc http://www.youtube.com/#{url}`
  end

  # Takes inventory of all objects created from the Video class and puts them in an array
  def self.all
    ObjectSpace.each_object(self).to_a
  end

  # Organizes the video objects
  def self.organize
    # Calls the title method on each object and then prints the title in an ordered list
    all.map(&:title).each.with_index(1) do |value, index|
      puts "#{index}: #{value}"
    end
  end

  # Searches Youtube
  def self.fetch(search_item)
    Nokogiri::HTML(open("https://www.youtube.com/results?search_query=#{search_item}")) 
  end

  # Scrapes the result page for title and URL
  def self.parse(search_item)
    search_results = fetch(search_item)
    search_results.css('li div div div.yt-lockup-content').map do |video_data|
      title = video_data.css('h3.yt-lockup-title a.yt-uix-tile-link').text
      length = nil
      url = video_data.css('h3.yt-lockup-title a.yt-uix-tile-link')[0]['href']

      # Creates new video object for each result
      Video.new(title, length, url)
    end

    # This line checks to see if any objects were created and will retry the search if it failed.
    if all[0] == nil
      parse(search_item)
    else
      # Calls organize method to organize the search results
      organize
    end    
  end  
end

puts "Welcome to Rubytube"

# Asks the user what video they would like to watch
print "Enter your search: "
search = gets

# Runs a search with user input
Video.parse(search) 

# Asks the user what video they would like to watch
puts "Which video would you like to watch?"
selection = gets

# Prints the selected video
puts "Watching #{Video.all[selection.to_i - 1].title}"

# Takes user input, converts to integer and the subtracts one to get the correct index
Video.all[selection.to_i - 1].watch