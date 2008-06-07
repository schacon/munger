begin
  require 'builder'
rescue LoadError
  require 'rubygems'
  require 'builder'
end

module Munger
  module Render
    class Html
    
      attr_reader :report, :classes
      
      def initialize(report, options = {})
        @report = report
        set_classes(options[:classes])
      end
      
      def set_classes(options = nil)
        options = {} if !options
        default = {:table => 'report-table'}
        @classes = default.merge(options)
      end
      
      def render
        x = Builder::XmlMarkup.new
        
        x.table(:class => @classes[:table]) do
          
          x.tr do
            @report.columns.each do |column|
              x.th(:class => 'columnTitle') { x << @report.column_title(column) }
            end
          end
          
          @report.process_data.each do |row|
            
            classes = []
            classes << row[:meta][:row_styles]
            classes << 'group' + row[:meta][:group].to_s if row[:meta][:group]
            classes << cycle('even', 'odd')
            classes.compact!

            if row[:meta][:group_header]
              classes << 'groupHeader' + row[:meta][:group_header].to_s 
            end
            
            row_attrib = {}
            row_attrib = {:class => classes.join(' ')} if classes.size > 0
            
            x.tr(row_attrib) do
              if row[:meta][:group_header]
                header = @report.column_title(row[:meta][:group_name]) + ' : ' + row[:meta][:group_value].to_s
                x.th(:colspan => @report.columns.size) { x << header }
              else 
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
      end
      
      def cycle(one, two)
        if @current == one
          @current = two
        else
          @current = one
        end
      end
      
      def valid?
        @report.is_a? Munger::Report
      end
    
    end
  end
end
