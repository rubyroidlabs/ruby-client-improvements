require 'json'
require 'benchmark'
require 'finapps'
require_relative 'lib/finapps/rest/client_improved'

ORDER_ID = 42
CREATE_PARAMS = { applicant: 'valid', institutions: 'valid', product: 'valid' }.freeze
LIST_PARAMS = {
  page: 2, sort: 'status', requested: 25, searchTerm: 'term', status: %w(1 7),
  assignment: 'valid_operator', relation: ['valid_order_id']
}.freeze
N = 30_000

# NOTE: Mock requests for benchmarks
module FinAppsCore
  module REST
    module Connection
      def faraday(config, logger)
        options = {
          url: "#{config.host}/v#{Defaults::API_VERSION}/",
        }
        Faraday.new(options) do |conn|
          conn.adapter :test do |stub|
            stub.get('/v3/orders/valid_id') { |env| [200, {}, 'OK'] }
            stub.get('/v3/orders') { |env| [200, {}, 'OK'] }
            stub.post('/v3/orders') { |env| [200, {}, 'OK'] }
            stub.put("/v3/orders/#{ORDER_ID}/cancel") { |env| [200, {}, 'OK'] }
          end
        end
      end
    end
  end
end

Benchmark.bm(9) do |x|
  x.report("client:  ") do
    client = FinApps::REST::Client.new :tenant_token, rashify: true
    orders = FinApps::REST::Orders.new(client)

    N.times do
      orders.show(:valid_id)
      orders.create(CREATE_PARAMS)
      orders.list(LIST_PARAMS)
      orders.destroy(ORDER_ID)
    end
  end

  x.report("improved:") do
    client = FinApps::REST::ClientImproved.new :tenant_token, rashify: true
    orders = FinApps::REST::Orders.new(client)

    N.times do
      orders.show(:valid_id)
      orders.create(CREATE_PARAMS)
      orders.list(LIST_PARAMS)
      orders.destroy(ORDER_ID)
    end
  end
end
