module GamesHelper
  SORT_OPTIONS = [
    ["Title A→Z", "title_asc"],
    ["Title Z→A", "title_desc"],
    ["Newest first", "newest"],
    ["Oldest first", "oldest"],
    ["By system", "system"]
  ].freeze

  def game_sort_options
    SORT_OPTIONS
  end
end
