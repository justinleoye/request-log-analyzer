require File.dirname(__FILE__) + '/spec_helper'
require 'request_log_analyzer/log_processor'

describe RequestLogAnalyzer::LogProcessor, 'stripping log files' do

  include RequestLogAnalyzerSpecHelper
  
  before(:each) do
    @log_stripper = RequestLogAnalyzer::LogProcessor.new(spec_format, :strip, {})
  end
  
  it "should remove a junk line" do
    @log_stripper.strip_line("junk line\n").should be_empty
  end

  it "should keep a teaser line intact" do
    @log_stripper.strip_line("processing 1234\n").should be_empty
  end
end