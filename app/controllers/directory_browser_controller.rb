class DirectoryBrowserController < ApplicationController
  def show
    authorize! current_user

    path = File.expand_path(params[:path].presence || "/")

    entries = Dir.entries(path)
                 .reject { |e| e.start_with?(".") }
                 .select { |e| File.directory?(File.join(path, e)) }
                 .sort
                 .map { |e| { name: e, path: File.join(path, e) } }

    render json: { path: path, entries: entries, shortcuts: shortcuts }
  rescue Errno::ENOENT
    render json: { error: "Directory not found" }, status: :unprocessable_entity
  rescue Errno::EACCES
    render json: { error: "Permission denied" }, status: :unprocessable_entity
  end

  private def shortcuts
    paths = []

    # Parse /proc/mounts to find Docker bind-mounts and named volumes
    if File.readable?("/proc/mounts")
      File.readlines("/proc/mounts").each do |line|
        _device, mount_point, fs_type = line.split(" ")
        next unless mount_point&.start_with?("/")
        next if %w[proc sys dev run tmpfs cgroup cgroup2 mqueue shm overlay].include?(fs_type)
        next if mount_point == "/"

        paths << mount_point
      end
    end

    # If no interesting mounts found, fall back to common local directories
    if paths.empty?
      candidates = [
        Dir.home, # current user's home dir
        "/home", # Linux
        "/Users", # macOS
        "/mnt", # Linux external drives
        "/Volumes", # macOS external drives
        "/media" # Linux removable media
      ]

      paths = candidates.select { |p| Dir.exist?(p) }
    end

    ([ "/" ] + paths).uniq.sort
  end
end
