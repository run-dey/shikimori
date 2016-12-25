class Import::Anime < Import::ImportBase
  SPECIAL_FIELDS = %i(
    genres studios related
  )

private

  def assign_genres genres
    ap genres
  end

  def assign_studios studios
  end

  def assign_related related
  end

  def klass
    Anime
  end
end