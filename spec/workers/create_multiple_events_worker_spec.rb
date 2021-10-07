require 'sidekiq/testing'
require 'csv'
require 'spec_helper'
require_relative '../../workers/init'
Sidekiq::Testing.fake!

RSpec.describe CreateMultipleEventsWorker, type: :worker do
  let(:csv) { File.read('./spec/fixtures/eventss.csv', encoding: 'UTF-8') }

  let(:csv_with_events_error) { File.read('./spec/fixtures/events_with_field_error.csv', encoding: 'UTF-8') }

  before(:each) { Sidekiq::Worker.clear_all }
  describe 'Create Multiple Events Worker' do
    it 'should respond to #perform' do
      expect(CreateMultipleEventsWorker.new).to respond_to(:perform)
    end
    it 'enqueues a communication worker' do
      3.times { create(:user) }

      expect do
        CreateMultipleEventsWorker.perform_async(csv,
                                                 { 'id' => User.first.id, 'name' => User.first.name,
                                                   'email' => User.first.email })
      end.to change(CreateMultipleEventsWorker.jobs, :size).by(1)
    end
  end

  it 'intiate and end job' do
    3.times { create(:user) }

    CreateMultipleEventsWorker.perform_async(csv,
                                             { 'id' => User.first.id, 'name' => User.first.name,
                                               'email' => User.first.email })
    expect(CreateMultipleEventsWorker.jobs.size).to eq(1)
    CreateMultipleEventsWorker.drain
    expect(CreateMultipleEventsWorker.jobs.size).to eq(0)
  end

  it 'actually creates events and invites' do
    3.times { create(:user) }
    owner = create(:user)
    CreateMultipleEventsWorker.new.perform(csv,
                                           { 'id' => owner.id, 'name' => owner.name,
                                             'email' => owner.email })
    expect(Event.count).to eq(2)
    expect(Invite.count).to eq(5)
  end
  it 'actually creates events and invites using peform_async' do
    3.times { create(:user) }
    owner = create(:user)
    CreateMultipleEventsWorker.perform_async(csv,
                                             { 'id' => owner.id, 'name' => owner.name,
                                               'email' => owner.email })
    CreateMultipleEventsWorker.drain
    expect(Event.count).to eq(2)
    expect(Invite.count).to eq(5)
  end

  it 'does not create events and invites if has an error in the csv' do
    3.times { create(:user) }

    owner = create(:user)
    CreateMultipleEventsWorker.perform_async(csv_with_events_error,
                                             { 'id' => owner.id, 'name' => owner.name,
                                               'email' => owner.email })

    expect(Event.all.count).to eq(0)
    expect(Invite.all.count).to eq(0)
  end
end
