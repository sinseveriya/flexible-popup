root = exports ? this

jQuery ($) ->

    log = (text) ->
        try
            console.log text
        catch e
            ;


    # Stack Item class, contains popup src
    class FlexiblePopupItem
        popupClass: 'popup-window'
        closeClass: 'popup-close'
        contentClass: 'popup-content'

        popupExtraClass: false
        closeExtraClass: 'sprite-close'
        content = false
        url: false

        constructor: (options) ->
            {@popupExtraClass, @closeExtraClass, @content, @url} = options

            if not flexiblePopupStack?
                log 'FlexiblePopup: [ERROR] You have to instance FlexiblePopupStack first'

            if @url

                if flexiblePopupStack.contentCache[@url]?
                    @content = flexiblePopupStack.contentCache[@url]
                else
                    $.ajax
                        url: @url
                        async: false
                        success: ((response) -> @content = response).bind @

                    flexiblePopupStack.contentCache[@url] = @content

        generate: () ->
            $popup = $('<aside>')
                .addClass @popupClass
                .addClass @popupExtraClass

            $('<i>')
                .addClass @closeClass
                .addClass @closeExtraClass
                .appendTo $popup

            $content = $('<section>')
                .addClass @contentClass
                .append $ @content
                .appendTo $popup

            $popup

        positionedInBody: ($popup) ->
            $popup
                .css
                    visibility: 'hidden'
                .appendTo 'body'

            $content = $popup.find ".#{@contentClass}"

            width = parseInt $content.outerWidth true
            width += parseInt $popup.css 'padding-left'
            width += parseInt $popup.css 'padding-right'
            minWidth = parseInt $popup.css 'min-width'
            width = width > minWidth and width or minWidth

            $popup
                .css
                    width: width
                    'margin-left': -width/2

            height = parseInt $content.outerHeight true
            height += parseInt $popup.css 'padding-top'
            height += parseInt $popup.css 'padding-bottom'
            minHeight = parseInt $popup.css 'min-height'
            height = height > minHeight and height or minHeight

            $popup
                .css
                    height: height
                    'margin-top': -height/2
                    visibility: 'visible'

            $popup.trigger 'flexiblePopupShown'


    # Stack of Popups
    class FlexiblePopupStack
        blackoutClass: 'popup-blackout'
        contentCache: {}
        stack: []

        push: (item) ->

            if @stack.length
                $ ".#{FlexiblePopupItem::popupClass}"
                    .remove()

            @stack.push item

            $popup = item.generate()
            $popup = item.positionedInBody $popup

        pop: () ->
            @stack.pop()

            $ ".#{FlexiblePopupItem::popupClass}"
                .remove()

            if not @stack.length
                $ ".#{@blackoutClass}"
                    .remove()
            else
                [..., last] = @stack
                $popup = last.generate()
                $popup = last.positionedInBody $popup


    # Handlers
    instanceStack = () ->

        if not flexiblePopupStack?
            root.flexiblePopupStack = new FlexiblePopupStack

        # blackout first
        if not flexiblePopupStack.stack.length
            $('<div>')
                .addClass flexiblePopupStack.blackoutClass
                .appendTo 'body'

        flexiblePopupStack


    jsInit = (init) ->
        stack = instanceStack()
        item = new FlexiblePopupItem init
        stack.push item


    htmlInit = () ->
        stack = instanceStack()
        init = {}
        $this = $ @

        filter = ['popupExtraClass', 'closeExtraClass', 'content', 'url',]

        for k in filter
            attr = "data-#{k}"

            if $this.attr(attr)?
                init[k] = $this.attr attr

        item = new FlexiblePopupItem init
        stack.push item


    close = () ->
        stack = instanceStack()
        stack.pop()


    serverError = () ->
        jsInit
            popupExtraClass: 'popup-error'
            content: '<h3>Ooops!</h3>
                        <p>На сервере произошла ошибка.</p>
                        <p>Простите, мы скоро исправимся!</p>
                        <footer>
                            <button class="btn popup-close">продолжить</button>
                        </footer>'


    formError = () ->
        jsInit
            popupExtraClass: 'popup-error'
            content: '<h3>Ooops!</h3>
                        <p>Вы допустили ошибку при при вводе данных.</p>
                        <p>Пропущенные поля мы выделили для Вас красным цветом.</p>
                        <footer>
                            <button class="btn popup-close">исправить</button>
                        </footer>'


    $(document).on 'click', '.popup-launcher', htmlInit
    $(document).on 'click', '.popup-close', close
    $(document).on 'formError', formError
    $(document).on 'popup', jsInit
    $(document).on 'serverError', serverError
