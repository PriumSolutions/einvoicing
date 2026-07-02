# frozen_string_literal: true

# Ruby 3.2 added Data.define. Keep the same value-object API available on older
# Rubies so the public invoice models remain immutable keyword-initialized
# records. Some Ruby 2.7 builds expose an empty Data class, so check for the
# method rather than only the constant.
class Data; end unless defined?(::Data)

unless Data.respond_to?(:define)
  class ::Data::Base
    def initialize(**attributes)
      members = self.class.members
      unknown = attributes.keys - members
      missing = members - attributes.keys

      raise ArgumentError, "unknown keywords: #{unknown.join(", ")}" unless unknown.empty?
      raise ArgumentError, "missing keywords: #{missing.join(", ")}" unless missing.empty?

      members.each do |member|
        instance_variable_set(:"@#{member}", attributes.fetch(member))
      end

      freeze
    end

    def self.members
      @members
    end

    def with(**attributes)
      unknown = attributes.keys - self.class.members
      raise ArgumentError, "unknown keywords: #{unknown.join(", ")}" unless unknown.empty?

      self.class.new(**to_h.merge(attributes))
    end

    def to_h
      self.class.members.each_with_object({}) do |member, result|
        result[member] = public_send(member)
      end
    end

    def deconstruct
      self.class.members.map { |member| public_send(member) }
    end

    def deconstruct_keys(keys)
      values = to_h
      return values if keys.nil?

      keys.each_with_object({}) do |key, result|
        result[key] = values[key] if values.key?(key)
      end
    end

    def ==(other)
      other.instance_of?(self.class) && other.to_h == to_h
    end
    alias eql? ==

    def hash
      [ self.class, to_h ].hash
    end

    def inspect
      attributes = self.class.members.map { |member| "#{member}=#{public_send(member).inspect}" }
      "#<data #{self.class} #{attributes.join(", ")}>"
    end
  end

  class ::Data
    def self.define(*members, &block)
      normalized_members = members.map(&:to_sym).freeze

      Class.new(Base) do
        @members = normalized_members

        class << self
          attr_reader :members
        end

        normalized_members.each do |member|
          attr_reader member
        end

        class_eval(&block) if block
      end
    end
  end
end
