$ ->
  if $("#competitors-region").length > 0
    competitionId = $("#competitors-region").data("competition-id")

    Competitor = Backbone.Model.extend({})

    Competitors = Backbone.Collection.extend
      model: Competitor

    Competition = Backbone.Model.extend
      urlRoot: "/api/v1/competitions"

    CompetitorsApp = Marionette.Application.extend
      region: "#competitors-region"

    CompetitorView = Marionette.View.extend
      template: Handlebars.compile($("#competitor-template").html())
      tagName: "li"

    CompetitorsView = Marionette.CollectionView.extend
      template: false
      childView: CompetitorView
      filterable: ->
        @$el.filterable()
      listview: ->
        @$el.listview()

    CompetitorEmptyView = Marionette.View.extend
      template: false
      tagName: "p"
      onRender: ->
        @$el.text("No available competitors (yet!)")

    setTimeout(
      -> $.mobile.loading("show")
      0
    )

    competition = new Competition(id: competitionId)
    competition.fetch()
      .done ->
        $("h1.header-title").text(competition.get("name"))
        $("title").text(competition.get("name"))

        competitors = new Competitors()
        competitorsView = new CompetitorsView(collection: competitors)

        competitorsApp = new CompetitorsApp()
        competitorsApp.on "start", ->
          competitorsApp.showView(competitorsView)
        competitorsApp.start()

        if competition.get("competitors").length > 0
          competitors.set(competition.get("competitors"))
          competitorsView.filterable()
          competitorsView.listview()
        else
          competitorsApp.showView(new CompetitorEmptyView())
      .fail ->
        alert("Failed to load competitors!")
      .always ->
        setTimeout(
          -> $.mobile.loading("hide")
          0
        )
