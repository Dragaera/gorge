# coding: utf-8

$LOAD_PATH.unshift *['.', 'lib']

require 'config/boot'

players = {
  'Las': 60458326,
  'Banana': 300172179,
}

max_nickname_length = players.keys.sort_by(&:length).last.length

data = players.map do |nick, steam_id|
  player = Gorge::Player.first!(steam_id: steam_id)
  {
    name: nick,
    steam_id: steam_id,
    kdr: player.kdr,
    accuracy: player.accuracy
  }
end

header_format_string = "%-#{ max_nickname_length + 5 }s %-5s %15s %15s %15s"
puts header_format_string % ['Player', 'KDR', 'Acc Marines', '(No Onos)', 'Acc Aliens']

format_string = "%-#{ max_nickname_length + 5 }s %-5.2f %14.0f%% %14.0f%% %14.0f%%"
data.each do |hsh|
  dt = [
    hsh[:name],
    hsh[:kdr],
    100 * hsh[:accuracy][:marine_total],
    100 * hsh[:accuracy][:marine_noonos],
    100 * hsh[:accuracy][:alien]
  ]

  puts format_string % dt
end
