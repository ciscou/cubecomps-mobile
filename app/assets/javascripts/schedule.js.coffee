$ ->
  if $("#schedule-region").length > 0
    competitionId = $("#schedule-region").data("competition-id")

    ScheduleDay = Backbone.Model.extend({})

    ScheduleDays = Backbone.Collection.extend
      model: ScheduleDay

    Competition = Backbone.Model.extend
      urlRoot: "/api/v1/competitions"

    ScheduleApp = Marionette.Application.extend
      region: "#schedule-region"

    ScheduleDayView = Marionette.CollectionView.extend
      template: Handlebars.compile($("#schedule-day-template").html())

    ScheduleDaysView = Marionette.CollectionView.extend
      template: false
      childView: ScheduleDayView
      table: ->
        @$("table").table()

    setTimeout(
      -> $.mobile.loading("show")
      0
    )

    competition = new Competition(id: competitionId)
    competition.fetch()
      .done ->
        $("h1.header-title").text(competition.get("name"))
        $("title").text(competition.get("name"))

        scheduleDays = new ScheduleDays()
        scheduleDaysView = new ScheduleDaysView(collection: scheduleDays)

        scheduleApp = new ScheduleApp()
        scheduleApp.on "start", ->
          scheduleApp.showView(scheduleDaysView)
        scheduleApp.start()

        schedule = competition.get("schedule")
        _.each _.keys(schedule), (key) ->
          scheduleDays.add(day: key, rows: schedule[key])

        scheduleDaysView.table()
      .fail ->
        alert("Failed to load schedule!")
      .always ->
        setTimeout(
          -> $.mobile.loading("hide")
          0
        )
