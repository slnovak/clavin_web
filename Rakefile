require 'jbundler'
require 'open-uri'
require 'zip/filesystem'

require 'net/http'
require 'uri'

java_import com.bericotech.clavin.gazetteer.GeoName
java_import com.bericotech.clavin.index.WhitespaceLowerCaseAnalyzer
java_import java.io.BufferedReader
java_import java.io.FileInputStream
java_import java.io.InputStreamReader
java_import org.apache.lucene.document.Document
java_import org.apache.lucene.document.Field
java_import org.apache.lucene.document.IntField
java_import org.apache.lucene.document.LongField
java_import org.apache.lucene.document.StoredField
java_import org.apache.lucene.document.TextField
java_import org.apache.lucene.index.IndexWriter
java_import org.apache.lucene.index.IndexWriterConfig
java_import org.apache.lucene.store.FSDirectory
java_import org.apache.lucene.util.Version
 
namespace :data do
  task :download do
    Dir.mkdir("./tmp") unless File.directory?("./tmp")

    # Download the gazetteer file
    Net::HTTP.start("download.geonames.org") do |http|
      begin
        file = open("./tmp/allCountries.zip", "wb")
        http.request_get("/" + URI.encode("/export/dump/allCountries.zip")) do |response|
          response.read_body do |segment|
            file.write(segment)
          end
        end
      ensure
        file.close
      end
    end

    # Extract the gazetteer file
    Zip::File.open("./tmp/allCountries.zip") do |zipfile|
      puts zipfile.extract("allCountries.txt", "./tmp/allCountries.txt")
    end

    File.delete("./tmp/allCountries.zip")
  end
end

namespace :index do
  task :build do

    gazatteer_path = "./tmp/allCountries.txt"
    index_path = "./tmp/index"

    Dir.mkdir("./tmp") unless File.directory?("./tmp")

    if File.directory?("./tmp/index")
      abort "error: Directory '.index' exists. Please remove it before indexing"
    end

    if File.exists?(gazatteer_path)

      index_directory = FSDirectory.open java.io.File.new(index_path)

      index_analyzer = WhitespaceLowerCaseAnalyzer.new

      index_writer = IndexWriter.new(
        index_directory,
        IndexWriterConfig.new(Version::LUCENE_40, index_analyzer));

      reader = BufferedReader.new(InputStreamReader.new(
        FileInputStream.new(java.io.File.new(gazatteer_path)), "UTF-8"));

      count = 0

      while !(line = reader.read_line).nil?
        begin
          count += 1
          puts "rowcount: #{count}" if (count % 100000 == 0 )
          add_to_index index_writer, line
        rescue java.lang.Exception => ex
          puts "Skipping... Exception: #{ex.message}"
        end
      end

      [index_writer, index_directory, reader].each(&:close)

    else
      abort "error: tmp/allCountries.txt not found"
    end
  end
end

def build_doc(name, geoname_entry, geoname_id, population)
  Document.new.tap do |doc|
    doc.add(TextField.new("indexName", name, Field::Store::YES))
    doc.add(StoredField.new("geoname", geoname_entry))
    doc.add(IntField.new("geonameID", geoname_id, Field::Store::YES))
    doc.add(LongField.new("population", population, Field::Store::YES));
  end
end

def add_to_index(index_writer, geoname_entry)
  geoname = GeoName.parse_from_geo_names_record(geoname_entry)

  if geoname.name[0]
    index_writer.add_document(build_doc(
        geoname.name, 
        geoname_entry, 
        geoname.geonameID, 
        geoname.population))
  end

  if geoname.asciiName[0] && geoname.asciiName != geoname.name
    index_writer.add_document build_doc(
      geoname.asciiName,
      geoname_entry,
      geoname.geonameID,
      geoname.population)
  end

  geoname.alternateNames.each do |alt_name|
    if alt_name[0] && alt_name != geoname.name
        index_writer.add_document build_doc(
          alt_name,
          geoname_entry,
          geoname.geonameID,
          geoname.population)
    end
  end
end
