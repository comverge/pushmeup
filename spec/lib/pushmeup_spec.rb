require 'spec_helper'

describe "Pushmeup" do
  describe "APNS" do
    it "should have a APNS object" do
      expect(defined?(APNS)).to be
    end

    it "should not forget the APNS default parameters" do
      expect(APNS.host).to eq "gateway.sandbox.push.apple.com"
      expect(APNS.port).to be 2195
      expect(APNS.pem).to be_nil
      expect(APNS.pass).to be_nil
    end

    describe "Notifications" do
      describe "#==" do
        it "should properly equate objects without caring about object identity" do
          a = APNS::Notification.new("123", {:alert => "hi"})
          b = APNS::Notification.new("123", {:alert => "hi"})
          expect(a).to eq b
        end
      end
    end
  end

  describe "GCM" do
    it "should have a GCM object" do
      expect(defined?(GCM)).to be
    end

    describe "Notifications" do
      before do
        @options = {:data => "dummy data"}
      end

      it "should allow only notifications with device_tokens as array" do
        n = GCM::Notification.new("id", @options)
        expect(n.device_tokens.is_a?(Array)).to be true
      end

      it "should allow only notifications with data as hash with :data root" do
        n = GCM::Notification.new("id", { :data => "data" })
        expect(n.data.is_a?(Hash)).to be true
      end

      describe "#==" do
        it "should properly equate objects without caring about object identity" do
          a = GCM::Notification.new("id", { :data => "data" })
          b = GCM::Notification.new("id", { :data => "data" })
          expect(a).to eq(b)
        end
      end
    end
  end

  describe "FCM" do
    it "should have a FCM object" do
      expect(defined?(FCM)).to be
    end
  end

  describe "FCM::RequestCreator#create_headers_body" do
    let(:notification) {
      FCM::Notification.new("id", data: {key1: 'value1'}, notification: {key2: 'value2'})
    }

    it "has body and headers" do
      body_headers = FCM::RequestCreator.create_headers_body(notification)
      expect(body_headers[:body]).to be
      expect(body_headers[:headers]).to be
    end
  end
end
