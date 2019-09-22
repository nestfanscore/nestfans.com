#= require jquery2
#= require popper
#= require bootstrap
#= require jquery_ujs
#= require jquery.mobile-events
#= require underscore
#= require backbone
#= require pagination
#= require jquery.timeago
#= require jquery.timeago.settings
#= require jquery.hotkeys
#= require jquery.autogrow-textarea
#= require tooltipster.bundle.min
#= require dropzone
#= require jquery.fluidbox.min
#= require social-share-button
#= require social-share-button/wechat
#= require jquery.atwho
#= require emoji-data
#= require emoji-modal
#= require notifier
#= require action_cable
#= require form_storage
#= require topics
#= require editor
#= require toc
#= require turbolinks
#= require google_analytics
#= require gt
#= require jquery.infinitescroll.min
#= require d3.min
#= require cal-heatmap.min
#= require_self

AppView = Backbone.View.extend
  el: "body"
  repliesPerPage: 50
  windowInActive: true

  events:
    "click a.likeable": "likeable"
    "click .header .form-search .btn-search": "openHeaderSearchBox"
    "click .header .form-search .btn-close": "closeHeaderSearchBox"
    "click a.button-block-user": "blockUser"
    "click a.button-follow-user": "followUser"
    "click a.button-block-node": "blockNode"
    "click a.rucaptcha-image-box": "reLoadRucaptchaImage"
    # "click .email-code-btn-outline": "sendEmailCode"

  initialize: ->
    FormStorage.restore()
    @initForDesktopView()
    @initComponents()
    @initScrollEvent()
    @initInfiniteScroll()
    @initCable()
    @restoreHeaderSearchBox()
    @initGtSdk()
    @initInvite()

    if $('body').data('controller-name') in ['topics', 'replies']
      window._topicView = new TopicView({parentView: @})

    window._tocView = new TOCView({parentView: @})

  initComponents: () ->
    $("abbr.timeago").timeago()
    $(".alert").alert()
    $('.dropdown-toggle').dropdown()
    $('[data-toggle="tooltip"]').tooltip()

    # 绑定评论框 Ctrl+Enter 提交事件
    $(".cell_comments_new textarea").unbind "keydown"
    $(".cell_comments_new textarea").bind "keydown", "ctrl+return", (el) ->
      if $(el.target).val().trim().length > 0
        $(el.target).parent().parent().submit()
      return false

    $(window).off "blur.inactive focus.inactive"
    $(window).on "blur.inactive focus.inactive", @updateWindowActiveState

    # Likeable Popover
    $('a.likeable[data-count!=0]').tooltipster
      content: "Loading..."
      theme: 'tooltipster-shadow'
      side: 'bottom'
      maxWidth: 230
      interactive: true
      contentAsHTML: true
      triggerClose:
        mouseleave: true
      functionBefore: (instance, helper) ->
        $target = $(helper.origin)
        if $target.data('remote-loaded') is 1
          return

        likeable_type = $target.data("type")
        likeable_id = $target.data("id")
        data =
          type: likeable_type
          id: likeable_id
        $.ajax
          url: '/likes'
          data: data
          success: (html) ->
            if html.length is 0
              $target.data('remote-loaded', 1)
              instance.hide()
              instance.destroy()
            else
              instance.content(html)
              $target.data('remote-loaded', 1)

  initForDesktopView : () ->
    return if App.mobile != false
    $("a[rel=twipsy]").tooltip()

    # CommentAble @ 回复功能
    App.mentionable(".cell_comments_new textarea")

  likeable : (e) ->
    if !App.isLogined()
      location.href = "/account/sign_in"
      return false

    $target = $(e.currentTarget)
    likeable_type = $target.data("type")
    likeable_id = $target.data("id")
    likes_count = parseInt($target.data("count"))

    $el = $(".likeable[data-type='#{likeable_type}'][data-id='#{likeable_id}']")

    if $el.data("state") != "active"
      $.ajax
        url : "/likes"
        type : "POST"
        data :
          type : likeable_type
          id : likeable_id

      likes_count += 1
      $el.data('count', likes_count)
      @likeableAsLiked($el)
    else
      $.ajax
        url : "/likes/#{likeable_id}"
        type : "DELETE"
        data :
          type : likeable_type
      if likes_count > 0
        likes_count -= 1
      $el.data("state","").data('count', likes_count).attr("title", "").removeClass("active")
      if likes_count == 0
        $('span', $el).text("")
      else
        $('span', $el).text("#{likes_count} 个赞")
    $el.data("remote-loaded", 0)
    false

  likeableAsLiked : (el) ->
    likes_count = el.data("count")
    el.data("state","active").attr("title", "取消赞").addClass("active")
    $('span',el).text("#{likes_count} 个赞")

  initCable: () ->
    if !window.notificationChannel && App.isLogined()
      window.notificationChannel = App.cable.subscriptions.create "NotificationsChannel",
        connected: ->
          @subscribe()

        received: (data) =>
          @receivedNotificationCount(data)

        subscribe: ->
          @perform 'subscribed'

  receivedNotificationCount : (json) ->
    # console.log 'receivedNotificationCount', json
    span = $(".notification-count span")
    link = $(".notification-count a")
    new_title = document.title.replace(/^\(\d+\) /,'')
    if json.count > 0
      span.show()
      new_title = "(#{json.count}) #{new_title}"
      url = App.fixUrlDash("#{App.root_url}#{json.content_path}")
      $.notifier.notify("",json.title,json.content,url)
      link.addClass("new")
    else
      span.hide()
      link.removeClass("new")
    span.text(json.count)
    document.title = new_title

  restoreHeaderSearchBox: ->
    $searchInput = $(".header .form-search input")

    if location.pathname != "/search"
      $searchInput.val("")
    else
      results = new RegExp('[\?&]q=([^&#]*)').exec(window.location.href)
      q = results && decodeURIComponent(results[1])
      $searchInput.val(q)

  openHeaderSearchBox: (e) ->
    $(".header .form-search").addClass("active")
    $(".header .form-search input").focus()
    return false

  closeHeaderSearchBox: (e) ->
    $(".header .form-search input").val("")
    $(".header .form-search").removeClass("active")
    return false

  followUser: (e) ->
    btn = $(e.currentTarget)
    userId = btn.data("id")
    span = btn.find("span")
    followerCounter = $(".follow-info .followers[data-login=#{userId}] .counter")
    if btn.hasClass("active")
      $.ajax
        url: "/#{userId}/unfollow"
        type: "POST"
        success: (res) ->
          if res.code == 0
            btn.removeClass('active')
            span.text("关注")
            followerCounter.text(res.data.followers_count)
    else
      $.ajax
        url: "/#{userId}/follow"
        type: 'POST'
        success: (res) ->
          if res.code == 0
            btn.addClass('active').attr("title", "")
            span.text("取消关注")
            followerCounter.text(res.data.followers_count)
    return false

  blockUser: (e) ->
    btn = $(e.currentTarget)
    userId = btn.data("id")
    span = btn.find("span")
    if btn.hasClass("active")
      $.post("/#{userId}/unblock")
      btn.removeClass('active').attr("title", "忽略后，社区首页列表将不会显示此用户发布的内容。")
      span.text("屏蔽")
    else
      $.post("/#{userId}/block")
      btn.addClass('active').attr("title", "")
      span.text("取消屏蔽")
    return false

  blockNode: (e) ->
    btn = $(e.currentTarget)
    nodeId = btn.data("id")
    span = btn.find("span")
    if btn.hasClass("active")
      $.post("/nodes/#{nodeId}/unblock")
      btn.removeClass('active').attr("title", "忽略后，社区首页列表将不会显示这里的内容。")
      span.text("忽略节点")
    else
      $.post("/nodes/#{nodeId}/block")
      btn.addClass('active').attr("title", "")
      span.text("取消屏蔽")
    return false

  reLoadRucaptchaImage: (e) ->
    btn = $(e.currentTarget)
    img = btn.find('img:first')
    currentSrc = img.attr('src')
    img.attr('src', currentSrc.split('?')[0] + '?' + (new Date()).getTime())
    return false

  sendEmailCode: () ->
    $('#new_user .alert').remove()
    email = $('#user_email').val()
    pattern = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
    # domains = ["126.com", "foxmail.com", "qq.com", "163.com","vip.163.com","263.net","yeah.net","sohu.com","sina.cn","sina.com","eyou.com","gmail.com","hotmail.com","42du.cn"]

    if pattern.test(email) == false
      $('#new_user').prepend "<div class='alert alert-block alert-danger'>\n<a class='close' data-dismiss='alert' href='#''>×<\/a>\n<div><strong>请先输入正确的邮箱地址<\/strong><\/div><\/div>\n"
      return

    $.post "/application/send_email_verification_code",
      email: email

    downTime = 60
    btn = $('#send-email-code-btn')
    textBackup = btn.text()
    addDownText = (downTime) ->
      btn.text downTime + ' 秒后重试'
      return

    btn.attr 'disabled', true
    addDownText downTime

    interval = setInterval((->
      if downTime == 0
        clearInterval interval
        btn.attr 'disabled', false
        btn.text textBackup
      else
        downTime = downTime - 1
        addDownText downTime
      return
    ), 1000)

  gtHandler: (captchaObj) ->
    captchaObj.onReady(->
      $('#wait').hide()
      return
    ).onSuccess ->
      result = captchaObj.getValidate()
      if !result
        return alert('请完成验证')
      email = $('#user_email').val()
      $.ajax
        url: '/geetest/validate'
        type: 'POST'
        dataType: 'json'
        data:
          geetest_challenge: result.geetest_challenge
          geetest_validate: result.geetest_validate
          geetest_seccode: result.geetest_seccode
          geetest_key: email
        success: (data) ->
          if data.status == 'success'
              console.log email
              $.post "/application/send_email_verification_code",
                email: email

              downTime = 60
              btn = $('#send-email-code-btn')
              textBackup = btn.text()
              addDownText = (downTime) ->
                btn.text downTime + ' 秒后重试'
                return

              
              btn.attr 'disabled', true
              addDownText downTime

              interval = setInterval((->
                if downTime == 0
                  clearInterval interval
                  btn.attr 'disabled', false
                  btn.text textBackup
                else
                  downTime = downTime - 1
                  addDownText downTime
                return
              ), 1000)
          else if data.status == 'fail'
            setTimeout (->
              captchaObj.reset()
              return
            ), 1500
          return
      return
    $('.email-code-btn-outline').click ->
      $('#new_user .alert').remove()
      email = $('#user_email').val()
      pattern = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/
      # domains = ["126.com", "foxmail.com", "qq.com", "163.com","vip.163.com","263.net","yeah.net","sohu.com","sina.cn","sina.com","eyou.com","gmail.com","hotmail.com","42du.cn"]

      if pattern.test(email) == false
        $('#new_user').prepend "<div class='alert alert-block alert-danger'>\n<a class='close' data-dismiss='alert' href='#''>×<\/a>\n<div><strong>请先输入正确的邮箱地址<\/strong><\/div><\/div>\n"
        return
      captchaObj.verify()
      return
    # 更多前端接口说明请参见：http://docs.geetest.com/install/client/web-front/
    return

  initGtSdk: ->
    gtHandler = @gtHandler
    $.ajax
      url: '/geetest/preprocess?t=' + (new Date).getTime()
      type: 'get'
      dataType: 'json'
      success: (data) ->
        console.log data
        initGeetest {
          gt: data.gt
          challenge: data.challenge
          new_captcha: data.new_captcha
          offline: !data.success
          product: 'bind'
          timeout: '3000'
          width: '300px'
          https: true
        }, gtHandler
        return
  
  initInvite: ->
    getUrlParam = (name) ->
      reg = new RegExp('(^|&)' + name + '=([^&]*)(&|$)')
      r = window.location.search.substr(1).match(reg)

      if r != null
        return unescape(r[2])
      null

    location = window.location
    if location.pathname == "/account/sign_up"
      invite_code = getUrlParam("invite")

      if invite_code
        $('#user_invite_by').val(invite_code)

  updateWindowActiveState: (e) ->
    prevType = $(this).data("prevType")

    if prevType != e.type
      switch (e.type)
        when "blur"
          @windowInActive = false
        when "focus"
          @windowInActive = true

    $(this).data("prevType", e.type)

  initInfiniteScroll: ->
    $('.infinite-scroll .item-list').infinitescroll
      nextSelector: '.pagination .next a'
      navSelector: '.pagination'
      itemSelector: '.topic, .notification-group'
      extraScrollPx: 200
      bufferPx: 50
      localMode: true
      loading:
        finishedMsg: '<div style="text-align: center; padding: 5px;">已到末尾</div>'
        msgText: '<div style="text-align: center; padding: 5px;">载入中...</div>'
        img: 'data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=='

  initScrollEvent: ->
    $(window).off('scroll.navbar-fixed')
    $(window).on('scroll.navbar-fixed', @toggleNavbarFixed)
    @toggleNavbarFixed()

  toggleNavbarFixed: (e) ->
    top = $(window).scrollTop()
    if top >= 50
      $(".header.navbar").addClass('navbar-fixed-active')
    else
      $(".header.navbar").removeClass('navbar-fixed-active')

    return if $(".navbar-topic-title").length == 0
    if top >= 50
      $(".header.navbar").addClass('fixed-title')
    else
      $(".header.navbar").removeClass('fixed-title')


