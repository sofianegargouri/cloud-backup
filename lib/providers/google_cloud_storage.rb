# frozen_string_literal: true

require 'json'

module Providers
  class GoogleCloudStorage < BaseProvider
    attr_reader :bucket_name, :service_account_json_key

    def initialize(bucket_name:, service_account_json_key:, **opts)
      require 'google/cloud/storage'

      @bucket_name = bucket_name
      @service_account_json_key = service_account_json_key
      @opts = opts
    end

    def upload_file(local_path, destination)
      bucket.create_file(local_path, destination)
    end

    def list_folder_files(folder)
      bucket.files(prefix: "#{folder}/").map(&:name)
    end

    def delete_files(files_paths)
      files_paths.each do |file_path|
        puts "Searching #{file_path}"
        file = bucket.find_file(file_path)
        puts "Found #{file_path}"
        puts "Deleting #{file_path}"
        file.delete
        puts "Deleted #{file_path}"
      end
    end

    private

    def storage
      @storage ||= Google::Cloud::Storage.new(project_id:, credentials:)
    end

    def bucket
      @bucket ||= storage.bucket(bucket_name, skip_lookup: true)
    end

    def project_id
      @project_id ||= credentials[:project_id]
    end

    def credentials
      @credentials ||= JSON.parse(service_account_json_key).with_indifferent_access
    end
  end
end
