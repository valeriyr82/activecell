require 'spec_helper'

describe Settings do
  describe 'email_notifications.default_from' do
    it { expect(Settings.email_notifications.default_from).to eq('noreply@activecell.com') }
  end
end
