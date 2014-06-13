class SpinDoctor
  def self.get_next_item list, last
    last_index = list.index(last)
    return list.sample if last_index.nil?
    list.rotate(last_index + 1).first
  end
end
