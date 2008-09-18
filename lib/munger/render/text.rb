module Munger #:nodoc:
  module Render #:nodoc:
    class Text
    
      attr_reader :report
      
      def initialize(report)
        @report = report
      end
      
      def render
        output = ''
        depth = {}
        
        # find depth
        @report.process_data.each do |row|
          @report.columns.each do |column|
            i = row[:data][column].to_s.size
            depth[column] ||= @report.column_title(column).to_s.size
            depth[column] = (depth[column] < i) ? i : depth[column]
          end
        end

        # header
        output += '|'
        @report.columns.each do |column|
          output += @report.column_title(column).to_s.ljust(depth[column] + 1) + '| '
        end
        output += "\n"

        total = depth.values.inject { |sum, i| sum + i } + (depth.size * 3)
        0.upto(total) { |i| output += '-' }
        output += "\n" 

        # body
        @report.process_data.each do |row|
          (row[:meta][:group]) ? sep = ':' : sep = '|'
          output += sep
          @report.columns.each do |column|
            output += row[:data][column].to_s.ljust(depth[column] + 1) + sep + ' '
          end
          output += "\n"
        end
        
        output
      end
      
      def valid?
        @report.is_a? Munger::Report
      end
    
    end
  end
end