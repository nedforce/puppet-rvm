Puppet::Type.type(:rvm_system_ruby).provide(:rvm) do
  desc "Ruby RVM support."

  commands :rvmcmd => "/usr/local/rvm/bin/rvm"

  def create
    if resource[:patch]
      rvmcmd "install", resource[:name], "--patch", resource[:patch]
    else
      rvmcmd "install", resource[:name]
    end
    set_default if resource.value(:default_use)
  end

  def destroy
    rvmcmd "remove", resource[:name], '--gems'
  end

  def exists?
    begin
      rvmcmd("list", "strings").split("\n").any? do |line|
        line =~ Regexp.new(Regexp.escape(resource[:name]))
      end
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list RVMs: #{detail}"
    end

  end

  def default_use
    begin
      rvmcmd("list", "default").split("\n").any? do |line|
        line =~ Regexp.new(Regexp.escape(resource[:name]))
      end
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list default RVM: #{detail}"
    end
  end

  def default_use=(value)
    set_default if value
  end

  def set_default
    rvmcmd "alias", "create", "default", resource[:name]
  end
end
