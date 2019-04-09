class Tenant
  HOSTS = {
    wca:  "https://cubecomps.worldcubeassociation.org",
    luis: "http://cubecomps.com"
  }.with_indifferent_access.freeze

  def self.set_for_host(host)
    tenant = if host == "m.cubecomps.worldcubeassociation.org"
               "wca"
             else
               "luis"
             end

    Thread.current[:current_tenant] = tenant
  end

  def self.current
    Thread.current[:current_tenant] || "luis"
  end

  def self.cubecomps_host
    HOSTS[current]
  end
end
