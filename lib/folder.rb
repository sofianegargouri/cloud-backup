# frozen_string_literal: true

require 'active_support'
require 'zip'

class Folder
  def self.backup(folder_data, config)
    folder = Folder.new(**folder_data.merge(config:).symbolize_keys)
    folder.backup
  end

  attr_reader :folder, :remote_folder, :provider, :config, :max_backups

  def initialize(folder:, remote_folder:, provider:, config:, max_backups:, **opts)
    @folder = folder
    @provider = provider
    @remote_folder = remote_folder
    @config = config.with_indifferent_access
    @max_backups = max_backups
    @opts = opts
  end

  def backup
    zip_folder
    upload_archive
    cleanup_storage_provider unless max_backups.nil?
    delete_archive_if_exists
  end

  private

  def cleanup_storage_provider
    storage_provider.cleanup_old_files(remote_folder, max_backups)
  end

  def zip_folder
    puts "Creating archive for #{folder}"

    delete_archive_if_exists

    Zip::File.open(archive_path, Zip::File::CREATE) do |zipfile|
      Dir["#{folder}/**/**"].each do |file|
        puts "Adding #{file} to archive"
        zipfile.add("#{folder_name}/#{File.basename(file)}", file)
      end
    end
  end

  def delete_archive_if_exists
    if File.exist?(archive_path)
      puts "Deleting existing archive at #{archive_path}"
      File.delete(archive_path)
    end

    puts 'Archive created'
  end

  def upload_archive
    puts 'Uploading archive'
    storage_provider.upload_file(archive_path, remote_archive_path)
    puts 'Archive uploaded'
  end

  def parent_folder
    @parent_folder ||= folder.split('/')[0..-2].join('/')
  end

  def archive_path
    @archive_path ||= "#{parent_folder}/#{archive_name}"
  end

  def remote_archive_path
    @remote_archive_path ||= "#{remote_folder}/#{archive_name}"
  end

  def archive_name
    @archive_name ||= "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}.zip"
  end

  def folder_name
    @folder_name ||= File.basename(folder)
  end

  def storage_provider
    @storage_provider ||= config[:providers][provider]
  end
end
