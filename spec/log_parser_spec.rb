require File.dirname(__FILE__) + '/spec_helper'

describe RequestLogAnalyzer::Source::LogParser, :requests do
  include RequestLogAnalyzerSpecHelper
  
  before(:each) do
    @log_parser = RequestLogAnalyzer::Source::LogParser.new(spec_format)
  end
  
  it "should have multiple line definitions" do
    @log_parser.file_format.line_definitions.length.should >= 2
  end  
  
  it "should have a valid language" do
    @log_parser.file_format.should be_valid
  end
  
  it "should parse more lines than requests" do
    @log_parser.should_receive(:handle_request).with(an_instance_of(SpecFormat::Request)).twice
    @log_parser.parse_file(log_fixture(:test_language_combined))
    @log_parser.parsed_lines.should > 2    
  end
  
  it "should parse requests spanned over multiple files" do
    @log_parser.should_receive(:handle_request).with(an_instance_of(SpecFormat::Request)).once
    @log_parser.parse_files([log_fixture(:multiple_files_1), log_fixture(:multiple_files_2)])
  end
  
  it "should parse all request values when spanned over multiple files" do
    @log_parser.parse_files([log_fixture(:multiple_files_1), log_fixture(:multiple_files_2)]) do |request|
      request.lines.should have(4).items      
      request[:request_no].should == 1
      request[:test_capture].should == "Testing is amazing" # Note the custom converter     
    end
  end  
  
  it "should parse a stream and find valid requests" do
    io = File.new(log_fixture(:test_file_format), 'r')
    @log_parser.parse_io(io) do |request|
      request.should be_kind_of(RequestLogAnalyzer::Request)
      request.should =~ :test
      request[:test_capture].should_not be_nil      
    end
    io.close
  end  
  
end

describe RequestLogAnalyzer::Source::LogParser, :warnings do
  include RequestLogAnalyzerSpecHelper
  
  before(:each) do
    @log_parser = RequestLogAnalyzer::Source::LogParser.new(spec_format)
  end
    
  it "should warn about teaser matching problems" do
    @log_parser.should_receive(:warn).with(:teaser_check_failed, anything).exactly(5).times
    @log_parser.parse_file(log_fixture(:test_file_format))
  end
  
  it "should warn about unmatching request headers and footers" do
    @log_parser.should_receive(:warn).with(:unclosed_request, anything).at_least(1).times    
    @log_parser.should_receive(:warn).with(:no_current_request, anything).at_least(1).times    
    @log_parser.should_not_receive(:handle_request)    
    @log_parser.parse_file(log_fixture(:test_order))    
  end  
end