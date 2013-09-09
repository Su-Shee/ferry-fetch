#!/usr/bin/env ruby

require 'active_support/all'
require 'watir-webdriver'
require 'headless'
require 'log4r'
require 'dotenv'
require 'nokogiri'
require 'json'

class FerryBoat

  def initialize
    
    Dotenv.load

    @rooturl   = ENV['ROOTURL']
    @loglevel  = ENV['LOGLEVEL'].to_i
    @delta     = ENV['TRAVELDATE'].to_i
    @departure = ENV['DEPARTURE']

    @itinerary = Array.new

    if ENV['HEADLESS']
      @headless = Headless.new
      @headless.start
    end
      
    @browser = Watir::Browser.new

    if @departure == 'Dublin'
      @country = 'Ireland'
      @route   = 'Dublin - Liverpool'
    else
      @country = 'UK'
      @route   = 'Liverpool - Dublin'
    end

  end

  def setup_logger
    @logger  = Log4r::Logger.new('ferrylog')
    @logger.outputters << Log4r::Outputter.stdout
    @logger.level = @loglevel
    @logger.info "Ferry scraper and logger initialized."
    return true
  end

  def open_url
    begin 
      @browser.goto @rooturl
    rescue Watir::Exception::NavigationException, Timeout::Error
      @logger.error "Couldn't goto URL."
    else
      @logger.info "URL opened." 
      return true
    end
  end

  def capture_iframe
    begin
      @iframe = @browser.frame(:index => 0)
    rescue Watir::Exception::UnknownFrameException, Timeout::Error
      @logger.error "Couldn't find iframe containing the form."
    else 
      @logger.info "Filling in iframe form."
      return true
    end
  end

  def fill_iframe_form
    begin 
      @iframe.radio(:index => 1).set
    rescue Watir::Exception::UnknownObjectException, Timeout::Error
      @logger.error "Couldn't find radio button."
    else
      @logger.info "Set journey to single."
    end

    begin 
      @iframe.select_list(:name => 'dpid').select(@country)
    rescue Watir::Exception::UnknownObjectException, Timeout::Error
      @logger.error "Couldn't find origin selection."
    else
      @logger.info "Origin set to " + @country + "."
    end

    begin
      @iframe.select_list(:name => 'grid_rfid').select(@route)
    rescue Watir::Exception::UnknownObjectException, Timeout::Error
      @logger.error "Couldn't find route selection."
    else
      @logger.info "Selected " + @route + "."
      return true
    end
  end

  def submit_iframe_form
    begin
      @iframe.a(:id => 'ctl09_butSubmit').click
    rescue Watir::Exception::UnknownObjectException,
           Watir::Exception::ObjectDisabledException, Timeout::Error
      @logger.error "Couldn't find submit button for iframe form."
    else
      @logger.info "Submitting iframe form, next page coming up..."
      return true
    end
  end

  def choose_date

    traveldate = Date.current + @delta.days

    @logger.info('Traveldate ' + @delta.to_s + ' days from today: ' << traveldate.to_s)

    begin
      @browser.input(:id => 'cal_out').click
    rescue Watir::Exception::UnknownObjectException,
           Watir::Exception::ObjectDisabledException
      @logger.error "Couldn't open calendar widget"
    else
      @logger.info "Opening calendar widget"
    end

    begin
      @browser.a(:class => 'ui-state-default', :text => traveldate.day.to_s).click
    rescue Watir::Exception::UnknownObjectException,
           Watir::Exception::ObjectDisabledException
      @logger.error "Couldn't choose date from calendar widget."
    else
      @logger.info "Choosing date from calendar widget."
      return true
    end
  end

  def select_vehicle
    begin 
      @browser.radio(:id => 'vehicleDetails_radWithVehicle').set
    rescue Watir::Exception::UnknownObjectException, Timeout::Error
      @logger.error "Couldn't set vehicle radiobox."
    else 
      @logger.info "Checked vehicle radiobox."
    end

    begin
      @browser.select_list(:id => 'vehicleDetails_ddlVehicleType').when_present.select('Car')
    rescue Watir::Exception::UnknownObjectException, 
           Watir::Exception::NoValueFoundException
      @logger.error "Couldn't choose car from select list"
    else 
      @logger.info "Car selected from select list"
    end

    begin
      @browser.select_list(:id => 'vehicleDetails_ddlVehicleMake').when_present.select('Audi')
    rescue Watir::Exception::UnknownObjectException, 
           Watir::Exception::NoValueFoundException
      @logger.error "Couldn't choose car/make from select list"
    else 
      @logger.info "Car make selected from select list"
    end

    sleep(5)

    begin
      @browser.select_list(:id => 'vehicleDetails_ddlVehicleModel').when_present.select('A3 (2003 +)')
    rescue Watir::Exception::UnknownObjectException, 
           Watir::Exception::NoValueFoundException
      @logger.error "Couldn't choose car/model from select list"
    else 
      @logger.info "Car model selected from select list"
      return true
    end
  end

  def select_time
    begin
      @browser.select_list(:name => 'ddOutTime').select('00:00')
    rescue Watir::Exception::UnknownObjectException, 
           Watir::Exception::NoValueFoundException
      @logger.error "Couldn't choose time from select list"
    else 
      @logger.info "Time selected from select list"
      return true
    end
  end

  def select_passenger
    begin
      @browser.select_list(:name => 'passengerAges$Age1$ddlAges').select('18+')
    rescue Watir::Exception::UnknownObjectException, Timeout::Error
      @logger.error "Couldn't select age of passenger."
    else 
      @logger.info "Selected age of passenger."
      return true
    end
  end

  def final_submit
    begin
      @browser.input(:name => 'butSubmit').when_present.click
    rescue Watir::Exception::UnknownObjectException,
           Watir::Exception::ObjectDisabledException
      @logger.error "Couldn't click submit button"
    else
      @logger.info "FINALLY form submitted! :)"
      return true
    end
  end

  def grab_itinerary
    @logger.info "Generating travel data..."

    Nokogiri::HTML(@browser.html).xpath("//div[@class='ticket']").each do |ticket|
      journey = Hash.new

      origin      = ticket.css('.info1').text.split(/[\s\t\n]+/)
      destination = ticket.css('.info2').text.split(/[\s\t\n]+/)
   
      if @departure == 'Dublin' 
        @logger.info('Filtering out anything not Dublin - Liverpool')
        next unless origin[1] == 'Dublin' and destination[1] == 'Liverpool'
      end

      if @departure == 'Liverpool'
        @logger.info('Filtering out anything not Liverpool - Dublin')
        next unless origin[1] == 'Liverpool' and destination[1] == 'Dublin'
      end
        
      journey['route_name'] = @route

      journey['origin_name']      = origin[1]
      journey['destination_name'] = destination[1]

      journey['arrival_time']   = destination[3..7].join(' ')
      journey['departure_time'] = origin[3..7].join(' ')

      journey['price']    = ticket.css('.pricetxt').text.strip
      journey['duration'] = ticket.css('.dur1').text.strip

      @itinerary.push(journey)
    end

    return @itinerary

  end

  def to_json
    @logger.info "Generating json from travel data..."
    file = 'from' + @departure + '.json'
    File.open(file, "w") { |f| f << JSON.pretty_generate(@itinerary) }
    return true
  end

  def teardown 
    @logger.info "Closing (headless) browser..."
    @browser.close
    @headless.destroy
  end
end

#puts @browser.text
