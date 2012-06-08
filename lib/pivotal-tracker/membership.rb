module PivotalTracker
  class Membership
    include HappyMapper

    class << self
      def all(project, options={})
        parse(Client.connection["/projects/#{project.id}/memberships"].get)
      end
    end

    element :id, Integer
    element :role, String
    element :project_id, Integer

    # Flattened Attributes from <person>...</person>
    element :name, String, :deep => true
    element :email, String, :deep => true
    element :initials, String, :deep => true

    def create
      return self if project_id.nil?
      response = Client.connection["/projects/#{project_id}/memberships"].post(self.to_xml, :content_type => 'application/xml')
      new_membership = Membership.parse(response)
      new_membership.project_id = project_id
      return new_membership
    end

    def delete
      Client.connection["/projects/#{project_id}/memberships/#{id}"].delete
    end

    def debug
      self.to_xml
    end

    protected

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.membership {
            xml.role "#{role || 'Member'}"
            xml.person{
              xml.name "#{name}"
              xml.email "#{email}"
              xml.initials "#{initials}"
            }
          }
        end
        return builder.to_xml
      end

      def update_attributes(attrs)
        attrs.each do |key, value|
          self.send("#{key}=", value.is_a?(Array) ? value.join(',') : value )
        end
      end

  end
end
