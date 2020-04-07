class CacheClient

  def initialize(namespace = 'default', url = ENV['MEMCACHED_URL'], compress = true)
    options = { :namespace => namespace, :compress => compress }
    @cache = Dalli::Client.new(url, options)
  end

  def set(key, value, ttl = nil)
    @cache.set(key, value, ttl)
  end

  def get(key)
    @cache.get(key)
  end

  def delete(key)
    @cache.delete(key)
  end

  def close
    @cache.close
  end

end
