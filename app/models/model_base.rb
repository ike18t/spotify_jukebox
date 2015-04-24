class ModelBase
  def initialize params={}
    params.each do |key, value|
      instance_variable_set "@#{key}", value
    end
  end

  def to_hash
    hash = {}
    self.instance_variables.each {|var| hash[var.to_s.delete("@")] = self.instance_variable_get(var) }
    hash
  end
end
