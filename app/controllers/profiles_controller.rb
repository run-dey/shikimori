class ProfilesController < ShikimoriController
  before_action :fetch_resource
  before_action :set_breadcrumbs, if: -> { params[:action] != 'show' || params[:controller] != 'profile' }

  PARENT_PAGES = {
    'password' => 'account',
    'ignored_topics' => 'misc',
    'ignored_users' => 'misc'
  }

  def show
    noindex if @resource.created_at > 1.year.ago

    if user_signed_in? && current_user.id == @resource.id
      MessagesService
        .new(@resource.object)
        .read_messages(kind: MessageType::ProfileCommented)
    end
  end

  def friends
    noindex
    redirect_to @resource.url if @resource.friends.none?
    page_title i18n_t('friends')
  end

  def clubs
    noindex
    redirect_to @resource.url if @resource.clubs.none?
    page_title i18n_i('Club', :other)
  end

  def favourites
    noindex
    redirect_to @resource.url if @resource.favourites.none?
    page_title i18n_t('favorites')
  end

  def feed
    noindex

    if !@resource.show_comments? ||
        @resource.main_comments_view.comments_count.zero?
      redirect_to @resource.url
    end

    page_title i18n_t('feed')
  end

  #def stats
    #page_title 'Статистика'
  #end

  def reviews
    noindex
    collection = postload_paginate(params[:page], 5) do
      @resource.reviews.order(id: :desc)
    end

    @collection = collection.map do |review|
      topic = review.maybe_topic locale_from_host
      Topics::ReviewView.new topic, true, true
    end

    page_title i18n_t('reviews')
  end

  def comments
    noindex
    collection = postload_paginate(params[:page], 20) do
      Comment
        .where(user: @resource.object)
        .where(params[:search].present? ?
          "body ilike #{ApplicationRecord.sanitize "%#{params[:search]}%"}" :
          nil)
        .order(id: :desc)
    end
    @collection = collection.map { |v| SolitaryCommentDecorator.new v }

    page_title i18n_t('comments')
  end

  def summaries
    noindex
    collection = postload_paginate(params[:page], 20) do
      Comment
        .where(user: @resource.object, is_summary: true)
        .order(id: :desc)
    end
    @collection = collection.map { |v| SolitaryCommentDecorator.new v }

    page_title i18n_t('summaries')
  end

  def versions
    noindex
    @collection = postload_paginate(params[:page], 30) do
      @resource.versions.where.not(item_type: AnimeVideo.name).order(id: :desc)
    end
    @collection = @collection.map(&:decorate)

    page_title i18n_t('content_changes')
  end

  def video_versions
    noindex
    @collection = postload_paginate(params[:page], 30) do
      @resource.versions.where(item_type: AnimeVideo.name).order(id: :desc)
    end
    @collection = @collection.map(&:decorate)

    page_title i18n_t('video_changes')
  end

  def video_uploads
    noindex
    @collection = postload_paginate(params[:page], 30) do
      AnimeVideoReport
        .where(user: @resource.object)
        .where(kind: :uploaded)
        .includes(:user, anime_video: :author)
        .order(id: :desc)
    end

    page_title i18n_t('video_uploads')
  end

  def video_reports
    noindex
    @collection = postload_paginate(params[:page], 30) do
      AnimeVideoReport
        .where(user: @resource.object)
        .where.not(kind: :uploaded)
        .includes(:user, anime_video: :author)
        .order(id: :desc)
    end

    page_title i18n_t('video_reports')
  end

  def achievements
    page_title i18n_t('achievements')
  end

  def ban
    noindex
    @ban = Ban.new user_id: @resource.id
    page_title t('ban_history')
  end

  def edit
    authorize! :edit, @resource
    page_title t(:settings)

    if PARENT_PAGES[params[:page]]
      page_title t("profiles.page.pages.#{PARENT_PAGES[params[:page]]}")
      breadcrumb(
        t("profiles.page.pages.#{PARENT_PAGES[params[:page]]}"),
        edit_profile_url(@resource, page: PARENT_PAGES[params[:page]])
      )
    end
    page_title t("profiles.page.pages.#{params[:page]}") rescue I18n::MissingTranslation

    @page = params[:page]
    @resource.email = '' if @resource.email =~ /^generated_/ && params[:action] == 'edit'
  end

  def update
    authorize! :update, @resource

    params[:user][:avatar] = nil if params[:user][:avatar] == 'blank'
    if params[:user][:notifications].present?
      params[:user][:notifications] =
        params[:user][:notifications].to_unsafe_hash.sum {|k,v| v.to_i } +
        MessagesController::DISABLED_CHECKED_NOTIFICATIONS
    end

    if update_profile
      bypass_sign_in @resource if params[:user][:password].present?

      if params[:page] == 'account'
        @resource.ignored_users = []
        @resource.update associations_params
      end

      params[:page] = 'account' if params[:page] == 'password'
      redirect_to edit_profile_url(@resource, page: params[:page]),
        notice: t('changes_saved')
    else
      flash[:alert] = t('changes_not_saved')
      edit
      render :edit
    end
  end

private

  def fetch_resource
    nickname = User.param_to(params[:profile_id] || params[:id])
    user = User.find_by nickname: nickname

    unless user
      nickname_change = UserNicknameChange.where(value: nickname).order(:id).first

      if nickname_change
        id_key = params[:profile_id] ? :profile_id : :id
        return redirect_to url_for(url_params(id_key => nickname_change.user.to_param)), status: 301
      else
        raise NotFoundError, nickname
      end
    end

    @resource = UserProfileDecorator.new user
    @user = @resource

    raise AgeRestricted if @resource.respond_to?(:censored?) && @resource.censored? && censored_forbidden?
  end

  def set_breadcrumbs
    breadcrumb i18n_i('User', :other), users_url
    breadcrumb @resource.nickname, @resource.url

    page_title i18n_t 'profile'
    page_title (@resource || @user).nickname
  end

  def update_params
    params.require(:user).permit(
      :avatar, :nickname, :name, :location, :website,
      :sex, :birth_on, :notifications, :about, :locale,
      ignored_user_ids: [],
      preferences_attributes: [:id, :russian_names, :russian_genres],
    )
  end

  def associations_params
    params.require(:user).permit ignored_user_ids: []
  end

  def password_params
    params.required(:user).permit(:password, :current_password, :email)
  end

  def update_profile
    if params[:user][:password].present? || params[:user][:email].present?
      if @resource.encrypted_password.present?
        @resource.update_with_password password_params
      else
        @resource.update password_params.except('current_password')
      end
    else
      params = update_params[:nickname].blank? ? update_params.merge(nickname: @resource.nickname) : update_params
      @resource.update params
    end

  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
    @resource.errors.add :nickname, :taken
    false
  end
end
