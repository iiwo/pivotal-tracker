module PivotalTracker
  class Person
    include HappyMapper

    element :id, Integer
    element :name, String
    element :email, String
    element :initials, String

    PivotalTracker::Membership
    PivotalTracker::Story

    def initialize(attributes={})
        update_attributes(attributes)
    end

    def update_attributes(attrs)
        attrs.each do |key, value|
          self.send("#{key}=", value.is_a?(Array) ? value.join(',') : value )
        end
    end

    class << self
      def me
        Client.use_ssl = true
        parse(Client.connection['/me'].get)
      end
    end
  end
end