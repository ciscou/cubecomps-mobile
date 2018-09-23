$ ->
  if $("#round-results-region").length > 0
    competitionId = $("#round-results-region").data("competition-id")
    eventId       = $("#round-results-region").data("event-id")
    roundId       = $("#round-results-region").data("round-id")

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
      times = _([result.t1, result.t2, result.t3, result.t4, result.t5])
        .compact()

      if times.length > 0
        times.join(", ")
      else
        "-"

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

    Round = Backbone.Model.extend
      urlRoot: -> "/api/v1/competitions/#{@get("competition_id")}/events/#{@get("event_id")}/rounds"

    ResultsApp = Marionette.Application.extend
      region: "#round-results-region"

    ResultView = Marionette.View.extend
      template: Handlebars.compile($("#result-template").html())
      tagName: "tr"
      ui:
        moreInfoLink: "a.more-info"
      triggers:
        "click @ui.moreInfoLink": "show:more:info"
      templateContext: ->
        competition_id: @getOption("round").get("competition_id")
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
        round: @getOption("round")
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

    RoundView = Marionette.View.extend
      template: Handlebars.compile($("#round-template").html())
      regions:
        results: ".results-region"
        moreInfo: ".more-info-region"

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
        competition_id: @getOption("round").get("competition_id")
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

    setTimeout(
      -> $.mobile.loading("show")
      0
    )

    round = new Round(competition_id: competitionId, event_id: eventId, id: roundId)
    round.fetch()
      .done ->
        $("h1.header-title").text(round.get("competition_name"))
        $("title").text(round.get("competition_name"))

        results = new Results()
        roundView = new RoundView(model: round)
        resultsView = new ResultsView(collection: results, round: round)

        resultsView.on "show:more:info", (view) ->
          moreInfoView = new MoreInfoView(model: view.model, round: round, results: results)
          window.location.hash = "#popup"
          moreInfoView.on "closed", ->
            if window.location.hash == "#popup"
              window.history.back()
          onHashChange = ->
            if window.location.hash == ""
              moreInfoView.close()
          window.onhashchange = onHashChange
          roundView.showChildView("moreInfo", moreInfoView)

        resultsApp = new ResultsApp()
        resultsApp.on "start", ->
          roundView.on "render", ->
            roundView.showChildView("results", resultsView)
          resultsApp.showView(roundView)
        resultsApp.start()

        results.reset(round.get("results"))
        resultsView.table()
      .fail ->
        alert("Failed to load results!")
      .always ->
        setTimeout(
          -> $.mobile.loading("hide")
          0
        )
