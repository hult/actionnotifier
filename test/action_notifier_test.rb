require 'test_helper'
require 'rpush'

require 'action_notifier'

MESSAGE = 'This is a test message'

class MyNotifier < ActionNotifier::Base
  def sample_notification(app, device_token, message = MESSAGE, custom = {})
    notify(app, device_token, message, custom)
  end
end

class ActionNotifierTest < Minitest::Test
  def setup
    @apns_app = Rpush::Apns::App.first
    @apns_token = '00fc13adff785122b4ad28809a3420982341241421348097878e577c991de8f0'
    @gcm_app = Rpush::Gcm::App.first
    @gcm_token = 'gcm_token'
  end

  def test_notifier_methods_can_be_called_on_instances
    notifier = MyNotifier.new
    notifier.expects(:sample_notification).with(@apns_app, @apns_token)
    notifier.sample_notification(@apns_app, @apns_token)
  end

  def test_notifier_methods_can_be_called_on_classes
    MyNotifier.any_instance.expects(:sample_notification).with(@apns_app, @apns_token)
    MyNotifier.sample_notification(@apns_app, @apns_token)
  end

  def test_push_apns_calls_correct_method
    MyNotifier.any_instance.expects(:notify_apns).with(@apns_app, @apns_token, MESSAGE, {})
    MyNotifier.sample_notification(@apns_app, @apns_token)
  end

  def test_push_gcm_calls_correct_method
    MyNotifier.any_instance.expects(:notify_gcm).with(@gcm_app, @gcm_token, MESSAGE, {})
    MyNotifier.sample_notification(@gcm_app, @gcm_token)
  end

  def test_push_to_other_apps_fail
    assert_raises ArgumentError do
      MyNotifier.sample_notification(Rpush::Adm::App.new, 'token')  # Amazon Device Messaging
    end
  end

  def test_apns_push_plain
    notification = MyNotifier.sample_notification(@apns_app, @apns_token)
    assert_equal MESSAGE, notification.alert
    assert_equal 'default', notification.sound
  end

  def test_apns_push_long_message
    notification = MyNotifier.sample_notification(@apns_app, @apns_token, 'a' * 120)
    assert_equal 110, notification.alert.length
    assert_equal '...', notification.alert.last(3)
    assert_equal 'a', notification.alert[106]
    assert_equal 'default', notification.sound
  end

  def test_apns_push_with_badge
    notification = MyNotifier.sample_notification(@apns_app, @apns_token, MESSAGE, { badge: 2 })
    assert_equal 2, notification.badge
    assert_equal({}, notification.data)
  end

  def test_apns_push_with_custom_sound
    notification = MyNotifier.sample_notification(@apns_app, @apns_token, MESSAGE, { sound: 'allora' })
    assert_equal 'allora', notification.sound
    assert_equal({}, notification.data)
  end

  def test_apns_push_with_custom_data
    notification = MyNotifier.sample_notification(@apns_app, @apns_token, MESSAGE, { deck: 'abc123' })
    assert_equal({ 'deck' => 'abc123' }, notification.data)
  end
end
