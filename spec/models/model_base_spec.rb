require_relative '../spec_helper'

describe ModelBase do
  context 'initialize' do
    it { expect(ModelBase.new(foo: :bar).instance_variable_get(:@foo)).to eq(:bar) }

    it { expect(ModelBase.new(foo: :bar, bizz: :buzz).instance_variable_get(:@bizz)).to eq(:buzz) }
  end
end
