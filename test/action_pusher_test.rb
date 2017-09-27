require 'test_helper'
require 'rpush'

require 'action_pusher'

MESSAGE = 'This is a test message'

class MyPusher < ActionPusher::Base
  def push_message(app, device_token, message = MESSAGE, custom = {})
    push(app, device_token, message, custom)
  end
end

class ActionPusherTest < Minitest::Test
  include ActionPusher

  def setup
    @apns_app = Rpush::Apns::App.first
    @apns_token = '00fc13adff785122b4ad28809a3420982341241421348097878e577c991de8f0'
    @gcm_app = Rpush::Gcm::App.first
    @gcm_token = 'gcm_token'
  end

  def test_pusher_methods_can_be_called_on_instances
    pusher = MyPusher.new
    pusher.expects(:push_message).with(@apns_app, @apns_token)
    pusher.push_message(@apns_app, @apns_token)
  end

  def test_pusher_methods_can_be_called_on_classes
    MyPusher.any_instance.expects(:push_message).with(@apns_app, @apns_token)
    MyPusher.push_message(@apns_app, @apns_token)
  end

  def test_push_apns_calls_correct_method
    MyPusher.any_instance.expects(:push_to_apns).with(@apns_app, @apns_token, MESSAGE, {})
    MyPusher.push_message(@apns_app, @apns_token)
  end

  def test_push_gcm_calls_correct_method
    MyPusher.any_instance.expects(:push_to_gcm).with(@gcm_app, @gcm_token, MESSAGE, {})
    MyPusher.push_message(@gcm_app, @gcm_token)
  end

  def test_push_to_other_apps_fail
    assert_raises ArgumentError do
      MyPusher.push_message(Rpush::Adm::App.new, 'token')  # Amazon Device Messaging
    end
  end

  def test_apns_push_plain
    notification = MyPusher.push_message(@apns_app, @apns_token)
    assert_equal MESSAGE, notification.alert
    assert_equal 'default', notification.sound
  end

  def test_apns_push_long_message
    notification = MyPusher.push_message(@apns_app, @apns_token, 'a' * 120)
    assert_equal 110, notification.alert.length
    assert_equal '...', notification.alert.last(3)
    assert_equal 'a', notification.alert[106]
    assert_equal 'default', notification.sound
  end

  def test_apns_push_with_badge
    notification = MyPusher.push_message(@apns_app, @apns_token, MESSAGE, { badge: 2 })
    assert_equal 2, notification.badge
    assert_equal({}, notification.data)
  end

  def test_apns_push_with_custom_sound
    notification = MyPusher.push_message(@apns_app, @apns_token, MESSAGE, { sound: 'allora' })
    assert_equal 'allora', notification.sound
    assert_equal({}, notification.data)
  end

  def test_apns_push_with_custom_data
    notification = MyPusher.push_message(@apns_app, @apns_token, MESSAGE, { deck: 'abc123' })
    assert_equal({ 'deck' => 'abc123' }, notification.data)
  end
end
