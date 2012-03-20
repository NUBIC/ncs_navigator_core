require 'aker'
require 'faraday'
require 'faraday_stack'
require 'ncs_navigator/configuration'

module Aker::Authority
  class NcsNavigatorAuthority

    def initialize(ignored_config=nil)
      @groups = {}
      @portal = :NCSNavigator
    end

    def amplify!(user)
      base = user(user)
      return user unless base
      user.merge!(base)
    end
    
    def user(user)
      staff = get_staff(user)
      if staff
        u = Aker::User.new(user.username)
        u.portals << @portal
        attributes = ["first_name", "last_name", "email"]
        attributes.each do |a|
          setter = "#{a}="
          if u.respond_to?(setter)
            u.send(setter, staff[a])
          end
        end
        u.identifiers[:staff_id] = staff["staff_id"]
        groups = staff['roles'].collect do |role|
          role['name']
        end
      
        if groups
          u.group_memberships(@portal).concat(load_group_memberships(@portal, groups))
        end
        u
      else
        nil
      end
    end
    
    private 
    
    def staff_portal_uri
      NcsNavigator.configuration.staff_portal_uri
    end
    
    def get_connection(user)
      connection = Faraday::Connection.new(
        :url => staff_portal_uri
        ) do |builder|
          builder.adapter Faraday.default_adapter
          builder.request :json
          builder.insert(0, Aker::Authority::AkerToken, user.cas_proxy_ticket(staff_portal_uri))
          builder.use FaradayStack::ResponseJSON, :content_type => 'application/json'
        end
    end
    
    def load_group_memberships(portal, group_data)
      group_data.collect do |group|
        Aker::GroupMembership.new(find_or_create_group(portal, group))
      end
    end

    def find_or_create_group(portal, group_name)
      existing = (@groups[portal] ||= []).collect { |top|
        top.find { |g| g.name == group_name }
      }.compact.first
      return existing if existing      
      @groups[portal] << Aker::Group.new(group_name)
      @groups[portal].last
    end
    
    def get_staff(user)
      connection = get_connection(user)
      response = connection.get '/staff/' << user.username << '.json'
      if response.status == 200
        response.body
      else
        nil
      end
    end
    
  end
end