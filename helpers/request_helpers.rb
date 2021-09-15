helpers do
  def get_body(req)
    req.body.rewind
    JSON.parse(req.body.read)
  end

  def response_body(status, body)
    [status(status), body.to_json]
  end
end
