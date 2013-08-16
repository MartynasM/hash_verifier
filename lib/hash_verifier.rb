require "hash_verifier/version"

class HashMatchError < StandardError; end
class SizeMismatch  < HashMatchError; end
class ClassMismatch < HashMatchError; end
class ValueMismatch < HashMatchError; end

class HashVerifier
  class << self
  
    def strict_verify(data, pattern)
      verify(data, pattern, true)
    end
  
    def verify(data, pattern, strict = false)
      match_size(data, pattern, strict)
      pattern.each do |pkey, pval|
        !match(data[pkey], pval, strict)
      end
      true
    end
  
    private
  
    def match_size(data, pattern, strict = false)
      raise SizeMismatch.new "Data: #{data.size} - Pattern: #{pattern.size}" if strict and data.size != pattern.size
    end
  
    def match(data, data_pattern, strict = false)
      if data_pattern.class == Class
        match_class(data, data_pattern, strict)
      elsif data_pattern.class == Array
        match_array(data, data_pattern, strict)
      elsif data_pattern.class == Hash
        verify(data, data_pattern, strict)
      elsif 
        match_value(data, data_pattern, strict)
      end
    end
  
    def match_value(data, data_pattern, strict = false)
      if data != data_pattern
        raise ValueMismatch.new "#{data} is not equal to #{data_pattern}"
      end 
    end
  
    def match_class(data, data_pattern, strict = false)
      if strict
        if data.class != data_pattern
          raise ClassMismatch.new "#{data}(#{data.class}) class doesn't match #{data_pattern}"
        end
      else
        if !data.kind_of?(data_pattern)
          raise ClassMismatch.new "#{data}(#{data.class.ancestors}) class doesn't match #{data_pattern}"
        end
      end
    end
  
    # this is where it gets interesting
    def match_array(data, data_pattern, strict = false)
      match_class(data, Array, strict) # percaution
      if data_pattern.size == 1
        match_array_single(data, data_pattern, strict)
      else
        match_array_full(data, data_pattern, strict)
      end
    end
  
    def match_array_single(data, data_pattern, strict = false)
      data.each do |member|
        match(member, data_pattern.first, strict)
      end
    end
  
    def match_array_full(data, data_pattern, strict = false)
      match_size(data, data_pattern, strict)
      data_pattern.each_with_index do |pattern, index|
        match(data[index], pattern, strict)
      end
    end

  end
end
