class CharacterProfileSerializer < CharacterSerializer
  attributes :altname, :japanese, :description, :description, :description_html
  attributes :favoured?, :thread_id

  has_many :seyu
  has_many :animes
  has_many :mangas

  def thread_id
    object.thread.id
  end
end
