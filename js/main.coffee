---
---

# basic namespace
window.brianreed ||= {}

brianreed.home =

  init: () ->

    _t = this

    # run basic functions

    $html = $( "html" )

    @is_touch = $html.hasClass( "touch" )
    @is_phone = $html.hasClass( "phone" )

    if @is_phone or $html.hasClass( "firefox" )
      $html.addClass( "no-fixed-bkg" )
    else
      $html.addClass( "fixed-bkg" )

    # startup methods

    @startup = $.Deferred()

    $(document).ready( ->
      _t.startup.resolve()
    )

    @plugins()

    @bindings()

    @setup_waypoints()

    # remove opacity on body

    @startup.done( ->
      setTimeout ( ->
        $html.removeClass( "opaque" )
      ), 100
    )

  plugins: ->

    # bind external plugins

    _t = this

    $html = $( 'html' )

    # console fix

    window.console ||= { log: ( arg ) -> }
    console.debug = console.log if !console.debug
    
    # android chrome detector (not default for some reason)

    $html.addClass( "chrome" ) if $html.hasClass( "android" ) and navigator.userAgent.toLowerCase().match( "chrome" )

    # twitter

    @startup.done( ->
      twitterFetcher.fetch(
        "domId": "tweet_space"
        "enableLinks": true
        "id": "568995458450595841"
        "maxTweets": 1
        "showImages": true
        "showInteraction": false
        "showRetweet": false
        "showUser": false
      )
    )

    # touch/non-touch

    # if @is_touch

    #   $(document).ready ->

    #     # fast-click - removes 300ms delay on touch
    #     FastClick.attach( document.body )

    # else if not $html.hasClass( "safari" )
      
    #   # stellar for parallax - not on safari
    #   $html.addClass( "stellar" )
    #   $.stellar()

    # slideshows

    _t.activate_slideshow( "work_slideshow" )
    _t.activate_slideshow( "art_slideshow" )

  setup_waypoints: ->

    _t = this

    # set waypoints on buckets

    @waypoints = []

    $( ".bucket" ).each( ->

      _t.waypoints[ "#{ this.id }_enter" ] = new Waypoint(
        element: this
        handler: ( direction ) ->

          if direction is "down"
            bucket_id = this.element.id

          else if direction is "up"
            bucket_id = $( this.element ).prev()[ 0 ].id
          
          _t.bucket_waypoint_handler( bucket_id )

        offset: "75%"
      )

      _t.waypoints[ "#{ this.id }_title" ] = new Waypoint(
        element: this
        handler: ( direction ) ->

          bucket_id = this.element.id
          _t.title_waypoint_handler( bucket_id )
          
          this.destroy()

        offset: "10%"
      ) if this.className.match( "intro_bucket" )
    )

  title_waypoint_handler: ( bucket_id ) ->

    _t = this

    # handle waypoint events for titles

    bucket = document.getElementById( bucket_id )
    
    # mark off bucket

    unless bucket.className.match( "title_drop" )
      bucket.className += " title_drop"

  bucket_waypoint_handler: ( bucket_id ) ->

    _t = this

    # handle waypoint events for buckets

    @current_bucket = bucket_id

    bucket = document.getElementById( bucket_id )
    $html = $( "html" )
    $header = $( "#header" )
    $side_nav = $( "#side_nav" )

    # mark off bucket

    unless bucket.className.match( "viewed" )
      bucket.className += " viewed"

    # add scrolling class

    if _t.current_bucket.match( /hero_detail_bucket|footer/ )
      $header.removeClass( "scrolling" )

    else if _t.current_bucket.match( /work_intro_bucket|art_detail_bucket/ )
      $header.addClass( "scrolling" )
      
    
    # message class

    if _t.current_bucket.match( /hero_bucket/ )
      $html.removeClass( "hide_msg" )
    else
      $html.addClass( "hide_msg" )

    # set timeout for bucket checking

    setTimeout ( ->
      bucket_links() if bucket_id is _t.current_bucket
    ), 200

    # active link handling

    set_active_link = ( $link ) ->

      # remove current
      $side_nav.find( "a.active" ).removeClass( "active" )

      # add current
      if $link and not $link.hasClass( "active" )
        $link.addClass( "active" )

    bucket_links = ->

      switch _t.current_bucket

        when "hero_bucket"
          set_active_link()

          $( bucket ).removeClass( "hide_title" )

        when "hero_detail_bucket"
          set_active_link()

          $( "#hero_bucket" ).addClass( "hide_title" )

        when "work_intro_bucket"
          set_active_link( $link = $side_nav.find( "#work_link" ) )

        when "work_detail_bucket"
          set_active_link( $link = $side_nav.find( "#work_link" ) )

        when "intermission_bucket"
          set_active_link()

        when "music_intro_bucket"
          set_active_link( $link = $side_nav.find( "#music_link" ) )

        when "music_detail_bucket"
          set_active_link( $link = $side_nav.find( "#music_link" ) )

        # when "music_detail_bucket"
        when "art_intro_bucket"
          set_active_link( $link = $side_nav.find( "#art_link" ) )

        when "art_detail_bucket"
          set_active_link( $link = $side_nav.find( "#art_link" ) )

        # when "art_detail_bucket"
        when "footer"
          set_active_link()



  bindings: ->

    # bind functionality

    _t = this

    # if user scrolls down past 20px, shrink the header for design.

    $(document).scroll( ->
      window.has_scrolled = true
    )

    # bind resize

    $(window).bind( "resize", ( e ) ->
      window.has_resized = true
    )

    @site_interval = setInterval ( ->

      _t.window_has_scrolled( st = $(window).scrollTop() ) if window.has_scrolled
      _t.window_has_resized() if window.has_resized

    ), 250

    # side nav click funk

    $( "#side_nav a" ).on( "click.side_nav_click", ( e ) ->
      e.preventDefault()

      bucket = this.getAttribute( "data-bucket" )

      top_pos = $( "##{ bucket }" ).offset().top
      $( "body, html" ).animate { scrollTop: top_pos }, 250

      # ga_event_track( "Header Nav", "Click", bucket )
    )

    # work intro bucket scroll prompt

    $( "#hero_bucket #scroll_prompt" ).on( "click.scroll_prompt", ( e ) ->
      top_pos = $( "#hero_detail_bucket" ).offset().top
      $( "body, html" ).animate { scrollTop: top_pos }, 250
    )

    # tech icon list toggle

    $tech_icons_wrapper = $( "#tech_icons_wrapper" )
    $tech_icons_wrapper.on( "click.open_tech_list", "#more_tech_toggle", ( e ) ->
      $tech_icons_wrapper.toggleClass( "list_open" )
      Waypoint.refreshAll()
    )

    # slideshow lightbox

    # $( ".project_images" ).click ->
    #   alert "click"

    # footer clicks

    $( "#footer" )

      # social link clicks

      .on( "click.social_link_click", "#social_links a", ->
        link_text = $(this).text()
        # ga_event_track( "Social Link", "Click", link_text );
      )

      # credit link clicks

      .on( "click.credit_link_click", "#credits a", ->
        link_text = $(this).text()
        # ga_event_track( "Credit Link", "Click", link_text );
      )

  activate_slideshow: ( slideshow_name ) ->

    _t = this

    # run slideshow on work section

    $slideshow = $( "##{ slideshow_name }" )

    # $( "#work_intro_bucket" ).addClass( "slideshow_active" )

    width = $slideshow.width()
    height = $slideshow.find( ".art_slide" ).first().height()
    if @is_phone
      height = width
    else
      height = width * .5625

    $slideshow.slidesjs(

      phone: _t.is_phone
      height: height
      width: width

      # play:
      #   auto: true
      #   interval: 5000
      #   pauseOnHover: true
      #   restartDelay: 2500

      callback:

        loaded: ->
          $slideshow.addClass( "slideshow_loaded" )

      # navigation:
      #   active: false

      pagination:
        active: false
    )

  window_has_scrolled: ( st ) ->
    
    # reset variable

    window.has_scrolled = false

  window_has_resized: ->
    
    # reset variable

    window.has_resized = false

  utils:

    # bakery make cookies!!1

    bakery:
      create: ( name, value, days ) ->
        exp = ""
        if days
          date = new Date()
          date.setTime( date.getTime() + ( days * 24 * 60 * 60 * 1000 ) )
          exp = "; expires=#{ date.toGMTString() }"
        document.cookie = "#{ name }=#{ value }#{ exp }; path=/"

      read: ( name ) ->
        nameEQ = "#{ name }="
        ca = document.cookie.split( ';' )

        i = 0
        while i < ca.length
          c = ca[ i ]
          c = c.substring( 1, c.length ) while c.charAt( 0 ) is ' '
          return c.substring( nameEQ.length, c.length ) if c.indexOf( nameEQ ) is 0
          i++
        null

      erase: ( name ) ->
        createCookie( name, '', -1 )


