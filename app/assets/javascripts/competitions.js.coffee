$ ->
  if $("#competitions-region").length > 0
    allPast = $("#competitions-region").hasClass("past")

    Competition = Backbone.Model.extend({})

    Competitions = Backbone.Collection.extend
      model: Competition

    Homepage = Backbone.Model.extend
      url: ->
        if allPast
          "/api/v1/competitions/past"
        else
          "/api/v1/competitions"

    CompetitionsApp = Marionette.Application.extend
      region: "#competitions-region"

    CompetitionView = Marionette.View.extend
      template: Handlebars.compile($("#competition-template").html())
      tagName: "li"

    CompetitionEmptyView = Marionette.View.extend
      template: Handlebars.compile($("#competition-empty-template").html())
      tagName: "li"

    CompetitionPastLinkView = Marionette.View.extend
      template: Handlebars.compile($("#competition-past-link-template").html())
      tagName: "li"

    CompetitionPastLinkView = Marionette.View.extend
      template: Handlebars.compile($("#competition-past-link-template").html())
      tagName: "li"

    CompetitionSeparatorView = Marionette.View.extend
      template: Handlebars.compile($("#competition-separator-template").html())
      tagName: "li"
      attributes:
        "data-role": "list-divider"

    CompetitionsView = Marionette.CollectionView.extend
      template: false
      tagName: "ul"
      childView: (model) ->
        switch model.id
          when "past-link"
            CompetitionPastLinkView
          when "in-progress-empty", "past-empty", "upcoming-empty"
            CompetitionEmptyView
          when "in-progress-separator", "past-separator", "upcoming-separator"
            CompetitionSeparatorView
          else
            CompetitionView
      filterable: ->
        @$el.filterable()
      listview: ->
        @$el.listview()

    setTimeout(
      -> $.mobile.loading("show")
      0
    )

    homepage = new Homepage()
    homepage.fetch()
      .done ->
        competitions = new Competitions()
        competitionsView = new CompetitionsView(collection: competitions)

        competitionsApp = new CompetitionsApp()
        competitionsApp.on "start", ->
          competitionsApp.showView(competitionsView)
        competitionsApp.start()

        in_progress = homepage.get("in_progress")
        past        = homepage.get("past")
        upcoming    = homepage.get("upcoming")

        unless allPast
          competitions.add(new Competition(id: "in-progress-separator", name: "Competitions in progress"))
          if in_progress.length > 0
            competitions.add(in_progress)
          else
            competitions.add(new Competition(id: "in-progress-empty", name: "No competitions in progress (yet!)"))

        competitions.add(new Competition(id: "past-separator", name: "Past competitions"))
        if past.length > 0
          competitions.add(past)
          competitions.add(new Competition(id: "past-link", name: "See more past competitions..."))
        else
          competitions.add(new Competition(id: "past-empty", name: "No past competitions (yet!)"))

        unless allPast
          competitions.add(new Competition(id: "upcoming-separator", name: "Upcoming competitions"))
          if upcoming.length > 0
            competitions.add(upcoming)
          else
            competitions.add(new Competition(id: "upcoming-empty", name: "No upcoming competitions (yet!)"))

        competitionsView.filterable() if allPast
        competitionsView.listview()
      .fail ->
        alert("Failed to load competitions!")
      .always ->
        setTimeout(
          -> $.mobile.loading("hide")
          0
        )
