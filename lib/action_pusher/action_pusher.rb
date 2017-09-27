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

    def old_push(user_or_users, args = {})
      c = args[:custom] || {}
      if user_or_users.respond_to? :each
        push_to_users(user_or_users, args[:alert], args[:badge], c)
      else
        push_to_user(user_or_users, args[:alert], args[:badge], c)
      end
    end

    def old_push_to_users(users, message, badge = nil, custom = {})
      users.each { |user| push_to_user user, message, badge, custom }
    end

    def old_push_to_user(user, message, badge = nil, custom = {})
      user.devices.each { |device| push_to_device device, message, badge, custom }
    end

    def old_push_to_device(device, message, badge = nil, custom = {})
      if device.push_token.present?
        send("push_to_#{device.device_type}", device.push_token, message.squish, badge, custom)
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
