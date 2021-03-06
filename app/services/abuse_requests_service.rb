class AbuseRequestsService
  ABUSIVE_USERS = [
    -1
    # 5779 # Lumennes
  ]

  SUMMARY_TIMEOUT = 5.minutes
  OFFTOPIC_TIMEOUT = 5.minutes

  pattr_initialize :comment, :reporter

  def offtopic faye_token
    if allowed_offtopic_change?
      faye_service(faye_token).offtopic @comment, !@comment.offtopic?
    else
      create_abuse_request :offtopic, !@comment.offtopic?, nil
    end
  end

  def summary faye_token
    if allowed_summary_change?
      faye_service(faye_token).summary @comment, !@comment.summary?
    else
      create_abuse_request :summary, !@comment.summary?, nil
    end
  end

  def abuse reason
    create_abuse_request :abuse, true, reason
  end

  def spoiler reason
    create_abuse_request :spoiler, true, reason
  end

private

  # rubocop:disable MethodLength
  def create_abuse_request kind, value, reason
    AbuseRequest.create!(
      comment_id: @comment.id,
      user_id: reporter.id,
      kind: kind,
      value: value,
      state: 'pending',
      reason: reason
    ) unless ABUSIVE_USERS.include?(reporter.id)
    []
  rescue ActiveRecord::RecordNotUnique
    []
  end
  # rubocop:enable MethodLength

  def allowed_summary_change?
    reporter.forum_moderator? ||
      (@comment.user_id == reporter.id &&
      @comment.created_at > SUMMARY_TIMEOUT.ago)
  end

  def allowed_offtopic_change?
    reporter.forum_moderator? ||
      (@comment.user_id == reporter.id &&
      @comment.created_at > OFFTOPIC_TIMEOUT.ago)
  end

  def faye_service faye_token
    FayeService.new reporter, faye_token
  end
end
