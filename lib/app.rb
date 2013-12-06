require 'jbundler'
require 'json'
require 'sinatra'
require 'sinatra/json'

java_import com.bericotech.clavin.GeoParserFactory

parser = GeoParserFactory.get_default "./tmp/index"

post '/search.json' do

  params.merge! JSON.parse(request.body.read)

  # Capitalize all terms so that they may be identified as places.
  query = params[:q].split.map(&:capitalize).join(" ")

  resolved_locations = parser.parse query

  json resolved_locations.map{|location|
    { location_name: location.location.text,
      matched_name:  location.matchedName,
      confidence:    location.confidence,
      fuzzy:         location.fuzzy,
      location: {
        id:                      location.geoname.geonameID,
        name:                    location.geoname.name,
        ascii_name:              location.geoname.asciiName,
        alternate_names:         location.geoname.alternateNames,
        latitude:                location.geoname.latitude,
        longitude:               location.geoname.longitude,
        feature_class:           location.geoname.featureClass,
        feature_code:            location.geoname.featureCode,
        primary_country_code:    location.geoname.primaryCountryCode,
        primary_country_name:    location.geoname.primaryCountryName,
        alternate_country_codes: location.geoname.alternateCountryCodes,
        admin1_code:             location.geoname.admin1Code,
        admin2_code:             location.geoname.admin2Code,
        admin3_code:             location.geoname.admin3Code,
        admin4_code:             location.geoname.admin4Code,
        population:              location.geoname.population,
        elevation:               location.geoname.elevation,
        digital_elevation_model: location.geoname.digitalElevationModel,
        timezone:                location.geoname.timezone.id,
        modification_date:       location.geoname.modificationDate}}}
end
