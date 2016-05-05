module ImperatorApi
  class RouteConstraints
    def initialize(options)
      @version = options[:version]
      @default = options[:default]
    end

    def matches?(req)
      matches_format?(req.format) &&
        matches_headers?(req.headers) ||
        matches_parameters?(req.parameters) ||
        @default
    end

    private

    def matches_parameters?(parameters)
      parameters['imperator_api_version'] == @version
    end

    def matches_format?(format)
      format.to_s == 'application/json' || format.to_s == 'application/xml'
    end

    def matches_headers?(headers)
      headers['Accept'] &&
        headers['Accept'].include?(media_type) ||
        headers['Accept'].include?(media_type_version)
    end

    def media_type
      "application/vnd.imperator_api.v#{@version}"
    end

    def media_type_version
      "application/vnd.imperator_api+json; version=#{@version}"
    end
  end
end
