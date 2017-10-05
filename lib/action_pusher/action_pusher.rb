require "abstract_controller"

module ActionPusher
  class Base < AbstractController::Base

    class << self
      def respond_to?(method, include_private = false)
        super || action_methods.include?(method.to_s)
      end

      protected
      def method_missing(method_name, *args)
        if respond_to?(method_name)
          new.send(method_name, *args)
        else
          super
        end
      end
    end

    def push(app, device_token, message, custom = {})
      if app.is_a? Rpush::Apns::App
        _push = :push_to_apns
      elsif app.is_a? Rpush::Gcm::App
        _push = :push_to_gcm
      else
        raise ArgumentError, "Unsupported app"
      end

      return send _push, app, device_token, message, custom
    end

    def push_to_apns(app, device_token, message, custom = {})
      n = Rpush::Apns::Notification.new
      n.app = app
      n.device_token = device_token
      n.alert = message.truncate(110)  # TODO: They can be longer now, right?
      if custom[:badge]
        n.badge = custom.delete(:badge)
      end
      n.sound = custom.delete(:sound) || 'default'
      n.data = custom
      n.save!
      return n
    end

    def push_to_gcm(device_token, message, custom = {})
      n = Rpush::Gcm::Notification.new
      n.app = Rpush::Gcm::App.find_by_name("android")
      n.registration_ids = [device_token]
      n.data = { message: message }.merge(custom)
      n.save!
      return n
    end
  end
end
