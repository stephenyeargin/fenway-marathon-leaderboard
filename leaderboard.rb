require 'json'
require 'nokogiri'
require 'open-uri'

# Load in all participants from JSON, keyed by URL and Name
participants = JSON.parse(File.read('participants.json'))

participants.each_with_index do |row, i|
  page = Nokogiri::HTML(open(row['url']))

  #  <div id="AmountRaisedCt" class="raised box altWidgetBox">
  #  	<div class="innerBox">
  #  		<div class="attribute">
  #  			<div class="value">$5,377.00</div>
  #  			<div class="label">Currently Raised</div>
  #  		</div>
  #  	</div>
  #  </div>

  participants[i]['amount'] = page.css('#AmountRaisedCt .value').to_s.gsub(/[^\d\.]/, '').to_f
  participants[i]['count'] = page.css('.donorRoll table > tr').length
end

puts 'Rank by Amount'
puts '--------------'
participants.sort! { |a, b|  a['amount'] <=> b['amount'] }
participants.reverse.each_with_index do |row, i|
  puts "##{i+1} \t #{row['name'].ljust(30)} #{('%.2f' % row['amount']).to_s.rjust(10)} (#{row['count']})"
end

puts ''

puts 'Rank by Donors'
puts '--------------'
participants.sort! { |a, b|  a['count'] <=> b['count'] }
participants.reverse.each_with_index do |row, i|
  puts "##{i+1} \t #{row['name'].ljust(30)} #{('%.2f' % row['amount']).to_s.rjust(10)} (#{row['count']})"
end
