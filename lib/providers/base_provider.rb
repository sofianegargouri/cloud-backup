# frozen_string_literal: true

module Providers
  class BaseProvider
    def self.from_hash(params)
      new(**params.symbolize_keys)
    end

    def cleanup_old_files(folder, files_count)
      files_list = list_folder_files(folder)
      sorted_files_list = files_list.sort.reverse

      if sorted_files_list.size > files_count
        files_to_delete = sorted_files_list[files_count..]
        puts "#{files_to_delete.size} files to delete"
        delete_files(files_to_delete)
      else
        puts 'No file to delete'
      end
    end
  end
end
