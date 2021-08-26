get '/v1/events/:event_id/documents' do 
    event = Event.find(params[:event_id])
    if event.documents.empty?
      status 204
     {success: true , message: 'No documents created yet for this event'}.to_json
    else
      status 200
      event.documents.to_json
    end
end

get '/v1/events/:event_id/documents/:id' do 
    document = Document.find(params[:id])
    if document.nil?
      status 204
     {success: true , message: 'Non existed document'}.to_json
    else
      status 200
      document.to_json
    end
end
  
post '/v1/events/:event_id/documents' do
    file_name = params[:file][:filename]
    file = params[:file][:tempfile]
    type = params[:file][:type]

   
    document = Document.new(event:Event.find(params[:event_id]), file_path: "./public/uploads/#{file_name}")

    if document.save
        if type == 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
            File.open("./public/uploads/#{file_name}", 'wb') do |f|
                f.write(file.read.force_encoding("UTF-8"))
            end
        else
            File.open("./public/uploads/#{file_name}", 'wb') do |f|
                f.write(file.read)
            end
        end
        status 201
        return {success: true}.to_json
    end
end