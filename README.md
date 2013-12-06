## CLAVIN_web: A lightweight API for CLAVIN

### Overview

[CLAVIN](https://github.com/Berico-Technologies/CLAVIN) is an open-source software package that performs geoparsing on documents. CLAVIN_web is a Sinatra-based web application that provides a web-based API into CLAVIN. Simply submit POST requests to `/search.json` with `{"q": "my text"}` in the body of the request, you you will receive a response similar to:

```
[
    {
        "location_name": "Washington",
        "matched_name": "Washington",
        "confidence": 1,
        "fuzzy": false,
        "location": {
            "id": 5815135,
            "name": "Washington",
            "ascii_name": "Washington",
            "alternate_names": "[Estado de Washington, Etat de Washington, Evergreen State, Hƿæsingatūn, Ipinle Washington, Ouasin'nkton, Shtat Vashyngton, ...]",
            "latitude": 47.50012,
            "longitude": -120.50147,
            "feature_class": "A",
            "feature_code": "ADM1",
            "primary_country_code": "US",
            "primary_country_name": "United States",
            "alternate_country_codes": "[]",
            "admin1_code": "WA",
            "admin2_code": "",
            "admin3_code": "",
            "admin4_code": "",
            "population": 6271775,
            "elevation": 555,
            "digital_elevation_model": 553,
            "timezone": "America/Los_Angeles",
            "modification_date": "Thu Aug 25 00:00:00 EDT 2011"
        }
    }
]
```

### Requirements

* JRuby 1.7.4 via [rbenv](https://github.com/sstephenson/rbenv)

### Installation

* `git clone git@github.com:slnovak/clavin_web.git`
* `cd clavin_web`
* `bundle install --path=vendor && bundle exec jbundle install`

### Starting the application server

Prior to starting up the web server, you need to download a gazatteer dataset and index it:

* `bundle exec rake data:download`
* `bundle exec rake index:build`

Once that's done, you can start the application server via:

* `bundle exec rackup`

You can test out the api by running:

`curl -XPOST http://127.0.0.1:9292/search.json -d '{"q": "Washington"}'`

