module Munger
  
  # this class is a data munger
  #  it takes raw data (arrays of hashes, basically) 
  #  and can manipulate it in various interesting ways
  class Data
    
    attr_accessor :data
    
    # will accept active record
    # can take the options:
    #  :cache_id
    def initialize(options = {})
      @data = options[:data] if options[:data]
      yield self if block_given?
    end

    def columns
      @columns ||= @data.first.keys
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
        return hash_or_ar
      elsif hash_or_ar.respond_to? :attributes
        return hash_or_ar.attributes
      end
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
        focus[:sum] += row[value]
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
        (@data.respond_to :each_with_index) &&
        (@data.first.respond_to :keys)) &&
        (!@data.first.is_a? String)
        return true
      else
        return false
      end
    rescue
      false
    end
    
    
  
  end
  
end

