class TransactionPresenter < ApplicationPresenter

  def success(object = nil)

    obj  = object.nil? ? @object : object
    uuid = obj.uuid
    json = obj.attributes.except('uuid')
    json['id'] = uuid
    json['statuses'] = obj.status_history
                                    .map { |h|
                                    h.attributes.except('id',
                                                        'transaction_id',
                                                        'updated_at') }
    json['links'] = get_links(obj)
    return json
    
  end

  def get_links(obj)
    links = HYPERMEDIA[obj.status]
      .map { |h| { "href" => h['href'].gsub(":transaction_id", obj.uuid),
                                            "rel"  => h['rel'],
                                            "type" => h['type']} }
    return links
  end

  def get_find_all_resource
    'transactions'
  end

  HYPERMEDIA = {
    "authorized" => [
      {
        "href" => "/transactions/:transaction_id",
        "rel" => "self",
        "type" => "GET"
      },
      {
        "href" => "/transactions/:transaction_id/capture",
        "rel" => "capture",
        "type" =>  "POST"
      },
      {
        "href" => "/transactions/:transaction_id",
        "rel" => "refund",
        "type" => "DELETE"
      }
    ],
    "denied" => [
      {
        "href" => "/transactions/:transaction_id",
        "rel" => "self",
        "type" => "GET"
      }
    ],
    "captured" => [
      {
        "href" => "/transactions/:transaction_id",
        "rel" => "self",
        "type" => "GET"
      }
    ],
    "refunded" => [
      {
        "href" => "/transactions/:transaction_id",
        "rel" => "self",
        "type" => "GET"
      }
    ]
  }

end
