require 'uri'
require 'byebug'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = route_params
      parse_www_encoded_form(req.query_string.to_s)
      parse_www_encoded_form(req.body.to_s)
    end

    def [](key)
      unless @params[key]
        if key.is_a? Symbol
          key = key.to_s
        elsif key.is_a? String
          key = key.to_sym
        end
      end
      @params[key]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      URI::decode_www_form(www_encoded_form).each do |pairs|
        key, value = pairs
        parsed_keys = parse_key(key)
        working_position = @params

        parsed_keys.each_with_index do |key, idx|
          if idx == parsed_keys.length - 1
            working_position[key] = value
          else
            working_position[key] ||= {}
            working_position = working_position[key]
          end
        end
      end
      nil
    end

    #
    # failed recursion
    #
    # @params = build_hash_structure(parsed_keys, parsed_keys, value)
    #
    # def build_hash_structure(all_keys, keys, value)
    #   key = keys.shift
    #   return { key => value } if keys.empty?
    #
    #   hash = build_hash_structure(all_keys, keys, value)
    #   { key => hash }
    # end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      if key.match(/\]\[|\[|\]/)
        key.split(/\]\[|\[|\]/)
      else
        [key]
      end
    end
  end
end
