require 'spec_helper'
describe User, type: :model do
  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end

  context 'associations' do
    it { should have_many(:events) }
  end
end
