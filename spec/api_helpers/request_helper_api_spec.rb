require 'spec_helper'
require_relative '../../helpers/request_helpers'

class TestHelper
  attr_accessor :params

  include RequestHelpers

  def initialize
    @params = { 'start_date': 'error', 'end_date': 'error' }
  end

  def halt(error)
    error
  end

  def status(num)
    num
  end
end

describe 'Request Helpers' do
  def app
    Sinatra::Application
  end

  let(:helper) { TestHelper.new }
  let(:user) { create(:user, email: 'email@gmail.com') }

  it 'should return false if was not provided search param' do
    expect(helper.was_provided_filters?).to eq(false)
  end
  it 'error on filtering return an halt' do
    expected_response = [400,
                         { error: 'Parâmetros de filtros invalidos, tente novamente' }.to_json]
    expect(helper.error_on_filtering?('Error')).to eq(expected_response)
  end
end
