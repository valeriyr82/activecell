require 'spec_helper'

describe HomeController do
  before { controller.stub(:current_user).and_return(nil) }

  describe 'on GET to :index' do
    before { get :index }
    it { should respond_with(:redirect) }
  end
end
