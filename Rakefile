require './FerryBoat'

task :dublin do
  ENV['LOGLEVEL']  = "2"
  ENV['DEPARTURE'] = "Dublin"
  ferry_scraper = FerryBoat.new
  ferry_scraper.setup_logger
  ferry_scraper.open_url
  ferry_scraper.capture_iframe
  ferry_scraper.fill_iframe_form
  ferry_scraper.submit_iframe_form
  ferry_scraper.choose_date
  ferry_scraper.select_vehicle
  ferry_scraper.select_passenger
  ferry_scraper.select_time
  ferry_scraper.final_submit
  ferry_scraper.grab_itinerary
  ferry_scraper.to_json
  ferry_scraper.teardown
end

task :liverpool do
  ENV['LOGLEVEL']  = "2"
  ENV['DEPARTURE'] = "Liverpool"
  ferry_scraper = FerryBoat.new
  ferry_scraper.setup_logger
  ferry_scraper.open_url
  ferry_scraper.capture_iframe
  ferry_scraper.fill_iframe_form
  ferry_scraper.submit_iframe_form
  ferry_scraper.choose_date
  ferry_scraper.select_vehicle
  ferry_scraper.select_passenger
  ferry_scraper.select_time
  ferry_scraper.final_submit
  ferry_scraper.grab_itinerary
  ferry_scraper.to_json
  ferry_scraper.teardown
end

task :json => :fetch do
  puts "put conversion to json outside of scraper..."
end

task :storage => :fetch do
  puts "shove stuff into database e.g. with rdbi.."
end

task :clean do
  puts "delete old files, cleanup"
end
