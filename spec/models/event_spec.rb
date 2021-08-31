require 'spec_helper'
describe Event, type: :model do
  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:local) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
  end

  context 'associations' do
    it { should have_many(:documents) }
    it { should belong_to(:user).with_foreign_key('owner_id') }
  end
end
