require 'twitter'
require 'rubygems'
require 'mechanize'   
require 'twitter'
require 'json'
require 'oauth'
require 'open-uri'
require 'mysql2'  

agent = Mechanize.new
page = agent.get('http://en.wikipedia.org/wiki/List_of_American_film_actresses')

actress_links = page.search("//div[@class='div-col columns column-width']/ul/li/a")

actress_names = []

actress_links.each do |link|
  actress_name = link.text
  actress_names << actress_name
end  
 
client = Twitter::REST::Client.new do |config|
  config.consumer_key = "QDhbzNZmxOPgDrtnoKaLpA"
  config.consumer_secret = "dtKKnZs8x3kbTXkKnfC6guLAZfWGxRcLLpJOoW98"
  config.access_token = "365276774-vOIAeUPieO3ToZ5KmiyymRb5AxzzUY6NCGM5uIrP"
  config.access_token_secret = "cxb3nhsqq0uxAehfDODGcXZUIT2v2OrRNbS4FUgL3pbKY"
end

actress_names.each do |name|
  begin
    @twitter = client.user_search(name)
    if @twitter
      if twitter_user = @twitter.first
	    begin
		  con = Mysql2::Client.new(:host => "localhost", :username => "user12", :password => "34klq*", :database => "american_actresses")
   
          con.query("INSERT INTO actresses (name, twitter) VALUES ('#{name}', 'https://twitter.com/#{twitter_user[:screen_name]}')")
    
        rescue Mysql2::Error => e
          puts e.errno
          puts e.error
    
        ensure
          con.close if con
        end 
	  end
    end	  
 
  rescue Twitter::Error::Unauthorized
    puts "Not authorized. Please check the Twitter credentials at the top of the script."
    break
 
  rescue Twitter::Error::TooManyRequests
    # Twitter's users/search API has an hourly limit of 60 requests, handled here by a delay in the program of one hour.
    puts "Hit rate limit, will retry in one hour."
	sleep(3600)
	retry
 
  rescue Exception => e
    puts "Something else went wrong:"
    puts e.message
  end
end