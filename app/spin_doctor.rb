class SpinDoctor
  def self.get_next_item list, last
    last_index = last.nil? ? nil : list.find_index{ |item| last.id == item.id }
    return list.sample if last_index.nil?
    list.rotate(last_index + 1).first
  end
end
