require 'spec_helper'
describe User, type: :model do
  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end

  context 'associations' do
    it { should have_many(:events).with_foreign_key('owner_id') }
    it { should have_many(:invites) }
  end
end
