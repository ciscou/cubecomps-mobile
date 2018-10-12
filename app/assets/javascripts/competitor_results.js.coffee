$ ->
  if $("#competitor-results-region").length > 0
    competitionId = $("#competitor-results-region").data("competition-id")
    competitorId  = $("#competitor-results-region").data("competitor-id")

    Handlebars.registerHelper "formatRecord", (record) ->
      humanizedTable =
        PB: "Personal Best",
        NR: "National Record",
        CR: "Continental Record",
        WR: "World Record"
      extraClass = Handlebars.Utils.escapeExpression(record.toLowerCase())
      humanizedRecord = Handlebars.Utils.escapeExpression(humanizedTable[record] || "")

      span  = "<span class=\"record #{extraClass}\" title=\"#{humanizedRecord}\">#{record}</span>"
      new Handlebars.SafeString(span)

    Handlebars.registerHelper "joinTimes", (result) ->
      times = _.chain([result.t1, result.t2, result.t3, result.t4, result.t5])
        .compact()
        .map((t) -> t.trim())
        .compact()
        .value()

      if times.length > 0
        times.join(", ")
      else
        "-"

    CubecompsEvent = Backbone.Model.extend({})

    Events = Backbone.Collection.extend
      model: CubecompsEvent

    Result = Backbone.Model.extend({})

    Results = Backbone.Collection.extend
      model: Result
      hasT1: ->
        @any (result) -> result.has("t1")
      hasT2: ->
        @any (result) -> result.has("t2")
      hasT3: ->
        @any (result) -> result.has("t3")
      hasT4: ->
        @any (result) -> result.has("t4")
      hasT5: ->
        @any (result) -> result.has("t5")
      hasAverage: ->
        @any (result) -> result.has("average")
      hasMean: ->
        @any (result) -> result.has("mean")
      hasBest: ->
        @any (result) -> result.has("best")

    Competitor = Backbone.Model.extend
      urlRoot: -> "/api/v2/competitions/#{@get("competition_id")}/competitors"

    ResultsApp = Marionette.Application.extend
      region: "#competitor-results-region"

    ResultView = Marionette.View.extend
      template: Handlebars.compile($("#result-template").html())
      tagName: "tr"
      ui:
        moreInfoLink: "a.more-info"
      triggers:
        "click @ui.moreInfoLink": "show:more:info"
      templateContext: ->
        competition_id: @getOption("competitor").get("competition_id")
        hasT1: @getOption("results").hasT1()
        hasT2: @getOption("results").hasT2()
        hasT3: @getOption("results").hasT3()
        hasT4: @getOption("results").hasT4()
        hasT5: @getOption("results").hasT5()
        hasAverage: @getOption("results").hasAverage()
        hasMean: @getOption("results").hasMean()
        hasBest: @getOption("results").hasBest()

    ResultsView = Marionette.CollectionView.extend
      template: Handlebars.compile($("#results-template").html())
      childView: ResultView
      childViewOptions: ->
        competitor: @getOption("competitor")
        results: @collection
      childViewContainer: "tbody"
      childViewTriggers:
        "show:more:info": "show:more:info"
      collectionEvents:
        reset: "render"
      templateContext: ->
        hasT1: @collection.hasT1()
        hasT2: @collection.hasT2()
        hasT3: @collection.hasT3()
        hasT4: @collection.hasT4()
        hasT5: @collection.hasT5()
        hasAverage: @collection.hasAverage()
        hasMean: @collection.hasMean()
        hasBest: @collection.hasBest()
      table: ->
        @$("table").table()

    EventView = Marionette.View.extend
      template: Handlebars.compile($("#event-template").html())
      regions:
        results: ".results-region"
        moreInfo: ".more-info-region"

    EventsView = Marionette.CollectionView.extend
      template: false
      childView: EventView

    MoreInfoView = Marionette.View.extend
      template: Handlebars.compile($("#more-info-template").html())
      attributes:
        "data-role": "popup"
        "data-overlay-theme": "a"
      ui:
        "allResultsLinks": "a.all-results"
      events:
        "click @ui.allResultsLinks": "seeAllResults"
      templateContext: ->
        competition_id: @getOption("competitor").get("competition_id")
        hasT1: @getOption("results").hasT1()
        hasT2: @getOption("results").hasT2()
        hasT3: @getOption("results").hasT3()
        hasT4: @getOption("results").hasT4()
        hasT5: @getOption("results").hasT5()
        hasAverage: @getOption("results").hasAverage()
        hasMean: @getOption("results").hasMean()
        hasBest: @getOption("results").hasBest()
      onAttach: ->
        moreInfoView = this
        @$el.enhanceWithin()
        @$el.popup
          afterclose: -> moreInfoView.trigger("closed")
        @$el.popup("open")
      seeAllResults: (e) ->
        @close()
        window.location.href = e.target.href
      close: ->
        @$el.popup("close")

    EventEmptyView = Marionette.View.extend
      template: false
      tagName: "p"
      onAttach: ->
        @$el.text("No available results for #{@model.get("name")} (yet!)")

    setTimeout(
      -> $.mobile.loading("show")
      0
    )

    competitor = new Competitor(competition_id: competitionId, id: competitorId)
    competitor.fetch()
      .done ->
        $("h1.header-title").text(competitor.get("name"))
        $("title").text(competitor.get("name"))

        events = new Events()
        eventsView = new EventsView(collection: events)

        resultsApp = new ResultsApp()
        resultsApp.on "start", ->
          eventsView.on "add:child", (cv, iv) ->
            results = new Results(iv.model.get("results"))
            resultsView = new ResultsView(collection: results, competitor: competitor)

            resultsView.on "show:more:info", (view) ->
              moreInfoView = new MoreInfoView(model: view.model, competitor: competitor, results: results)
              window.location.hash = "#popup"
              moreInfoView.on "closed", ->
                if window.location.hash == "#popup"
                  window.history.back()
              onHashChange = ->
                if window.location.hash == ""
                  moreInfoView.close()
              window.onhashchange = onHashChange
              iv.showChildView("moreInfo", moreInfoView)

            iv.showChildView("results", resultsView)
            resultsView.table()
          resultsApp.showView(eventsView)
        resultsApp.start()

        results = competitor.get("results")
        if _.isEmpty(results)
          resultsApp.showView(new EventEmptyView(model: competitor))
        else
          events.reset(results)
      .fail ->
        alert("Failed to load results!")
      .always ->
        setTimeout(
          -> $.mobile.loading("hide")
          0
        )
