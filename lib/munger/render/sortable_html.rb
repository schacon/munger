require 'builder'
module Munger
  module Render
    # Render a table that lets the user sort the columns
    class SortableHtml
    
      attr_reader :report, :classes
      
      # options:
      # :url => /some/url/for/link  # link to put on column
      # :params => {:url_params}    # parameters from url if any
      # :sort => 'column'           # column that is currently sorted
      # :order => 'asc' || 'desc'   # order of the currently sorted field
      def initialize(report, options = {})
        @report = report
        @options = options
        # default url and params options
        @options[:url] ||= '/'
        @options[:params] ||= {}
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
              # TODO: Should be able to see if a column is 'sortable'
              # Assume all columns are sortable here - for now.
              sorted_state = 'unsorted'
              direction = 'asc'
              if [column.to_s, @report.column_data_field(column)].include?(@options[:sort])
                sorted_state = "sorted"
                direction = @options[:order] == 'asc' ? 'desc' : 'asc'
                direction_class = "sorted-#{direction}"
              end
              puts @options[:params].inspect
              new_params = @options[:params].merge({'sort' => @report.column_data_field(column),'order' => direction})
              puts new_params.inspect
              x.th(:class => "columnTitle #{sorted_state} #{direction_class}" ) do 
                 # x << @report.column_title(column) 
                 x << "<a href=\"#{@options[:url]}?#{create_querystring(new_params)}\">#{@report.column_title(column)}</a>"
               end
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
    
      private
      def create_querystring(params={})
        qs = []
        params.each do |k,v|
          qs << "#{k}=#{v}"
        end
        puts qs
        qs.join("&")
      end
      
    end
  end
end