require_relative '../spec_helper'

describe Attributor::Collection do

  subject(:type) { Attributor::Collection }

  context '.native_type' do
    it "should return Array" do
      type.native_type.should be(::Array)
    end
  end

  context '.decode_json' do
    context 'for valid JSON strings' do
      [
          '[]',
          '[1,2,3]',
          '["alpha", "omega", "gamma"]',
          '["alpha", 2, 3.0]'
      ].each do |value|
        it "parses JSON string as array when incoming value is #{value.inspect}" do
          type.decode_json(value).should == JSON.parse(value)
        end
      end
    end

    context 'for invalid JSON strings' do
      [
          '{}',
          'foobar',
          '2',
          '',
          2,
          nil
      ].each do |value|
        it "parses JSON string as array when incoming value is #{value.inspect}" do
          expect {
            type.decode_json(value)
          }.to raise_error(Attributor::AttributorException)
        end
      end
    end

  end

  context '.load' do
    context 'for incoming Array values' do
      [
        [],
        [1,2,3],
        [Object.new, [1,2], nil, true]
      ].each do |value|
        it "returns value when incoming value is #{value.inspect}" do
          type.load(value).should == value
        end
      end
    end

    #context 'for incoming invalid values' do
    #
    #  it "raises when incoming value is #{value.inspect}" do
    #    value = [nil, Object.new, {}, true, false, 1]
    #    expect { type.load(value) }.to raise_error(Attributor::AttributorException, /cannot load value/)
    #  end
    #end
  end

  context '.validate' do
    context 'for valid Array values' do
      it "returns no errors for []" do
        type.validate([], nil, nil).should == []
      end
    end

    context 'for invalid Array values' do
      it "returns errors for [1,2]" do
        errors = type.validate([1,2], "monkey", nil)
        errors.should_not be_empty
        errors.include?("Collection monkey[0] is not an Attributor::Type").should be_true
        errors.include?("Collection monkey[1] is not an Attributor::Type").should be_true
      end

      it "returns errors for [nil]" do
        errors = type.validate([nil], "dog", nil)
        errors.should_not be_empty
        errors.include?("Collection dog[0] is not an Attributor::Type").should be_true
      end

      it "returns errors for [1.0, Object.new]" do
        errors = type.validate([1.0, Object.new], "cat", nil)
        errors.should_not be_empty
        errors.include?("Collection cat[0] is not an Attributor::Type").should be_true
        errors.include?("Collection cat[1] is not an Attributor::Type").should be_true
      end
    end
  end

  context '.example' do
    it "returns an Array" do
      value = type.example({})
      value.should be_a(::Array)
    end

    Attributor::BASIC_TYPES.each do |element_type|
      it "returns an Array of native types of #{element_type}" do
        value = Attributor::Collection.of(element_type).example({})
        value.all? { |element| element_type.valid_type?(element) }.should be_true
      end
    end
  end
end
