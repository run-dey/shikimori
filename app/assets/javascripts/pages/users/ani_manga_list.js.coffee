list_cache = []
filter_timer = null
$ ->
  DEFAULT_LIST_SORT = $('.default-sort').data('value')
  $('.anime-filter .genres .collapse,.manga-filter .genres .collapse').trigger 'click', true
  get_anime_params()
  get_manga_params()
  return


# активация списка
$('.animelist, .mangalist').live 'ajax:success cache:success', (e, data) ->
  # тормозит на анимации
  $('.slide > .selected').addClass 'no-animation'
  $('.animanga-filter').hide()

  if @className.match /anime|manga/
    type = (if @className.match(/anime/) then 'anime' else 'manga')
    $(".#{type}-filter").show()

    parse_function = if type is 'anime' then get_anime_params else get_manga_params
    unless @className.match(/list/)
      mylist = $(@).parent().index() - (if type == 'anime' then 9 else 9 + 6)
      parse_function().parse "/mylist/#{mylist}/order-by/my"
    else
      if @className.match(/list/)
        parse_function().parse location.href.replace(/http:\/\/.*?\//, "/")

  apply_list_handlers()
  update_list_cache()

  # клики на фильтры по списку в начале страницы
  $(document.body).on 'click', '.ani-manga-list .link', ->
    $(@).toggleClass 'selected'
    id = $(@).data 'id'
    $(".animanga-filter:visible .mylist li.mylist-#{id}").trigger 'click'

  # фокус по инпуту фильтра по тайтлу
  $('.filter input', @).on 'focus', ->
    update_list_cache() unless list_cache.length

  # разворачивание свёрнутых блоков при фокусе на инпут
  $('.filter input', @).on 'focus', ->
    $('.collapsed', $(@).closest('.slide')).each ->
      $(@).trigger 'click' if @style.display == 'block'

  # пишут в инпуте фильтра по тайтлу
  $('.filter input', @).on 'keyup', (e) ->
    return if e.keyCode == 91 || e.keyCode == 18 || e.keyCode == 16 || e.keyCode == 17

    if filter_timer
      clearInterval filter_timer
      filter_timer = null

    filter_timer = setInterval(filter, 350)


# сортировка по клику на колонку
$('.order-control').live 'click', (e) ->
  type = $(@).data('order')
  $(".animanga-filter:visible .orders.anime-params li.order-by-#{type}").trigger 'click'

# при выборе сортировке будем ставить её в дефолтные
$('.anime-params-controls .orders li, .manga-params-controls .orders li').live 'click', ->
  DEFAULT_LIST_SORT = $(this).attr('class').match(/order-by-([\w-]+)/)[1] if IS_LOGGED_IN

# скрытие слайдов с аниме
$('.slide > div').live 'ajax:clear', (e, page) ->
  $('.animanga-filter').hide() unless page.match(/anime|manga/)

# открытие блока с редактирование записи по клику на неё
$('tr.editable').live 'ajax:success', (e, html) ->
  # прочие блоки редактирования скроем
  $another_tr_edit = $('tr.edit-form')

  $tr = $(@)
  $tr_edit = $("<tr class='edit-form'><td colspan='#{$(@).children('td').length}'>#{html}</td></tr>").insertAfter(@)
  $form = $tr_edit.find('form')
  original_height = $form.height()

  if $another_tr_edit.length
    $another_tr_edit.remove()
  else
    $form.css height: 0
    (-> $form.css height: original_height).delay()

  # отмена редактирования
  $('.cancel', $tr_edit).on 'click', ->
    $form.css height: 0
    (-> $tr_edit.remove()).delay 350

  # применение изменений в редактировании
  $form.on 'ajax:success', (e, data) ->
    $.flash notice: 'Изменения сохранены'
    $('.cancel', $tr_edit).click()

    $('.current-value[data-field=score]', $tr).html String(data.score || '0').replace(/^0$/, '–')
    $('.current-value[data-field=chapters]', $tr).html data.chapters
    $('.current-value[data-field=volumes]', $tr).html data.volumes
    $('.current-value[data-field=episodes]', $tr).html data.episodes
    $('.rate-text', $tr).html if data.text_html then "<div>#{data.text_html}</div>" else ''
    if data.rewatches > 0
      $('.rewatches', $tr).html(if data.anime then "#{data.rewatches} #{p data.rewatches, 'повторный просмотр', 'повторных просмотра', 'повторных просмотров'}" else "#{data.rewatches} #{p data.rewatches, 'повторное прочтение', 'повторных прочтения', 'повторных прочтений'}")
    else
      $('.rewatches', $tr).html ''

  # удаление из списка
  $('.remove', $form).on 'ajax:success', (e, data) ->
    $('.cancel', $tr_edit).click()
    (-> $tr.remove()).delay 250
    e.stopPropagation()

$('tr.editable').live 'click', (e) ->
  if $(@).next().hasClass 'edit-form'
    $(@).next().find('.cancel').click()
    e.stopImmediatePropagation()

# подгрузка списка аниме
$('.selected .ani-manga-list .b-postloader').live 'postloader:success', (e, $data) ->
  $header = $data.filter('header:first')

  # при подгрузке могут быть 2 случая:
  # 1. подгружается совершенно новый блок, и тогда $header будет пустым
  # 2. погружается дальнейший контент уже существующего блока, и тогда...
  if $(".ani-manga-list header.#{$header.attr 'class'}").length > 0
    # заголовок скрываем, ставим ему класс collapse-merged и collapse-ignored(чтобы раскрытие collapsed работало корректно),
    # а так же таблице ставим класс merged и скрываем её заголовок
    $header
      .addClass('collapse-merged')
      .addClass('collapse-ignored')
      .hide()
        .next()
        .addClass('collapse-merged')
          .find('tr:first,tr.border')
          .hide()

  _.delay (->
    apply_list_handlers()
    update_list_cache()
    $input = $('.selected .ani-manga-list .filter input')
    $input.trigger 'keyup' unless _.isEmpty($input.val())
  ), 250

# парсинг параметров из урла для анимелиста
get_anime_params = ->
  return arguments.callee.params if 'params' of arguments.callee
  $link = $('.slider-control-animelist a')
  return unless $link.length

  arguments.callee.params = new AnimesParamsParser($link.attr("href").replace(/^http:\/\/.*?\//, "/"), location.href, (data) ->
    return unless data.match(/anime/)
    $('.slide > .animelist').append "<div class=\"clear-marker\"></div>"
    $('.slider-control-animelist a').attr(href: data).trigger 'click'
  , $('.anime-filter'))

  arguments.callee.params

# парсинг параметров из урла для мангалиста
get_manga_params = ->
  return arguments.callee.params if 'params' of arguments.callee
  $link = $(".slider-control-mangalist a")
  return unless $link.length

  arguments.callee.params = new AnimesParamsParser($link.attr("href").replace(/^http:\/\/.*?\//, "/"), location.href, (data) ->
    return unless data.match(/manga/)
    $('.slide > .mangalist').append "<div class=\"clear-marker\"></div>"
    $('.slider-control-mangalist a').attr(href: data).trigger 'click'
  , $('.manga-filter'))

  arguments.callee.params

# фильтрация списка пользователя
filter = ->
  clearInterval filter_timer
  filter_timer = null
  $slide = $('.slide > .selected')

  # разворачивание свёрнутых элементов
  filter_value = $('.filter input', $slide).val().toLowerCase()
  $entries = $('tr.selectable', $slide)
  _(list_cache).each (block) ->
    visible = false
    i = 0

    while i < block.rows.length
      entry = block.rows[i]
      if entry.title.indexOf(filter_value) >= 0
        visible = true

        if entry.display != ''
          entry.display = ''
          entry.node.style.display = ''

      else if entry.display != 'none'
        entry.display = 'none'
        entry.node.style.display = 'none'
      i++

    block.$nodes.toggle visible  if block.toggable
    block.$only_show.show() if block.$only_show and visible
    return

  $.force_appear()

# кеширование всех строчек списка для производительности
update_list_cache = ->
  $slide = $('.slide > .selected')
  list_cache = $('table', $slide).map ->
    $table = $(@)
    rows = $table.find('tr.selectable').map(->
      node: @
      title: String($(@).data('title')).toLowerCase()
      display: @style.display
    ).toArray()
    $nodes = $table.add($table.prev(':not(.collapse-merged)'))

    # если текущая таблица подгружена пагинацией, тоесть она без заголовка, то...
    if $nodes.length is 1
      klass = $table.prev().attr('class').match(/status-\d/)[0]
      $only_show = $(".#{klass}:not(.collapse-merged)", $slide)
      $only_show = $only_show.add($only_show.next())

    $nodes: $nodes
    $only_show: $only_show
    rows: rows
    toggable: !$table.next('.b-postloader').length

# обработчики для списка
apply_list_handlers = ->
  $('.selected .ani-manga-list tr.unprocessed')
    .removeClass('unprocessed')
    .find('a.tooltipped')
    .tooltip $.extend($.extend({}, tooltip_options),
      offset: [
        -95
        10
      ]
      position: 'bottom right'
      opacity: 1
      onBeforeShow: null
      onBeforeHide: null
    )

  # изменения оценки/числа просмотренных эпизодов
  $trs = $('.selected .ani-manga-list .hoverable').off()

  $trs.off()
    .hover ->
        $current_value = $('.current-value', @)
        $new_value = $('.new-value', @)

        # если нет элемента, то создаём его
        if $new_value.length is 0
          val = parseInt $current_value.text(), 10
          val = 0 if !val && val != 0

          new_value_html = if $current_value.data('field') != 'score'
            "<span class=\"new-value\"><input type=\"text\" class=\"input\"/><span class=\"item-add\"></span></span>"
          else
            "<span class=\"new-value\"><input type=\"text\" class=\"input\"/></span>"

          $new_value = $(new_value_html)
            .children('input')
            .val(val)
            .data(counter: val, max: $current_value.data('max') || 999, min: $current_value.data('min'))
            .data(field: $current_value.data('field'), action: $current_value.closest('tr').data('rate_url'))
              .parent()
              .insertAfter($current_value)

          apply_new_value_handlers $new_value

        $new_value.show()
        $current_value.hide()
        $('.misc-value', @).hide()


      , ->
        return if $('.new-value input', @).is(":focus")
        $('.new-value', @).hide()
        $('.current-value', @).show()
        $('.misc-value', @).show()

    .on 'click', (e) ->
      # клик на плюсик обрабатываем по дефолтному
      return if e.target && e.target.className == 'item-add'
      $this = $(@)
      $this.trigger 'mouseenter'
      $('input', $this).trigger('focus').select()
      e.stopPropagation()
      false


apply_new_value_handlers = ($new_value) ->
  # обработчики для инпутов листа
  $('input', $new_value).off()
    .on 'blur', ->
      $this = $(@)
      $this.parent().parent().trigger 'mouseleave'
      @value = 0 if @value < 0
      return if (parseInt(@value, 10) or 0) is (parseInt($this.data('counter'), 10) or 0)

      $value = $this.parent().parent().find('.current-value')
      prior_value = $value.html()
      $this.data 'counter', @value
      $value.html (if $this.data('counter') == '0' then '&ndash;' else $this.data('counter'))
      $.cursorMessage()

      $.post($this.data('action'), "_method=patch&user_rate[#{$this.data 'field'}]=#{$this.attr 'value'}").success( ->
        $.hideCursorMessage()
      ).error ->
        $.hideCursorMessage()
        $value.html prior_value
        $.flash alert: 'Произошла ошибка'

    .on 'mousewheel', (e) ->
      return true unless $(@).is(':focus')

      if e.originalEvent.wheelDelta && e.originalEvent.wheelDelta > 0
        @value = Math.min (parseInt(@value, 10) + 1 or 0), parseInt($(@).data('max'), 10)

      else if e.originalEvent.wheelDelta
        @value = Math.max (parseInt(@value, 10) - 1 or 0), parseInt($(@).data('min'), 10)

      false

    .on 'keydown', (e) ->
      if e.keyCode is 38
        @value = Math.min (parseInt(@value, 10) + 1 or 0), parseInt($(@).data('max'), 10)

      else if e.keyCode is 40
        @value = Math.max (parseInt(@value, 10) - 1 or 0), parseInt($(@).data('min'), 10)

      else if e.keyCode is 27
        @value = $(@).data('counter')
        $(@).trigger 'blur'

    .on 'keypress', (e) ->
      if e.keyCode is 13
        $(@).trigger 'blur'
        e.stopPropagation()
        false

  # обработчик для плюсика у числа эпизодов/глав
  $('.item-add', $new_value).on 'click', (e) ->
    $input = $(@).prev()
    $input
      .val(parseInt($input.val(), 10) + 1)
      .triggerWithReturn('blur')
      .success(-> $input.closest('td').trigger 'mouseover')

    e.stopPropagation()
    false
