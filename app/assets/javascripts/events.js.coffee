$ ->
  if $("#events-region").length > 0
    competitionId = $("#events-region").data("competition-id")

    Handlebars.registerHelper "ifRoundIsSetup", (round, options) ->
      if round.competition_id && round.event_id && round.id
        options.fn(this)
      else
        options.inverse(this)

    Handlebars.registerHelper "eventLabels", (event) ->
      labelParts = []

      labelParts.push(event.best_record)
      labelParts.push("Live!") if event.live

      labelParts = _.compact(labelParts)

      if _.isEmpty(labelParts)
        ""
      else
        label = Handlebars.Utils.escapeExpression(labelParts.join(" | "))
        span  = "<span class=\"ui-li-count ui-body-inherit\">#{label}</span>"
        new Handlebars.SafeString(span)

    Handlebars.registerHelper "roundLabels", (round) ->
      labelParts = []

      labelParts.push(round.best_record)
      labelParts.push("Live!") if round.live
      labelParts.push("Done!") if round.finished

      labelParts = _.compact(labelParts)

      if _.isEmpty(labelParts)
        ""
      else
        label = Handlebars.Utils.escapeExpression(labelParts.join(" | "))
        span  = "<span class=\"ui-li-count\">#{label}</span>"
        new Handlebars.SafeString(span)

    CubecompsEvent = Backbone.Model.extend({})

    CubecompsEvents = Backbone.Collection.extend
      model: CubecompsEvent

    Competition = Backbone.Model.extend
      urlRoot: "/api/v1/competitions"

    EventsApp = Marionette.Application.extend
      region: "#events-region"

    EventView = Marionette.View.extend
      template: Handlebars.compile($("#event-template").html())
      id: ->
        "event-#{@model.id}"
      ui:
        listview: 'ul'
      onRender: ->
        @$el.collapsible(inset: false)
        @getUI("listview").listview()

    EventsView = Marionette.CollectionView.extend
      template: false
      childView: EventView
      collapsibleset: ->
        @$el.collapsibleset()

    EventEmptyView = Marionette.View.extend
      template: false
      tagName: "p"
      onRender: ->
        @$el.text("No available events (yet!)")

    setTimeout(
      -> $.mobile.loading("show")
      0
    )

    competition = new Competition(id: competitionId)
    competition.fetch()
      .done ->
        $("h1.header-title").text(competition.get("name"))
        $("title").text(competition.get("name"))

        events = new CubecompsEvents()
        eventsView = new EventsView(collection: events)

        eventsApp = new EventsApp()
        eventsApp.on "start", ->
          eventsApp.showView(eventsView)
        eventsApp.start()

        if competition.get("events").length > 0
          events.set(competition.get("events"))
          eventsView.collapsibleset()
        else
          eventsApp.showView(new EventEmptyView())
      .fail ->
        alert("Failed to load events!")
      .always ->
        setTimeout(
          -> $.mobile.loading("hide")
          0
        )
