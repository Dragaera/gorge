# coding: utf-8

require 'config/boot'

# ['Apheriox', 'The Thirsty Onos', 'Hashtagawesome', 'Diamondgamers'].each { |n| Gorge::Server.create(name: n ) }

# server = Gorge::Server.first!(name: 'The Thirsty Onos')
# imp = Gorge::Importer::Importer.new('/home/michael/dev/ns2/wonitor-scraper/tto/tto_ns2plus_20171226.sqlite3', server: server)
# imp.import
# 
# server = Gorge::Server.first!(name: 'Hashtagawesome')
# imp = Gorge::Importer::Importer.new('/home/michael/dev/ns2/wonitor-scraper/hashtagawesome/hashtagawesome_ns2plus_20171226.sqlite3', server: server)
# imp.import
# 
# server = Gorge::Server.first!(name: 'Apheriox')
# imp = Gorge::Importer::Importer.new('/home/michael/dev/ns2/wonitor-scraper/apheriox/apheriox_ns2plus_20171226.sqlite3', server: server)
# imp.import

server = Gorge::Server.first!(name: 'Diamondgamers')
imp = Gorge::Importer::Importer.new('/home/michael/dev/ns2/wonitor-scraper/diamondgamers/diamondgamers_ns2plus_20171226.sqlite3', server: server)
imp.import
