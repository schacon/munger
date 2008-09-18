module Munger #:nodoc:
  module Render #:nodoc:
    class CSV #:nodoc:
    
      attr_reader :report
      
      def initialize(report)
        @report = report
      end
      
      def render
        output = []

        # header
        output << @report.columns.collect { |col| @report.column_title(col).to_s }.join(',')
        
        # body
        @report.process_data.each do |row|
          output << @report.columns.collect { |col| row[:data][col].to_s }.join(',')
        end
        
        output.join("\n")
      end
      
      def valid?
        @report.is_a? Munger::Report
      end
    
    end
  end
end