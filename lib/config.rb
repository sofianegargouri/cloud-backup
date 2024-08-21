# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'
Dir["#{__dir__}/providers/*.rb"].each { |file| require file }
require 'yaml'

class Config
  attr_reader :config

  def self.load(config_path)
    config_class = Config.new(config_path)
    config_class.config
  end

  def initialize(config_path)
    @config_path = config_path

    if File.exist?(config_path)
      @config = parsed_config_file_content
      load_providers
    else
      warn_config_file
    end
  end

  private

  def load_providers
    @config[:providers] = @config[:providers].transform_values do |options|
      load_provider(options.with_indifferent_access)
    end
  end

  def load_provider(options)
    provider_class = "Providers::#{options[:type].camelize}".constantize
    provider_class.from_hash(options)
  end

  def parsed_config_file_content
    @parsed_config_file_content ||= YAML.load(config_file_content).with_indifferent_access
  end

  def config_file_content
    @config_file_content ||= File.read(@config_path)
  end

  def warn_config_file
    raise StandardError, 'No config.yaml file found'
  end
end
