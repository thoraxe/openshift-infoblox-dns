# some configuration for this plugin is required, namely:
# 1) IP address or hostname of the infoblox appliance that will receive our API acll
# 2) username
# 3) password

require 'rubygems'
require 'json'
require 'rest-client'

@infoblox_info = {:location => "hostname_or_ip", :username => "someusername", :password => "somepassword", :baseurl => "wapi", :apiversion => "v1.1"}
@infoblox_base_url = "https://#{@infoblox_info[:username]}:#{@infoblox_info[:password]}@#{@infoblox_info[:location]}/#{@infoblox_info[:baseurl]}/#{@infoblox_info[:apiversion]}/"

def register_application(app_name, namespace, public_hostname)
  # in this case, public_hostname is the hostname of the node the
  # application is running on

  # create a cname record for the application in the domain
  fqdn = "#{app_name}-#{namespace}.#{@domain_suffix}"

  # build the json data to submit to create the cname record
  data_to_send = JSON.parse({'canonical' => public_hostname, 'name' => fqdn}.to_json)

  res = RestClient.post "#{@infoblox_base_url}record:cname", data_to_send, :content_type => :json, :accept => :json

end

def deregister_application(app_name, namespace)
  # delete the CNAME record for the application in the domain

  # build the fqdn string for the application
  fqdn = "#{app_name}-#{namespace}.#{@domain_suffix}"

  # we need to get the infoblox id for the record we wish to delete
  id_value = get_cname_id(fqdn)

  res = RestClient.delete "#{@infoblox_base_url}#{id_value}", :accept => :json

end

def modify_application(app_name, namespace, new_public_hostname)
  # modify the CNAME record for the application in the domain

  # build the fqdn string for the application
  fqdn = "#{app_name}-#{namespace}.#{@domain_suffix}"

  # we need to get the infoblox id for the record we wish to modify
  id_value = get_cname_id(fqdn)

  # build the json data to submit to modify the cname record
  data_to_send = JSON.parse({'canonical' => new_public_hostname, 'name' => fqdn}.to_json)

  res = RestClient.put "#{@infoblox_base_url}#{id_value}", data_to_send, :content_type => :json, :accept => :json

end

# get the special cname id string from the appliance for use elsewhere
def get_cname_id(fqdn)
  res = RestClient.get "#{@infoblox_base_url}record:cname", :params => {:name => fqdn}, :accept => :json

  (JSON.parse(res))[0]["_ref"]
end
