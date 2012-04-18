module SignalApi

  module ApiMock

    def self.included(base)
      base.instance_methods.each { |m| base.send(:undef_method, m) unless m =~ /(^__|^nil\?$|^send$|class|proxy_|^object_id$)/ }
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module ClassMethods
      @@mock_method_definitions = {}
      @@mock_method_calls = {}

      def mock_method_calls
        @@mock_method_calls
      end

      def mock_method_definitions
        @@mock_method_definitions
      end

      def mock_method(method, *parameter_names)
        @@mock_method_definitions[method] = parameter_names
        @@mock_method_calls[method] = []
      end

      def clear_mock_data
        @@mock_method_calls.keys { |k| @@mock_method_calls[k] = [] }
      end
    end

    module InstanceMethods
      def method_missing(method, *args)
        method_args = self.class.mock_method_definitions[method]
        
        called_args = {}
        method_args.each_with_index do |method_arg, i|
          called_args[method_arg] = args[i]
        end

        additional_info_method = method.to_s + "_additional_info"
        if self.class.method_defined?(additional_info_method)
          called_args.merge!(send(additional_info_method))
        end

        self.class.mock_method_calls[method] << called_args
      end
    end

=begin
ree-1.8.7-2011.03 :013 >   SignalApi::ShortUrl.method(:create)
 => #<Method: SignalApi::ShortUrl.create> 
ree-1.8.7-2011.03 :014 > 
=end

  end
end
