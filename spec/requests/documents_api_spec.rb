require 'spec_helper'

describe 'Document API' do
  def app
    Sinatra::Application
  end

  context 'GET /v1/events/:event_id/documents' do
    it 'get all the documents from an event' do
      event = create(:event)
      document = create(:document, event: event)
      document2 = create(:document, event: event)
      document3 = create(:document, event: event)

      get "/v1/events/#{event.id}/documents"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body[0]['file_path']).to eq(document.file_path)
      expect(parsed_body[1]['file_path']).to eq(document2.file_path)
      expect(parsed_body[2]['file_path']).to eq(document3.file_path)
    end

    it 'event does not have documents created' do
        event = create(:event)

        get "/v1/events/#{event.id}/documents"
        
        expect(last_response.status).to eq 204
    end
  end

  context 'GET /v1/events/:event_id/documents/:id' do
    it 'get specifc document from event' do
      event = create(:event)
      document = create(:document, event: event)

      get "/v1/events/#{event.id}/documents/#{document.id}"

      expect(last_response.status).to eq 200
      expect(last_response.content_type).to include('application/json')

      parsed_body = JSON.parse(last_response.body)

      expect(parsed_body['file_path']).to eq(document.file_path)
    end

  end

  context 'POST /v1/events/:event_id/documents' do

    it 'create an document' do
      event = create(:event)

      post "/v1/events/#{event.id}/documents",:file => Rack::Test::UploadedFile.new('spec/fixtures/test_image.jpeg', 'image/jpeg'), 'CONTENT_TYPE' => 'image/jpeg'
      
      expect(last_response.status).to eq 201
    end

    it "can upload PDF" do
      event = create(:event)

      post "/v1/events/#{event.id}/documents",:file => Rack::Test::UploadedFile.new('spec/fixtures/Desafio - Programa de OnBoarding.pdf', 'appplication/pdf'), 'CONTENT_TYPE' => 'appplication/pdf'

      expect(last_response.status).to eq 201
    end

    it "can upload DOCX" do
        event = create(:event)

        post "/v1/events/#{event.id}/documents",:file => Rack::Test::UploadedFile.new('spec/fixtures/Teste.docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'), 'CONTENT_TYPE' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation'

        expect(last_response.status).to eq 201
    end

    it "can upload ODS" do
        event = create(:event)

        post "/v1/events/#{event.id}/documents",:file => Rack::Test::UploadedFile.new('spec/fixtures/teste.ods', 'application/vnd.oasis.opendocument.spreadsheet'), 'CONTENT_TYPE' => 'application/vnd.oasis.opendocument.spreadsheet'

        expect(last_response.status).to eq 201
    end

    it "can upload XLSX" do
        event = create(:event)

        post "/v1/events/#{event.id}/documents",:file => Rack::Test::UploadedFile.new('spec/fixtures/teste.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'), 'CONTENT_TYPE' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

        expect(last_response.status).to eq 201
    end

    it "can upload PPTX" do
        event = create(:event)

        post "/v1/events/#{event.id}/documents",:file => Rack::Test::UploadedFile.new('spec/fixtures/teste.pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation'), 'CONTENT_TYPE' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation'

        expect(last_response.status).to eq 201
    end

  end
end
