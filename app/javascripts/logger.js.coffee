class Logger
  INFO = 1
  WARNING = 2
  ERROR = 4
  DEBUG = 8
  ALL = INFO|WARNING|ERROR|DEBUG

  constructor: (element, loglevel = ALL) ->
    @el = element
    @loglevel = loglevel

  print: (loglevel, message) ->
    return unless @loglevel & loglevel
    listItem = document.createElement "li"
    listItem.innerHTML = message
    @el.appendChild listItem
    # scroll to bottom of list
    @el.scrollTop = @el.scrollHeight
    @

  info: (message) ->
    @print INFO, message

  warn: (message) ->
    @print WARNING, message

  error: (message) ->
    @print ERROR, message

  debug: (message) ->
    @print DEBUG, message

window.Logger = Logger

