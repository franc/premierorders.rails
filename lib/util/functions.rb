module Functions
  IDENTITY = lambda{|v| v}

  def self.const(v) 
    lambda{|discard| v}
  end

  def self.error(message) 
    lambda do |v|
      raise message
    end
  end
end
