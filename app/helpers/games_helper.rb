module GamesHelper
  def game_sort_options
    [
      [ I18n.t("helpers.games.sort.title_asc"), "title_asc" ],
      [ I18n.t("helpers.games.sort.title_desc"), "title_desc" ],
      [ I18n.t("helpers.games.sort.newest"), "newest" ],
      [ I18n.t("helpers.games.sort.oldest"), "oldest" ],
      [ I18n.t("helpers.games.sort.system"), "system" ]
    ]
  end
end
