require 'builder'
module Munger
  module Render
    class Html
    
      attr_reader :report
      
      def initialize(report)
        @report = report
      end
      
      def render
        x = Builder::XmlMarkup.new
        x.table do
          
          x.tr do
            @report.columns.each do |column|
              x.th { x << @report.column_title(column) }
            end
          end
          
          @report.process_data.each do |row|
            
            classes = []
            classes << row[:meta][:row_styles]
            classes << 'group' + row[:meta][:group].to_s if row[:meta][:group]
            classes.compact!
            
            row_attrib = {}
            row_attrib = {:class => classes.join(' ')} if classes.size > 0
            
            x.tr(row_attrib) do
              @report.columns.each do |column|
                
                cell_attrib = {}
                if cst = row[:meta][:cell_styles]
                  cst = Item.ensure(cst)
                  if cell_styles = cst[column]
                    cell_attrib = {:class => cell_styles.join(' ')}
                  end
                end
                
                x.td(cell_attrib) { x << row[:data][column].to_s }
              end
            end
          end
          
        end
      end
      
      def valid?
        @report.is_a? Munger::Report
      end
    
    end
  end
end