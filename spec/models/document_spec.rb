require 'spec_helper'
describe Document, type: :model do
  context 'associations' do
    it { should belong_to(:event) }
  end
end
