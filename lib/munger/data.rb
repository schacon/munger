module Munger #:nodoc:
  
  # this class is a data munger
  #  it takes raw data (arrays of hashes, basically) 
  #  and can manipulate it in various interesting ways
  class Data
    
    attr_accessor :data
    
    # will accept active record collection or array of hashes
    def initialize(options = {})
      @data = options[:data] if options[:data]
      yield self if block_given?
    end
    
    def <<(data)
      add_data(data)
    end
    
    def add_data(data)
      if @data
        @data = @data + data 
      else
        Data.new(:data => data)
      end
      @data
    end
    

    #--
    # NOTE:
    # The name seems redundant; why:
    #   Munger::Data.load_data(data)
    # and not:
    #   Munger::Data.load(data)
    #++
    def self.load_data(data, options = {})
      Data.new(:data => data)
    end
    
    def columns
      @columns ||= clean_data(@data.first).to_hash.keys
    rescue
      puts clean_data(@data.first).to_hash.inspect
    end
    
    # :default:	The default value to use for the column in existing rows. 
    #           Set to nil if not specified.
    # if a block is passed, you can set the values manually
    def add_column(names, options = {})
      default = options[:default] || nil
      @data.each_with_index do |row, index|
        if block_given?
          col_data = yield Item.ensure(row)
        else
          col_data = default
        end
        
        if names.is_a? Array
          names.each_with_index do |col, i|
            row[col] = col_data[i]
          end
        else
          row[names] = col_data
        end
        @data[index] = Item.ensure(row)
      end
    end
    alias :add_columns :add_column
    alias :transform_column :add_column
    alias :transform_columns :add_column
    
    def clean_data(hash_or_ar)
      if hash_or_ar.is_a? Hash
        return Item.ensure(hash_or_ar)
      elsif hash_or_ar.respond_to? :attributes
        return Item.ensure(hash_or_ar.attributes)
      end
      hash_or_ar
    end
        
    def filter_rows
      new_data = []
      
      @data.each do |row|
        row = Item.ensure(row)
        if (yield row)
          new_data << row
        end
      end
      
      @data = new_data
    end
    
    # group the data like sql
    def group(groups, agg_hash = {})
      data_hash = {}
      
      agg_columns = []
      agg_hash.each do |key, columns|
        Data.array(columns).each do |col|  # column name
          agg_columns << col
        end
      end
      agg_columns = agg_columns.uniq.compact
      
      @data.each do |row|
        row_key = Data.array(groups).map { |rk| row[rk] }
        data_hash[row_key] ||= {:cells => {}, :data => {}, :count => 0}
        focus = data_hash[row_key]
        focus[:data] = clean_data(row)
        
        agg_columns.each do |col|
          focus[:cells][col] ||= []
          focus[:cells][col] << row[col]
        end
        focus[:count] += 1
      end
            
      new_data = []
      new_keys = []
      
      data_hash.each do |row_key, data|
        new_row = data[:data]
        agg_hash.each do |key, columns|
          Data.array(columns).each do |col|  # column name
            newcol = ''
            if key.is_a?(Array) && key[1].is_a?(Proc)
              newcol = key[0].to_s + '_' + col.to_s
              new_row[newcol] = key[1].call(data[:cells][col])
            else  
              newcol = key.to_s + '_' + col.to_s
              case key
              when :average
                sum = data[:cells][col].inject(0) { |sum, a| sum + a.to_i }
                new_row[newcol] = (sum / data[:count])  
              when :count
                new_row[newcol] = data[:count]  
              else            
                new_row[newcol] = data[:cells][col].inject(0) { |sum, a| sum + a.to_i }
              end
            end
            new_keys << newcol
          end
        end
        new_data << Item.ensure(new_row)
      end
      
      @data = new_data
      new_keys.compact
    end
    
    def pivot(columns, rows, value, aggregation = :sum)
      data_hash = {}
      
      @data.each do |row|
        column_key = Data.array(columns).map { |rk| row[rk] }
        row_key = Data.array(rows).map { |rk| row[rk] }
        data_hash[row_key] ||= {}
        data_hash[row_key][column_key] ||= {:sum => 0, :data => {}, :count => 0}
        focus = data_hash[row_key][column_key]
        focus[:data] = clean_data(row)
        focus[:count] += 1
        focus[:sum] += row[value].to_i
      end
      
      new_data = []
      new_keys = {}
      
      data_hash.each do |row_key, row_hash|
        new_row = {}
        row_hash.each do |column_key, data|
          column_key.each do |ckey|
            new_row.merge!(data[:data])
            case aggregation
            when :average
              new_row[ckey] = (data[:sum] / data[:count])  
            when :count
              new_row[ckey] = data[:count]  
            else            
              new_row[ckey] = data[:sum]              
            end
            new_keys[ckey] = true
          end
        end
        new_data << Item.ensure(new_row)
      end
      
      @data = new_data
      new_keys.keys
    end
    
    def self.array(string_or_array)
      if string_or_array.is_a? Array
        return string_or_array
      else
        return [string_or_array]
      end
    end
    
    def size
      @data.size
    end
    alias :length :size
    
    def valid?
      if ((@data.size > 0) &&
        (@data.respond_to? :each_with_index) &&
        (@data.first.respond_to? :keys)) &&
        (!@data.first.is_a? String)
        return true
      else
        return false
      end
    rescue
      false
    end

    # cols is an array of column names, if given the nested arrays are built in this order
    def to_a(cols=nil)
      array = []
      cols ||= self.columns
      @data.each do |row|
        array << cols.inject([]){ |a,col| a << row[col] }
      end
      array
    end
    
  end
  
end

