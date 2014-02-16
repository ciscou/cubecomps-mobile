class LandscapeModeHint
  constructor: ->
    @popup = $("#landscape-mode-hint")
    if @popup.length
      @open()
      @bindCloseButton()

  open: ->
    if localStorage?
      unless localStorage.getItem("hideLandscapeModeHint")
        @popup.popup("open")

  bindCloseButton: ->
    @popup.find(".close").on "click", (e) ->
      localStorage?.setItem("hideLandscapeModeHint", "true")

$(document).on "pageinit", ->
  setTimeout (-> new LandscapeModeHint), 1000
