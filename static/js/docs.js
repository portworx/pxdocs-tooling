$(function () {
  /*

    style markdown components

  */
  $('.docs-content table')
    .css({
      borderCollapse: 'collapse',
    })
    .show()

  $('.docs-content table th,td')
    .css({
      padding: '10px',
      border: '1px solid #ccc'
    })

  if (EQUALIZE_TABLE_WIDTHS) {
    $('.docs-content table td')
      .css({
        width: EQUALIZE_TABLE_WIDTHS
      })
  }


  /*

    sidebar drop-downs

  */
  function setupSidebarMenu() {
    $('div[data-menu-type]').each(function () {
      var link = $(this)
      var type = link.attr('data-menu-type')
      var id = link.attr('data-menu-id')
      var url = link.attr('data-menu-url')

      var childrenContent = $('#menu-children-' + id)

      if (childrenContent.hasClass('open')) {
        link.find('.material-icons').html('keyboard_arrow_down')
      }
      else {
        link.find('.material-icons').html('keyboard_arrow_right')
      }

      link.click(function (e) {
        if (type == 'leaf') return
        e.preventDefault()
        e.stopPropagation()

        if (childrenContent.hasClass('open')) {
          childrenContent.removeClass('open')
          link.find('.material-icons').html('keyboard_arrow_right')
        }
        else {
          childrenContent.addClass('open')
          link.find('.material-icons').html('keyboard_arrow_down')
        }

      })
    })
  }

  setupSidebarMenu()

  /*

    algolia search

  */

  // This defines how many chars on either side of a match we display in the results.
  var SEARCH_HIGHLIGHT_BLEED = 40

  function getMatchIndex(text, search) {
    return text.toLowerCase().indexOf(search.toLowerCase())
  }

  // this function before we display the results, cleaning the output so that it's user-readable.
  function transformItem(item) {
    var highlightResult = item._highlightResult.content
    var searchWords = highlightResult.matchedWords

    let processedText = (highlightResult.value || '')
      .replace(/^.*?(<\w+)/, function (wholeMatch, chunk) {
        return chunk
      })
      .replace(/^.*?<\/li>/, '')

    processedText = processedText.replace(/<img .*?>/g, '')
    processedText = '<div>' + processedText + '</div>'

    let text = $(processedText).text()

    var foundTerms = {}

    var resultMatches = searchWords
      .filter(function (word) {
        return getMatchIndex(text, word) >= 0
      })
      .map(function (word) {
        var firstMatch = getMatchIndex(text, word)

        var startMatch = firstMatch - SEARCH_HIGHLIGHT_BLEED
        if (startMatch < 0) startMatch = 0

        var endMatch = firstMatch + word.length + SEARCH_HIGHLIGHT_BLEED
        if (endMatch > text.length - 1) endMatch = text.length - 1

        var textChunk = text.substring(startMatch, endMatch)

        searchWords.forEach(function (word) {
          textChunk = textChunk.replace(new RegExp(word, 'gi'), '<em>' + word + '</em>')
        })
        return '...' + textChunk + '...'
      })
      .filter(function (match) {
        var matchingChunk = match.match(/\<.*\>/)[0]
        if (!matchingChunk) return true
        if (foundTerms[matchingChunk]) return false
        foundTerms[matchingChunk] = true
        return true
      })

    if (resultMatches.length > 3) {
      resultMatches = resultMatches.slice(0, 3)
    }

    item._resultMatches = resultMatches.join('<br />')
    return item
  }

  function makeConfiguration() {
    return instantsearch.widgets.configure({
      hitsPerPage: 100,
      attributesToRetrieve: ['title', 'keywords', 'objectID', 'sectionTitles', 'url', 'sectionURL', 'content'],
      attributesToHighlight: ['title', 'keywords', 'objectID', 'sectionTitles', 'url', 'sectionURL', 'content']
    })
  }

  function makeSearchBox(containerName) {
    return instantsearch.widgets.searchBox({
      container: `#${containerName}`,
      cssClasses: {
        // hiding this temporarily. TODO: re-add and restyle the css for the search box
        // root: 'search-box-root',
        // input: 'search-box-input',
      },
      showReset: false,
      showLoadingIndicator: false,
      showSubmit: false,
      placeholder: 'Search for pages',
      templates: {
        // submit: 'submit',
        // reset: 'reset',
        // loadingIndicator: 'loading',
      },
    })
  }

  function makeHits(containerName) {
    return instantsearch.widgets.hits({
      escapeHTML: false,
      container: `#${containerName}`,
      templates: {
        empty: [
          '<div class="search-hits-empty">',
          'no results',
          '</div>',
        ].join("\n"),
        item: [
          '<div class="search-hits-row">',
          '<div class="search-hits-section">',
          '<a href="{{{sectionURL}}}" target="_blank">',
          '{{{_highlightResult.sectionTitles.value}}}',
          '</a>',
          '</div>',
          '<div class="search-hits-page">',
          '<a href="{{{url}}}"  target="_blank">',
          '{{{_highlightResult.title.value}}}',
          '</a>',
          '</div>',
          '<div class="search-hits-matches">',
          '<a href="{{{url}}}"  target="_blank">',
          '{{{_resultMatches}}}',
          '</a>',
          '</div>',
          '</div>',
        ].join("\n")
      },
      transformItems(items) {
        const newItems = items.map(item => transformItem(item))
        return newItems
      },
    })
  }

  function makeSecondaryIndex(/*indexName, hitsContainerName*/ productNameAndIndex) {
    return instantsearch.widgets
      .index({ indexName: productNameAndIndex.indexName })
      .addWidgets([
        makeConfiguration(),
        makeHits(`search-hits-${productNameAndIndex.indexName}`),
      ])
  }

  function setupAlgolia() {
    const searchClient = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_API_KEY);
    const search = instantsearch({
      routing: true,
      indexName: productNamesAndIndices[0].indexName,
      searchClient,
      searchFunction: function (helper) {
        var searchResults = $('#search-wrapper');
        if (helper.state.query === '') {
          searchResults.hide()
        }
        else {
          searchResults.show()
        }
        helper.search()
      },
    });
    search.addWidgets([
      makeConfiguration(),
      makeSearchBox('search-box'),
      makeHits(`search-hits-${productNamesAndIndices[0].indexName}`),
    ])
    for (currentIndex = 1; currentIndex < productNamesAndIndices.length; currentIndex++) {
      search.addWidgets([makeSecondaryIndex(productNamesAndIndices[currentIndex])])
    }

    search.start()

    $('#search-container').show()
    $('#search-container-holding-space').hide()

  }


  if (ALGOLIA_APP_ID && ALGOLIA_API_KEY && PRODUCT_NAMES_AND_INDICES && $('#search-box').length >= 1) {
    setupAlgolia()
  }

  $(document).keyup(function (e) {
    if ($('.ais-SearchBox-input:focus') && $('.ais-SearchBox-input').val().length > 0 && (e.keyCode === 13) && !$('#search-hits').hasClass('full-screen')) {
      $('#search-wrapper, .docs-drawer').addClass('full-screen')
      $('.docs-navigation, .version-menu, .docs-content, #scrollspy-container, .docs-footer-padding, .docs-footer').hide()
      $('.search-hits li').addClass('show-li')
      $('#search-box').prepend('<a href="#" class="full-screen__close"><i class="material-icons">close</i><br/>Close</a>')
    }
  })


  $('body').on('click', '.full-screen__close', function () {
    $('#search-wrapper, .docs-drawer').removeClass('full-screen')
    $('.search-hits li').removeClass('show-li')
    $('.docs-navigation, .version-menu, .docs-content, #scrollspy-container, .docs-footer-padding, .docs-footer').show()
    $(this).remove()
  })

  /*

    versions drop-down

  */

  function activateVersionMenu() {
    var allVersions = VERSIONS_ALL.split(',')
    allVersions.forEach(function (version) {
      var versionOption = $('<li class="mdl-menu__item">Version ' + version + '</li>')

      versionOption.click(function () {
        if (version == VERSIONS_CURRENT) return
        var url = location.protocol + '//' + version + '.' + VERSIONS_BASE_URL
        document.location = url
      })

      $('#version-menu #version-menu-options').append(versionOption)
    })
    $('#version-menu #text-button').text('Version: ' + VERSIONS_CURRENT)
  }

  if (VERSIONS_BASE_URL) {
    if (VERSIONS_CURRENT != "master") {
      activateVersionMenu()
      $('#version-menu-dropdown').css({
        visibility: 'visible'
      })
    }
  }

  /*

    scrollspy

  */

  var SCROLLSPY_FIXED_OFFSET = 170
  var SCROLLSPY_ACTIVE_BUFFER = 150
  var SCROLLSPY_HEADER_SELECTOR = "h2,h3"

  var scrollspyContainer = $('#scrollspy-container')
  var scrollspyList = $('#scrollspy-list')
  var scrollspyNav = $('#scrollspy-container nav')
  var pageContent = $('#page-content')

  var scrollWindow = $(window)

  function highlightScrollLink(id) {
    if (!id) return
    $('.scrollspy-item').removeClass('active')
    $('#scrollspy-menu-' + id.replace('#', '')).addClass('active')
  }

  var clickLinkHash = null

  function checkScrollPositions() {

    var windowScroll = scrollWindow.scrollTop()

    if (clickLinkHash) {
      clickLinkHash = null
      return
    }

    var allElements = pageContent.find(SCROLLSPY_HEADER_SELECTOR)
    var windowHeight = $(window).height()

    var elementsAboveFold = []

    for (var i = 0; i < allElements.length; i++) {
      var headerItem = allElements.eq(i)
      var headerItemPosition = headerItem.offset().top - windowScroll

      if (headerItemPosition < SCROLLSPY_ACTIVE_BUFFER) {
        elementsAboveFold.push(headerItem)
      }
    }

    var activeElement = elementsAboveFold.length > 0 ? elementsAboveFold[elementsAboveFold.length - 1] : null

    if (!activeElement) {
      $('.scrollspy-item').removeClass('active')
      return
    }

    highlightScrollLink(activeElement.attr('id'))

    const newHashId = activeElement.attr('id')
    const currentHashId = window.location.hash.replace('#', '')

    if (newHashId && newHashId != currentHashId) {

      // disable history push state for right side menu items
      if (history.pushState) {
        // history.pushState(null, null, '#' + newHashId)
      }
      else {
        // location.hash = '#' + activeElement.attr('id')
      }
    }
  }

  function setupInitialScrollPosition() {
    const currentHashId = window.location.hash.replace('#', '')
    if (!currentHashId) return
    const headerItem = $('#' + currentHashId)
    if (headerItem.length <= 0) return
    scrollWindow.scrollTop(headerItem.offset().top - 140)
  }

  scrollWindow.scroll(function () {
    checkScrollPositions()
  })

  function setupScrollspyMenu() {
    if (scrollspyContainer.length <= 0) return

    pageContent.find(SCROLLSPY_HEADER_SELECTOR).each(function () {
      var headerItem = $(this)
      var scrollItem = $('<li></li>')
      var scrollItemLink = $('<a href="#' + headerItem.attr('id') + '">' + headerItem.text() + '</a>')

      scrollItemLink.click(function (e) {
        setTimeout(function () {
          clickLinkHash = headerItem.attr('id')
          highlightScrollLink(clickLinkHash)
          scrollWindow.scrollTop(headerItem.offset().top - 140)
        })
      })

      scrollItem.append(scrollItemLink)
      scrollItem.addClass('scrollspy-item')
      scrollItem.addClass('scrollspy-' + headerItem.prop("tagName"))
      scrollItem.attr('id', 'scrollspy-menu-' + headerItem.attr('id'))
      scrollspyList.append(scrollItem)
    })

    pageContent.find("h2,h3,h4,h5,h6").each(function () {
      var headerItem = $(this)
      var headerLink = $('<a></a>')
      headerLink.attr({
        href: '#' + headerItem.attr('id')
      })
      headerItem.prepend(headerLink)
    })
  }

  setupScrollspyMenu()
  checkScrollPositions()
  setupInitialScrollPosition()

  /*

    footer padding

  */

  var footerElem = $('.docs-footer')
  var footerElemPadding = $('.docs-footer-padding')

  function checkFooterPadding() {

    footerElem.css({
      visibility: 'visible'
    })

    var footerOffset = footerElem.offset().top
    var documentHeight = scrollWindow.height()

    // give the foot a top-margin for short documents
    if (footerOffset < documentHeight) {
      var footerHeightOffset = documentHeight - footerOffset
      footerElemPadding.css({
        height: footerHeightOffset + 'px',
      })
    }
  }

  checkFooterPadding()

  /*

    copy paste

  */
  $('.highlight').each(function (i) {
    var highlightElem = $(this)
    var codeElem = highlightElem.find('pre code.language-text');
    codeElem.parent().parent().addClass('copyable');
    $(document).find('code.language-output').parent().addClass('highlight typeOutput');
    var copyDiv = $([
      '<div class="copy-link" align="right" >',
      '<button id="clipboard-icon-' + i + '" class="button">',
      '<i class="material-icons">assignment</i>',

      '</button>',
      '<div class="docs-tooltip docs-tooltip-small" for="clipboard-icon-' + i + '">',
      'copy to clipboard',
      '</div>',
      '</div>'
    ].join("\n"))

    highlightElem.prepend(copyDiv)


    copyDiv.click(function () {

      var $temp = $("<textarea>" + codeElem.text() + "</textarea>")
      $("body").append($temp)
      $temp.select()
      document.execCommand("copy")
      $temp.remove()

      copyDiv
        .find('button')
        .addClass('mdl-button--primary active').parent().addClass('active');

      setTimeout(function () {
        copyDiv
          .find('button')
          .removeClass('mdl-button--primary active').parent().removeClass('active');

      }, 1500)
    })
  })

  /*

    sidebar toggle button

  */
  var docsDrawer = $('.docs-drawer')
  function setupSidebarToggleButton() {
    $('#toggle-sidebar-button').click(function () {
      if (docsDrawer.hasClass('visible')) {
        docsDrawer.removeClass('visible')
      }
      else {
        docsDrawer.addClass('visible')
      }
    })
  }

  setupSidebarToggleButton()

  /*

    sidebar scroll

  */
  $(window).scroll(function () {
    var headerHeight = $('.docs-header').height()
    var windowHeight = $(document).height()
    var scrolledVal = $(document).scrollTop().valueOf()
    var calcDiff = headerHeight - scrolledVal
    if (scrolledVal >= headerHeight) {
      $('.docs-drawer, #search-hits').css('top', '0px')
      if ($(window).width() < 580) {
        $('#search-hits').css('top', '65px')
      }
    }
    else {
      $('.docs-drawer, #search-hits').css('top', calcDiff)
      if ($(window).width() < 580) {
        $('#search-hits').css('top', (calcDiff + 65))
      }
    }
  })

  /*

    open external links target="_blank"

  */
  $(document.links).filter(function () {
    return this.hostname != window.location.hostname
  }).attr('target', '_blank')
  /*

    full screen iframe

  */
  $('body').on('click', '.full-screen__link', function () {
    var windowHeight = $(document).height()
    var iframeHeight = windowHeight - 113
    $('.full-screen__iframe-wrap').css('height', iframeHeight)
    $('.full-screen__iframe-wrap, .full-screen__iframe__close').show()
    $('.docs-footer').hide()
  })

  $('body').on('click', '.full-screen__iframe__close', function () {
    $('.full-screen__iframe-wrap, .full-screen__iframe__close').hide()
    $('.docs-footer').show()
  })
})