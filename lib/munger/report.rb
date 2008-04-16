module Munger
  
  class Report
    
    attr_writer :data, :sort, :columns, :subgroup, :aggregate
    
    attr_reader :process_data, :grouping_level
    
    # r = Munger::Report.new ( :data => data, 
    #   :columns => [:collect_date, :spot_name, :airings, :display_name],
    #   :sort => [:collect_date, :spot_name]
    #   :subgroup => @group_list,
    #   :aggregate => {:sum => new_columns} )
    # report = r.highlight
    def initialize(options = {})
      @grouping_level = 0
      set_options(options)
    end
    
    def set_options(options)
      if d = options[:data]
        if d.is_a? Munger::Data
          @data = d
        else
          @data = Munger::Data.new(:data => d)
        end
      end
      @sort = options[:sort] if options[:sort]
      @columns = options[:columns] if options[:columns]
      @subgroup = options[:subgroup] if options[:subgroup]
      @aggregate = options[:aggregate] if options[:aggregate]
    end
    
    # returns ReportTable
    def process(options = {})
      set_options(options)
            
      # sorts and fills NativeReport 
      @report = translate_native(do_field_sort(@data.data))
      
      do_add_groupings
      do_add_aggregate_rows
      
      self
    end
    
    def sort(values = nil)
      if values
        @sort = values 
        self
      else
        @sort
      end
    end
    
    def subgroup(values = nil)
      if values
        @subgroup = values 
        self
      else
        @subgroup
      end
    end
    
    def columns(values = nil)
      if values
        @columns = values 
        self
      else
        @columns ||= @data.columns
      end
    end
    
    def aggregate(values = nil)
      if values
        @aggregate = values 
        self
      else
        @aggregate
      end
    end
    
    def valid?
      (@data.is_a? Munger::Data) && (@data.valid?)
    end

    # post-processing calls

    # @report.style_cells('highlight') { |cell, row| cell > 32 }
    def style_cells(style, options = {})
      @process_data.each_with_index do |row, index|
        
        # filter columns to look at
        if options[:only]
          cols = Data.array(options[:only])
        elsif options [:except]
          cols = columns - Data.array(options[:except])
        else
          cols = columns
        end
        
        cols.each do |col|
          if yield(row[:data][col], row[:data])
            @process_data[index][:meta][:cell_styles] ||= {}
            @process_data[index][:meta][:cell_styles][col] ||= []
            @process_data[index][:meta][:cell_styles][col] << style
          end
        end
      end
    end
    
    # @report.style_rows('highlight') { |row| row.age > 32 }
    def style_rows(style, options = {})
      @process_data.each_with_index do |row, index|
        if yield(row[:data])
          @process_data[index][:meta][:row_styles] ||= []
          @process_data[index][:meta][:row_styles] << style
        end
      end
    end
    
    def get_subgroup_rows(group_level = nil)
      data = @process_data.select { |r| r[:meta][:group] }
      data = data.select { |r| r[:meta][:group] == group_level } if group_level
      data
    end
    
    def to_s
      pp @process_data
    end
    
    private 

      
      def translate_native(array_of_hashes)
        @process_data = []
        array_of_hashes.each do |row|
          @process_data << {:data => Item.ensure(row), :meta => {}}
        end
      end
      
      def do_add_aggregate_rows
        return false if !@aggregate
        return false if !@aggregate.is_a? Hash
        
        totals = {}        
        
        @process_data.each_with_index do |row, index|
          if level = row[:meta][:group]
            # write the totals and reset level
            @aggregate.each do |type, columns|
              Data.array(columns).each do |column|
                data = totals[column][level]
                @process_data[index][:data][column] = calculate_aggregate(type, data)
                totals[column][level] = []
              end
            end
          else
            @aggregate.each do |type, columns|
              Data.array(columns).each do |column|
                value = row[:data][column]
                @grouping_level.downto(0) do |level|
                  totals[column] ||= {}
                  totals[column][level] ||= []
                  totals[column][level] << value
                end
              end
            end
          end
        end
              
        total_row = {:data => {}, :meta => {:group => 0}}
        # write one row at the end with the totals
        @aggregate.each do |type, columns|
          Data.array(columns).each do |column|
            data = totals[column][0]
            total_row[:data][column] = calculate_aggregate(type, data)
          end
        end
        @process_data << total_row
        
      end
      
      def calculate_aggregate(type, data)
        if type.is_a? Proc
          type.call(data)
        else
          case type
          when :count
            data.size
          when :average
            sum = data.inject {|sum, n| sum + n }
            (sum / data.size)
          when :product
            data.inject {|prod, n| prod * n }
          else
            data.inject {|sum, n| sum + n }
          end
        end
      end
      
      def do_add_groupings
        return false if !@subgroup
        sub = Data.array(@subgroup)
        @grouping_level = sub.size
        
        current = {}
        new_data = []
        
        @process_data.each_with_index do |row, index|
          new_data << row
          next_row = @process_data[index + 1]
          if next_row
            level = @grouping_level
            sub.reverse.each do |group|
              if (next_row[:data][group] != current[group]) && current[group]
                group_row = {:data => {}, :meta => {:group => level}}
                new_data << group_row
              end
              current[group] = next_row[:data][group]
              level =- 1
            end 
          else  # last row
            level = @grouping_level
            sub.reverse.each do |group|
              group_row = {:data => {}, :meta => {:group => 1}}
              new_data << group_row
              level =- 1
            end
          end
        end

        @process_data = new_data
      end
      
      def do_field_sort(data)
        data.sort do |a, b|
          compare = 0
          a = Item.ensure(a)
          b = Item.ensure(b)
      
          Data.array(@sort).each do |sorting|
            if sorting.is_a? String
              compare = a[sorting] <=> b[sorting]
              break if compare != 0
            elsif sorting.is_a? Array
              key = sorting[0]
              func = sorting[1]
              if func == :asc
                compare = a[key] <=> b[key]
              elsif func == :desc
                compare = b[key] <=> a[key]
              elsif func.is_a? Proc
                compare = func.call(a[key], b[key])
              end
              break if compare != 0
            end
          end
          compare
        end
      end
    
  end
  
end
