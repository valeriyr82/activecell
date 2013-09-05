require 'spec_helper'

# Automatically test all your factories
# @see: https://github.com/thoughtbot/factory_girl/wiki/Testing-all-Factories-%28with-RSpec%29
describe FactoryGirl do
  FactoryGirl.factories.each do |factory|
    context "with factory for :#{factory.name}" do
      subject { FactoryGirl.build(factory.name) }

      it "is valid" do
        expect(subject.valid?).to be_true
      end
    end
  end
end