window.App =
  turbolinks: false
  mobile: false
  locale: 'zh-CN'
  notifier : null
  current_user_id: null
  access_token : ''
  asset_url : ''
  twemoji_url: 'https://twemoji.maxcdn.com/'
  root_url : ''
  cable: ActionCable.createConsumer()

  isLogined : ->
    document.getElementsByName('current-user').length > 0

  loading : () ->
    console.log "loading..."

  fixUrlDash : (url) ->
    url.replace(/\/\//g,"/").replace(/:\//,"://")

  # 警告信息显示, to 显示在那个 DOM 前 (可以用 css selector)
  alert : (msg, to) ->
    $(".alert").remove()
    html = "<div class='alert alert-warning'><button class='close' data-dismiss='alert'><span aria-hidden='true'>&times;</span></button>#{msg}</div>"
    if to
      $(to).before(html)
    else
      $("#main").prepend(html)

  # 成功信息显示, to 显示在那个 DOM 前 (可以用 css selector)
  notice : (msg, to) ->
    $(".alert").remove()
    html = "<div class='alert alert-success'><button class='close' data-dismiss='alert'><span aria-hidden='true'>&times;</span></button>#{msg}</div>"
    if to
      $(to).before(html)
    else
      $("#main").prepend(html)

  openUrl : (url) ->
    window.open(url)

  # Use this method to redirect so that it can be stubbed in test
  gotoUrl: (url) ->
    Turbolinks.visit(url)

  # scan logins in jQuery collection and returns as a object,
  # which key is login, and value is the name.
  scanMentionableLogins: (query) ->
    result = []
    logins = []
    for e in query
      $e = $(e)
      item =
        login: $e.find(".user-name").first().text()
        name: $e.find(".user-name").first().attr('data-name')
        avatar_url: $e.find(".avatar img").first().attr("src")

      continue if not item.login
      continue if not item.name
      continue if logins.indexOf(item.login) != -1

      logins.push(item.login)
      result.push(item)

    console.log result
    _.uniq(result)

  mentionable : (el, logins) ->
    logins = [] if !logins
    $(el).atwho
      at : "@"
      limit: 8
      searchKey: 'login'
      callbacks:
        filter: (query, data, searchKey) ->
          return data
        sorter: (query, items, searchKey) ->
          return items
        remoteFilter: (query, callback) ->
          r = new RegExp("^#{query}")
          # 过滤出本地匹配的数据
          localMatches = _.filter logins, (u) ->
            return r.test(u.login) || r.test(u.name)
          # Remote 匹配
          $.getJSON '/search/users.json', { q: query }, (data) ->
            # 本地的排前面
            for u in localMatches
              data.unshift(u)
            # 去重复
            data = _.uniq data, false, (item) ->
              return item.login;
            # 限制数量
            data = _.first(data, 8)
            callback(data)
      displayTpl : "<li data-value='${login}'><img src='${avatar_url}' height='20' width='20'/> ${login} <small>${name}</small></li>"
      insertTpl : "@${login}"
    .atwho
      at : ":"
      limit: 8
      searchKey: 'code'
      data : window.EMOJI_LIST
      displayTpl : "<li data-value='${code}'><img src='#{App.twemoji_url}/svg/${url}.svg' class='twemoji' /> ${code} </li>"
      insertTpl: "${code}"
    true


document.addEventListener 'turbolinks:load',  ->
  window._appView = new AppView()

document.addEventListener 'turbolinks:click', (event) ->
  if event.target.getAttribute('href').charAt(0) is '#'
    event.preventDefault()

FormStorage.init()
