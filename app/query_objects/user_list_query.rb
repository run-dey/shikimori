class UserListQuery
  def initialize klass, user, params
    @klass = klass
    @user = user

    @params = params.merge klass: @klass, userlist: true
  end

  def fetch
    target_ids = AniMangaQuery
      .new(@klass, @params, @user)
      .fetch.except(:order).pluck(:id)
    statuses = UserRate.statuses.keys
      .each_with_object({}) { |status, memo| memo[status.to_sym] = [] }

    # закоменчено, пока не починят merge в activerecord в хз каком релизе рельс https://github.com/rails/rails/issues/12953
    user_rates#.merge(AniMangaQuery.new(@klass, @params, @user).fetch.except(:order))
      .where("#{@klass.table_name}.id in (?)", target_ids)
      .order("user_rates.status, #{AniMangaQuery.order_sql order, @klass}")
      .each_with_object(statuses) do |rate, memo|
        memo[rate.status.to_sym] ||= []
        memo[rate.status.to_sym] << rate.decorate
      end
      .delete_if { |status, rates| rates.none? }
  end

private

  def user_rates
    @user.send("#{list_type}_rates")
      .includes(list_type.to_sym)
      .references(list_type.to_sym)
  end

  def list_type
    @klass.name.downcase
  end

  def order
    @params[:order]
  end

  def anime?
    list_type == 'anime'
  end
end
