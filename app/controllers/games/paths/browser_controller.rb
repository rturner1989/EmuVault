module Games
  module Paths
    class BrowserController < ApplicationController
      def show
        path = File.expand_path(params[:path].presence || "/")

        entries = Dir.entries(path)
                     .reject { |e| e.start_with?(".") }
                     .select { |e| File.directory?(File.join(path, e)) }
                     .sort
                     .map { |e| { name: e, path: File.join(path, e) } }

        render json: { path: path, entries: entries, shortcuts: shortcuts }
      rescue Errno::ENOENT
        render json: { error: t(".not_found") }, status: :unprocessable_entity
      rescue Errno::EACCES
        render json: { error: t(".permission_denied") }, status: :unprocessable_entity
      end

      private def shortcuts
        paths = []

        if File.readable?("/proc/mounts")
          File.readlines("/proc/mounts").each do |line|
            _device, mount_point, fs_type = line.split(" ")
            next unless mount_point&.start_with?("/")
            next if %w[proc sys dev run tmpfs cgroup cgroup2 mqueue shm overlay].include?(fs_type)
            next if mount_point == "/"

            paths << mount_point
          end
        end

        if paths.empty?
          candidates = [
            Dir.home,
            "/home",
            "/Users",
            "/mnt",
            "/Volumes",
            "/media"
          ]

          paths = candidates.select { |p| Dir.exist?(p) }
        end

        ([ "/" ] + paths).uniq.sort
      end
    end
  end
end
