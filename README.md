# Cubecomps mobile

Just like http://www.cubecomps.com, but optimized for small screens!

## API included!

Want to develop your own cubecomps application? No need to
re-scrap cubecomps.com! Just use our API. You can add `.json` to any
URL and you're good to go (/ is an alias to /competitions, so you can
use /competitions.json to get the home screen)

### API examples

Get a list of competitions.

```curl http://m.cubecomps.com/competitions.json```

```
{
  "in_progress": [
    {
      "id": "1259",
      "name": "Xi'an Open"
    },
    {
      "id": "1257",
      "name": "Johannesburg Open"
    },
    ...
    {
      "id": "1261",
      "name": "Rubik La Verapaz"
    }
  ],
  "past": [
    {
      "id": "1256",
      "name": "Toronto Open Fall"
    },
    {
      "id": "1255",
      "name": "Tescup Speedcubing Open"
    },
    ...
    {
      "id": "1251",
      "name": "Florida Feast"
    }
  ],
  "upcoming": [
    {
      "id": "1212",
      "name": "Danish Special"
    },
    {
      "id": "1221",
      "name": "INABIF Open"
    },
    ...
    {
      "id": "1245",
      "name": "Open Cube Project"
    }
  ]
}
```

Past competitions returns last 10. You can GET /competitions/past.json
to get the full list of past competitions.

Get the schedule of a competition.

```curl http://m.cubecomps.com/competitions/1094/schedule.json```

```
[
  {
    "start": "2015-10-09T15:30:00+00:00",
    "end": "2015-10-09T16:00:00+00:00",
    "event_code": "reg",
    "alternate_text": "REGISTRATION",
    "round_name": null,
    "extra_info": null,
    "am_pm_format": false
  },
  {
    "start": "2015-10-09T16:00:00+00:00",
    "end": "2015-10-09T17:00:00+00:00",
    "event_code": "777",
    "alternate_text": "",
    "round_name": "Combined Final",
    "extra_info": "Cutoff 6:30",
    "am_pm_format": false
  },
  ...
  {
    "start": "2015-10-11T20:30:00+00:00",
    "end": "2015-10-11T21:00:00+00:00",
    "event_code": "tro",
    "alternate_text": "AWARDS",
    "round_name": null,
    "extra_info": null,
    "am_pm_format": false
  }
]
```

Get a list of events of a competition.

```curl http://m.cubecomps.com/competitions/1094/events.json```

```
[
  {
    "name": "Rubik's Cube",
    "rounds": [
      {
        "competition_id": "1094",
        "event_id": "1",
        "id": "1",
        "name": "First Round",
        "live": false,
        "finished": true
      },
      {
        "competition_id": "1094",
        "event_id": "1",
        "id": "2",
        "name": "Second Round",
        "live": false,
        "finished": true
      },
      {
        "competition_id": "1094",
        "event_id": "1",
        "id": "3",
        "name": "Final",
        "live": false,
        "finished": true
      }
    ]
  },
  {
    "name": "4x4x4 Cube",
    "rounds": [
      {
        "competition_id": "1094",
        "event_id": "3",
        "id": "1",
        "name": "Combined First",
        "live": false,
        "finished": true
      },
      {
        "competition_id": "1094",
        "event_id": "3",
        "id": "2",
        "name": "Second Round",
        "live": false,
        "finished": true
      },
      {
        "competition_id": "1094",
        "event_id": "3",
        "id": "3",
        "name": "Final",
        "live": false,
        "finished": true
      }
    ]
  },
  ...
  {
    "name": "Rubik's Cube: Multiple Blindfolded",
    "rounds": [
      {
        "competition_id": "1094",
        "event_id": "19",
        "id": "1",
        "name": "Final",
        "live": false,
        "finished": true
      }
    ]
  }
]
```

Get a list of results for a round.

```curl http://m.cubecomps.com/competitions/1094/events/19/rounds/1/results.json```

```
[
  {
    "position": "1",
    "top_position": true,
    "name": "Berta Garc\u00eda Parra",
    "country": "Spain",
    "competitor_id": "100",
    "t1": "10\/12\u00a057:13.00",
    "t2": "11\/12\u00a053:41.00",
    "best": "11\/12\u00a053:41.00",
    "best_record": null
  },
  {
    "position": "2",
    "top_position": true,
    "name": "Asier Cardoso S\u00e1nchez",
    "country": "Spain",
    "competitor_id": "15",
    "t1": "9\/15\u00a057:31.00",
    "t2": "11\/13\u00a050:06.00",
    "best": "11\/13\u00a050:06.00",
    "best_record": null
  },
  ...
  {
    "position": "",
    "top_position": false,
    "name": "Sergi Sabat",
    "country": "Spain",
    "competitor_id": "46",
    "t1": "\u00a0",
    "t2": "\u00a0",
    "best": "\u00a0",
    "best_record": null
  }
]
```

Get a list of competitors for a competition.

```curl http://m.cubecomps.com/competitions/1094/competitors.json```

```
[
  {
    "competition_id": "1094",
    "id": "65",
    "name": "Abel P\u00e9rez Gisbert"
  },
  {
    "competition_id": "1094",
    "id": "108",
    "name": "Adri\u00e1n Barrag\u00e1n N\u00fa\u00f1ez"
  },
  ...
  {
    "competition_id": "1094",
    "id": "48",
    "name": "Victor Sanchez Redondo"
  }
]
```

Get a list of results for a competitor.

```curl http://m.cubecomps.com/competitions/1094/competitors/43.json```

```
[
  {
    "position": "29",
    "top_position": true,
    "event": "Rubik's Cube",
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
    "event": "Rubik's Cube",
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
  {
    "position": "8",
    "top_position": false,
    "event": "Rubik's Cube: Multiple Blindfolded",
    "round": "Final",
    "event_id": "19",
    "round_id": "1",
    "t1": "DNF",
    "t2": "4\/5\u00a042:05.00",
    "t3": null,
    "t4": null,
    "t5": null,
    "average": null,
    "average_record": null,
    "mean": null,
    "mean_record": null,
    "best": "4\/5\u00a042:05.00",
    "best_record": "PB"
  }
]
```
