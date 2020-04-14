describe CacheClient do

  it "set correctly an JSON in the cache using the same instance" do

    cache = CacheClient.new

    key   = 'chave'
    value = {first_name: 'Henrique', last_name: 'Lima'}
    cache.set(key, value.to_json)

    obj         = JSON.parse(cache.get(key))
    first_name  = obj['first_name']
    last_name   = obj['last_name']

    expect(first_name).to eq(value[:first_name])
    expect(last_name).to eq(value[:last_name])

    cache.delete(key)
    cache.close

  end

end
