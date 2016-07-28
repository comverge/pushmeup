module FCM
  class RequestCreator

    # Returns a map populated from the given notification.
    # The top level map has two keys: headers and body
    def self.create_headers_body(notification)
      n = notification

      headers = {
        'Authorization' => "key=#{FCM.key(n.identity)}",
        'Content-Type' => 'application/json',
      }

      body = {
        :registration_ids => n.device_tokens,
        :collapse_key => n.collapse_key,
        :time_to_live => n.time_to_live,
        :delay_while_idle => n.delay_while_idle
      }
      body[:data] = n.data unless n.data.empty?
      body[:notification] = n.notification unless n.notification.empty?

      {headers: headers, body: body}
    end
  end
end
