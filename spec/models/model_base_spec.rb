require_relative '../spec_helper'

describe ModelBase do
  context 'initialize' do
    it { ModelBase.new({:foo => :bar}).instance_variable_get(:@foo).should eq(:bar) }

    it { ModelBase.new({:foo => :bar, :bizz => :buzz }).instance_variable_get(:@bizz).should eq(:buzz) }
  end
end
