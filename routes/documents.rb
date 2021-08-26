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

get '/v1/events/:event_id/documents/:id/download' do
    status 200
    document = Document.find(params[:id])
    send_file "./#{document.file_path}", :filename => 'Documento', :type => 'Application/octet-stream'
end
  
post '/v1/events/:event_id/documents' do
    if params[:file].nil?
        status 400
        return {succes:false, message: 'File param error'}.to_json
    end

    event = Event.where(id: params['event_id']).first

    if event.nil?
        status 404
        return {succes:false, message: "Can't upload document because event don't exist"}.to_json
    end

    file_name = params[:file][:filename]
    file = params[:file][:tempfile]
    type = params[:file][:type]
   
    document = Document.new(event: event, file_path: "./public/uploads/#{file_name}")

    if document.save and !file_name.nil?
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