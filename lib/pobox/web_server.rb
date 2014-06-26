module Pobox
  class WebServer < Goliath::API
    def response(env)
      case env['REQUEST_URI']
      when '/'
        handle_root
      when /^\/([[:alnum:]]+)$/
        handle_mailbox(env, $1)
      when /^\/([[:alnum:]]+)\/([0-9]+)$/
        handle_message(env, $1, $2)
      else
        [404, {}, "Not found"]
      end
    end

    def handle_root
      [200, {}, Message.all.to_json]
    end

    def handle_mailbox(env, mailbox)
      [200, {}, Message.where(recipient: mailbox).to_json]
    end

    def handle_message(env, mailbox, message_id)
      [200, {}, Message.where(recipient: mailbox, id: message_id).first.to_json]
    end
  end
end
