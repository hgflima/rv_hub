class CacheClient

  class InitilizationError < StandardError; end

  def initialize(url = ENV['MEMCACHED_URL'], options = {})

    options[:namespace] ||= ENV['MEMCACHED_DEFAULT_NAMESPACE']
    options[:compress]  ||= ENV['MEMCACHED_COMPRESS']
    options[:ttl]       ||= ENV['MEMCACHED_DEFAULT_TTL']

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
