#!/usr/bin/env ruby

require './FerryBoat'
require 'rspec'
require_relative 'spec_helper'

describe "Fetching itinenary for ferries" do

  before(:all) do
    ENV['LOGLEVEL'] = "4"
    @scraper = FerryBoat.new
  end

  subject { @scraper }
 
  it { should respond_to :setup_logger }
  it { should respond_to :open_url }
  it { should respond_to :capture_iframe }
  it { should respond_to :fill_iframe_form }
  it { should respond_to :submit_iframe_form }
  it { should respond_to :choose_date }
  it { should respond_to :select_vehicle }
  it { should respond_to :select_passenger }
  it { should respond_to :select_time }
  it { should respond_to :final_submit }
  it { should respond_to :grab_itinerary }
  it { should respond_to :to_json }
  it { should respond_to :teardown }

  it "should setup the logger" do
    @scraper.setup_logger.should == true
  end

  it "should load the url" do
    @scraper.open_url.should == true
  end

  it "should find the basic iframe to fill out" do
    @scraper.capture_iframe.should == true
  end

  it "should fill out the form in the iframe" do
    @scraper.fill_iframe_form.should == true
  end

  it "should submit the form in the iframe" do
    @scraper.submit_iframe_form.should == true
  end

  it "should choose a date" do
    @scraper.choose_date.should == true
  end

  it "should select a vehicle option" do
    @scraper.select_vehicle.should == true
  end

  it "should select the passenger option" do
    @scraper.select_passenger.should == true
  end

  it "should select the time" do
    @scraper.select_time.should == true
  end

  it "should should do the final submission" do
    @scraper.final_submit.should == true
  end

  it "should be able to grab the itinerary data" do
    @scraper.grab_itinerary.class.should eq Array
  end
 
  it "should be able to serialize to JSON" do
    @scraper.to_json.should == true
  end
 
end

