class CreateRpushApps < ActiveRecord::Migration[5.1]
  def up
    app = Rpush::Gcm::App.new
    app.name = "android"
    app.auth_key = 'phony'
    app.connections = 1
    app.save!

    app = Rpush::Apns::App.new
    app.name = "ios"
    app.certificate = File.read("apns-certificate/self-signed.pem")
    app.password = "fisk"
    app.environment = "sandbox"
    app.connections = 1
    app.save!
  end
end
