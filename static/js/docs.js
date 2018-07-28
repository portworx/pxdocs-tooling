const SCROLLSPY_FIXED_OFFSET = 200
SCROLLSPY_ACTIVE_BUFFER = 80

$(function() {
  /*
  
    style markdown components
    
  */
  $('.mdl-layout__content th,.mdl-layout__content td')
    .addClass('mdl-data-table__cell--non-numeric')
  $('.mdl-layout__content table')
    .addClass('mdl-data-table mdl-js-data-table')
    .show()
  $('.mdl-layout__content table').css({
    display: 'table',
    maxWidth: '800px',
  })
  $('.mdl-layout__content table th,td').css({
    maxWidth: '1px',
    display: 'table-cell'
  })

  /*
  
    algolia search
    
  */

  // how many chars either side of a match to display in the results
  var SEARCH_HIGHLIGHT_BLEED = 30

  function getMatchIndex(text, search) {
    return text.toLowerCase().indexOf(search.toLowerCase())
  }

  function setupAlgolia() {
    var search = instantsearch({
      appId: ALGOLIA_APP_ID,
      apiKey: ALGOLIA_API_KEY,
      indexName: ALGOLIA_INDEX_NAME,
      routing: true,
      searchParameters: {
        hitsPerPage: 5,
        attributesToRetrieve: ['title', 'objectID', 'sectionTitles', 'url', 'sectionURL', 'content'], 
        attributesToHighlight: ['title', 'objectID', 'sectionTitles', 'url', 'sectionURL', 'content'],
      },
      searchFunction: function(helper) {
        var searchResults = $('#search-hits');
        if (helper.state.query === '') {
          searchResults.hide()
        }
        else {
          searchResults.show()
        }
        helper.search()
      }
    })

    search.addWidget(
      instantsearch.widgets.searchBox({
        container: '#search-box',
        placeholder: 'Search for pages',
        cssClasses: {
          root: 'search-box-root',
          input: 'search-box-input',
        },
        reset: true,
        magnifier: true,
      })
    )

    search.addWidget(
      instantsearch.widgets.hits({
        container: '#search-hits',
        templates: {
          empty: [
            '<div class="search-hits-empty">',
                'no results',
            '</div>',
          ].join("\n"),
          item: [
            '<div class="search-hits-row">',
              '<div class="search-hits-section">',
                '<a href="{{{sectionURL}}}">',
                  '{{{_highlightResult.sectionTitles.value}}}',
                '</a>',
              '</div>',
              '<div class="search-hits-page">',
                '<a href="{{{url}}}">',
                  '{{{_highlightResult.title.value}}}',
                '</a>',
              '</div>',
              '<div class="search-hits-matches">',
                '<a href="{{{url}}}">',
                  '{{{_resultMatches}}}',
                '</a>',
              '</div>',
            '</div>',
          ].join("\n")
        },
        transformData: {
          item: function(item) {

            var highlightResult = item._highlightResult.content
            var searchWords = highlightResult.matchedWords
            var text = $(highlightResult.value).text()

            var allWords = searchWords.join(' ')

            var foundTerms = {}

            var resultMatches = searchWords
              .filter(function(word) {
                return getMatchIndex(text, word) >= 0
              })
              .map(function(word) {
                var firstMatch = getMatchIndex(text, word)
                
                var startMatch = firstMatch - SEARCH_HIGHLIGHT_BLEED
                if(startMatch < 0) startMatch = 0

                var endMatch = firstMatch + word.length + SEARCH_HIGHLIGHT_BLEED
                if(endMatch > text.length-1) endMatch = text.length-1

                var textChunk = text.substring(startMatch, endMatch)

                searchWords.forEach(function(word) {
                  textChunk = textChunk.replace(new RegExp(word, 'gi'), '<em>' + word + '</em>')
                })

                return '...' + textChunk + '...'
              })
              .filter(function(match) {
                var matchingChunk = match.match(/\<.*\>/)[0]
                if(!matchingChunk) return true
                if(foundTerms[matchingChunk]) return false
                foundTerms[matchingChunk] = true
                return true
              })

            if(resultMatches.length > 3) {
              resultMatches = resultMatches.slice(0,3)
            }

            item._resultMatches = resultMatches.join('<br />')
            return item
          },
        }
      })
    )

    search.start()

    $('#search-container').show()
    $('#search-container-holding-space').hide()
  }

  if(ALGOLIA_APP_ID && ALGOLIA_API_KEY && ALGOLIA_INDEX_NAME && $('#search-box').length >= 1) {
    setupAlgolia()
  }
  else {
    $('#search-container-holding-space').hide()
  }
  

  /*
  
    versions drop-down
    
  */

  function activateVersionMenu() {
    var allVersions = VERSIONS_ALL.split(',')
    allVersions.forEach(function(version) {
      var versionOption = $('<li class="mdl-menu__item">Version ' + version + '</li>')

      versionOption.click(function() {
        var url = location.protocol + '//' + version + '.' + VERSIONS_BASE_URL
        document.location = url
      })
      
      $('#version-menu #version-menu-options').append(versionOption)
    })
    $('#version-menu #text-button').text('Version: ' + VERSIONS_CURRENT)
    $('#version-menu').show()
    $('#version-menu-holding-space').hide()
  }

  if(VERSIONS_BASE_URL) {
    activateVersionMenu()
  }
  else {
    $('#version-menu-holding-space').hide()
  }


  /*
  
    scrollspy
    
  */
  var scrollspyContainer = $('#scrollspy-container')
  var scrollspyList = $('#scrollspy-list')
  var scrollspyNav = $('#scrollspy-container nav')
  var mainContent = $('.mdl-layout__content')
  var pageContent = $('#page-content')

  function highlightScrollLink(id) {
    if(!id) return
    $('.scrollspy-item').removeClass('active')
    $('#scrollspy-menu-' + id.replace('#', '')).addClass('active')
  }

  var clickLinkHash = null

  function checkScrollPositions() {

    if(mainContent.scrollTop() > SCROLLSPY_FIXED_OFFSET) {
      scrollspyNav.addClass('fixed') 
    }
    else {
      scrollspyNav.removeClass('fixed')  
    }

    if(clickLinkHash) {
      clickLinkHash = null
      return
    }

    var activeElement = null
    var allElements = pageContent.find("h2,h3")
    var windowHeight = $(window).height()

    allElements.each(function() {
      var headerItem = $(this)
      var headerItemOffset = headerItem.offset().top

      if(headerItemOffset < windowHeight && headerItemOffset < (SCROLLSPY_FIXED_OFFSET - SCROLLSPY_ACTIVE_BUFFER)) {
        activeElement = headerItem
      }
    })

    if(!activeElement) {
      activeElement = allElements.eq(0)
    }

    if(activeElement) {
      highlightScrollLink(activeElement.attr('id'))  
    }

    window.location.hash = ''
  }

  mainContent.scroll(function() {
    checkScrollPositions()
  })

  function setupScrollspyMenu() {
    if(scrollspyContainer.length <= 0) return
    
    pageContent.find("h2,h3").each(function() {
      var headerItem = $(this)
      var scrollItem = $('<li></li>')
      var scrollItemLink = $('<a href="#' + headerItem.attr('id') + '">' + headerItem.text() + '</a>')

      scrollItemLink.click(function() {
        clickLinkHash = headerItem.attr('id')
        highlightScrollLink(clickLinkHash)
      })

      scrollItem.append(scrollItemLink)      
      scrollItem.addClass('scrollspy-item')
      scrollItem.addClass('scrollspy-' + headerItem.prop("tagName"))
      scrollItem.attr('id', 'scrollspy-menu-' + headerItem.attr('id'))
      scrollspyList.append(scrollItem)
    })

    pageContent.find("h2,h3,h4,h5,h6").each(function() {
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

  /*
  
    copy paste
    
  */
  $('.highlight').each(function() {
    var highlightElem = $(this)
    var codeElem = highlightElem.find('pre code')
    var copyDiv = $('<div class="copy-link">copy</div>')

    highlightElem.prepend(copyDiv)

    copyDiv.click(function() {

      var $temp = $("<textarea>" + codeElem.text() + "</textarea>")
      $("body").append($temp)
      $temp.select()
      document.execCommand("copy")
      $temp.remove()

      copyDiv.addClass('active')

      setTimeout(function() {
        copyDiv.removeClass('active')
      }, 1000)
    })
  })

  /*
  
    drop down menus
    
  */
  function showDropDownMenu(menu) {
    var link = menu.parent()
    var position = link.position()
    var linkWidth = link.width()
    var menuWidth = menu.width()
    menu.css({
      left: position.left + (linkWidth/2) - (menuWidth/2),
      top: position.top + 30,
    })
    menu.show()
  }

  function setupDropDownMenus() {
    $('a[data-dropdown]').each(function() {
      var menuLink = $(this)
      var menuId = menuLink.attr('data-dropdown')
      var menu = $('#' + menuId)

      menu.click(function(e) {
        e.stopPropagation()
      })

      menuLink.click(function(e) {
        e.preventDefault()
        e.stopPropagation()

        if(menu.is(':visible')) {
          menu.hide()
        }
        else {
          $('.dropdown-menu').hide()
          showDropDownMenu(menu)
          
        }
      })
    })

    $('body').click(function() {
      $('.dropdown-menu').hide()
    })

    $(window).resize(function() {
      $('a[data-dropdown]').each(function() {
        var menuLink = $(this)
        var menuId = menuLink.attr('data-dropdown')
        var menu = $('#' + menuId)

        if(menu.is(':visible')) {
          showDropDownMenu(menu)
        }
      })
    })
  }

  setupDropDownMenus()

})