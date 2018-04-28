require_relative '../../finapps_core/rest/base_client_improved'

module FinApps
  module REST
    class ClientImproved < FinAppsCore::REST::BaseClientImproved # :nodoc:
      RESOURCES = %i(
        institutions
        institutions_forms
        orders
        order_assignments
        order_notifications
        order_refreshes
        order_reports
        order_statuses
        order_tokens
        operators
        operators_password_resets
        password_resets
        products
        sessions
        statements
        consumers
        consumer_institution_refreshes
        user_institutions
        user_institutions_forms
        user_institutions_statuses
        version
      ).freeze

      # @param [String] tenant_token
      # @param [Hash] options
      # @return [FinApps::REST::Client]
      def initialize(tenant_token, options={}, logger=nil)
        not_blank(tenant_token, :tenant_token)

        merged_options = options.merge(tenant_token: tenant_token)
        super(merged_options, logger)
      end

      RESOURCES.each do |method|
        define_method(method) do
          class_name = camelize(method.to_s)
          variable = "@#{class_name.downcase}"
          unless instance_variable_defined?(variable)
            klass = ::FinApps::REST.const_get(class_name)
            instance_variable_set(variable, klass.new(self))
          end
          instance_variable_get(variable)
        end
      end

      private

      def camelize(term)
        string = term.to_s
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
        string.gsub!(%r{(?:_|(/))([a-z\d]*)}) { $2.capitalize.to_s }
        string
      end
    end
  end
end
