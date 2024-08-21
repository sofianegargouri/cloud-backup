#!/usr/bin/env ruby

# frozen_string_literal: true

require 'rufus-scheduler'
require_relative './lib/config'
require_relative './lib/folder'

scheduler = Rufus::Scheduler.new

config = Config.load("#{__dir__}/config.yaml")

config[:backed_up_folders].each do |folder_data|
  puts "Scheduling #{folder_data[:folder]} for #{folder_data[:cron]}"
  scheduler.cron folder_data[:cron] do
    Folder.backup(folder_data, config)
  end
end

scheduler.join
