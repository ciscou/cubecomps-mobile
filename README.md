# Cubecomps mobile

Just like http://www.cubecomps.com, but optimized for small screens!

:warning: WARNING: cubecomps mobile if officialy shut down as of Feb 13th, 2020. Thanks all for taking part of this over all these years! :warning:

## API included!

Want to develop your own cubecomps application? No need to
re-scrape cubecomps.com! Just use our API.

### Get a list of competitions.

```curl https://m.cubecomps.com/api/v1/competitions```

```
{
  "in_progress": [],
  "past": [
    {
      "id": "3547",
      "name": "Cube Factory Częstochowa",
      "city": "Częstochowa - Poland",
      "date": "Sep 15-16, 2018"
    },
    {
      "id": "3546",
      "name": "KSF Semey City",
      "city": "Semey - Kazakhstan",
      "date": "Sep 15-16, 2018"
    },
    ...
    {
      "id": "3531",
      "name": "Hillsboro Open",
      "city": "Hillsboro, Oregon - United States",
      "date": "Sep 15, 2018"
    }
  ],
  "upcoming": [
    {
      "id": "3468",
      "name": "Villa Open",
      "city": "Salvador, Bahia - Brazil",
      "date": "Sep 21-22, 2018"
    },
    {
      "id": "3499",
      "name": "Swiss Nationals",
      "city": "Thun - Switzerland",
      "date": "Sep 21-23, 2018"
    },
    ...
    {
      "id": "3445",
      "name": "Manchester Open",
      "city": "Manchester - United Kingdom",
      "date": "Feb 16-17, 2019"
    }
  ]
}
```

Past competitions returns last 10. You can `GET /api/v1/competitions/past`
to get the full list of past competitions.

### Get the events, competitors and schedule of a competition.

```curl https://m.cubecomps.com/api/v1/competitions/1094```

```
{
  "name": "Spanish Championship 2015",
  "events": [
    {
      "id": "1",
      "name": "3x3x3 Cube",
      "best_record": "NR",
      "live": false,
      "finished": true,
      "rounds": [
        {
          "competition_id": "1094",
          "event_id": "1",
          "id": "1",
          "name": "First Round",
          "best_record": null,
          "live": false,
          "finished": true
        },
        ...
      ]
    },
    ...
  ],
  "competitors": [
    {
      "competition_id": "1094",
      "id": "65",
      "name": "Abel Pérez Gisbert"
    },
    {
      "competition_id": "1094",
      "id": "108",
      "name": "Adrián Barragán Núñez"
    },
    ...
    {
      "competition_id": "1094",
      "id": "48",
      "name": "Victor Sanchez Redondo"
    }
  ],
  "schedule": {
    "October  9, 2015": [
      {
        "start": "2015-10-09T15:30:00+00:00",
        "end": "2015-10-09T16:00:00+00:00",
        "formatted_start": "15:30",
        "formatted_end": "16:00",
        "event_code": "reg",
        "event_id": 21,
        "event_name": "REGISTRATION",
        "alternate_text": "REGISTRATION",
        "round_name": null,
        "round_id": 1,
        "extra_info": null,
        "am_pm_format": false,
        "round_started": true,
        "competition_id": "1094"
      },
      {
        "start": "2015-10-09T16:00:00+00:00",
        "end": "2015-10-09T17:00:00+00:00",
        "formatted_start": "16:00",
        "formatted_end": "17:00",
        "event_code": "777",
        "event_id": 6,
        "event_name": "7x7x7 Cube",
        "alternate_text": "",
        "round_name": "Combined Final",
        "round_id": 1,
        "extra_info": "Cutoff 6:30",
        "am_pm_format": false,
        "round_started": true,
        "competition_id": "1094"
      },
      ...
    ],
    ...
  }
}
```

### Get a list of results for a round.

```curl https://m.cubecomps.com/api/v1/competitions/1094/events/19/rounds/1```

```
{
  "competition_name": "Spanish Championship 2015",
  "event_name": "3x3x3 Multi-Blind",
  "round_name": "Final",
  "results": [
    {
      "position": "1",
      "top_position": true,
      "name": "Berta García Parra",
      "country": "Spain",
      "competitor_id": "100",
      "t1": "10/12 57:13.00",
      "t2": "11/12 53:41.00",
      "best": "11/12 53:41.00",
      "best_record": null
    },
    {
      "position": "2",
      "top_position": true,
      "name": "Asier Cardoso Sánchez",
      "country": "Spain",
      "competitor_id": "15",
      "t1": "9/15 57:31.00",
      "t2": "11/13 50:06.00",
      "best": "11/13 50:06.00",
      "best_record": null
    },
    ...
    {
      "position": "",
      "top_position": false,
      "name": "Sergi Sabat",
      "country": "Spain",
      "competitor_id": "46",
      "t1": " ",
      "t2": " ",
      "best": " ",
      "best_record": null
    }
  ]
}
```

### Get a list of results for a competitor.

```curl https://m.cubecomps.com/api/v1/competitions/1094/competitors/43```

```
{
  "competition_name": "Spanish Championship 2015",
  "name": "Francisco Pérez Padilla",
  "results": [
    {
      "position": "29",
      "top_position": true,
      "event": "3x3x3 Cube",
      "round": "First Round",
      "event_id": "1",
      "round_id": "1",
      "t1": "16.36",
      "t2": "13.84",
      "t3": "18.52",
      "t4": "17.70",
      "t5": "16.51",
      "average": "16.86",
      "average_record": null,
      "mean": null,
      "mean_record": null,
      "best": "13.84",
      "best_record": null
    },
    {
      "position": "43",
      "top_position": false,
      "event": "3x3x3 Cube",
      "round": "Second Round",
      "event_id": "1",
      "round_id": "2",
      "t1": "22.52",
      "t2": "17.72",
      "t3": "18.61",
      "t4": "20.90",
      "t5": "20.91",
      "average": "20.14",
      "average_record": null,
      "mean": null,
      "mean_record": null,
      "best": "17.72",
      "best_record": null
    },
    ...
  ]
}
```
