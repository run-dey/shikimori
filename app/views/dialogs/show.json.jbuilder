json.content render(@collection)

if @add_postloader
  json.postloader render('blocks/postloader', filter: 'b-message',
    url: show_profile_dialog_url(@dialog.user, @dialog.target_user.to_param(true), page: @page+1),
    append_to_top: true, block_text: 'Предыдущая переписка ...')
end
