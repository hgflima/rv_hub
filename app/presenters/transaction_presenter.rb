class TransactionPresenter

  def initialize(transaction)
    @transaction = transaction
  end

  def success
    uuid = @transaction.uuid
    json = @transaction.attributes.except('uuid')
    json['id'] = uuid
    json['statuses'] = @transaction.status_history
                                    .map { |h|
                                    h.attributes.except('id',
                                                        'transaction_id',
                                                        'updated_at') }
    json['links'] = get_links
    return json
  end

  def get_links
    links = HYPERMEDIA[@transaction.status]
      .map { |h| { "href" => h['href'].gsub(":transaction_id", @transaction.uuid),
                                            "rel"  => h['rel'],
                                            "type" => h['type']} }
    return links
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
