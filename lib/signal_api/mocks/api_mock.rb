module SignalApi

  module ApiMock

    def self.included(base)
      base.extend(ClassMethods)
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

        define_method method do |*args|
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

      def mock_class_method(method, *parameter_names)
        @@mock_method_definitions[method] = parameter_names
        @@mock_method_calls[method] = []

        (class << self; self; end).instance_eval do
          define_method method do |*args|
            method_args = mock_method_definitions[method]

            called_args = {}
            method_args.each_with_index do |method_arg, i|
              called_args[method_arg] = args[i]
            end

            additional_info_method = method.to_s + "_additional_info"
            if method_defined?(additional_info_method)
              called_args.merge!(send(additional_info_method))
            end

            mock_method_calls[method] << called_args
          end
        end
      end

      def clear_mock_data
        @@mock_method_calls.keys { |k| @@mock_method_calls[k] = [] }
      end
    end
  end
end
