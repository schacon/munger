require 'builder'
module Munger
  module Render
    class Html
    
      attr_reader :data
      
      def initialize(data)
        @data = data
      end
      
      def render
        x = Builder::XmlMarkup.new
        x.table do
          
          x.tr do
            @data.columns.each do |column|
              x.th { x << column.to_s }
            end
          end
          
          @data.process_data.each do |row|
            
            row_attrib = {}
            if rst = row[:meta][:row_styles]
              row_attrib = {:class => rst.join(' ')}
            end
            
            x.tr(row_attrib) do
              @data.columns.each do |column|
                
                # {:meta=>{:cell_styles=>{:age=>["highlight"]}}
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
        @data.is_a? Munger::Report
      end
    
    end
  end
end