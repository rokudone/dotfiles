#!/usr/bin/env ruby

if ARGV.length != 4
  puts "Usage: ruby calc.rb <年> <月> <祝日> <有休>"
  exit
end

require 'date'

year = ARGV[0].to_i
month = ARGV[1].to_i
祝日数 = ARGV[2].to_i
有休数 = ARGV[3].to_i

日数 = Date.new(year, month, -1).day.to_i
休日数 = 0
(1..Date.new(year, month, -1).day).each do |day|
  date = Date.new(year, month, day)
  休日数 += 1 if date.saturday? || date.sunday?
end
休日数 += 祝日数

所定就業日数 = 日数 - 休日数
所定労働時間 = 所定就業日数 * 8
所定外労働時間 = [(日数.to_f / 7 * 40) - 所定労働時間, 0].max
有休時間 = 有休数 * 8
時間外労働時間 = 80 + 有休時間 + 所定外労働時間 # 有休は所定労働時間としてカウントされるが、36協定には含まれない 時間外として働く必要がある

総労働時間 = 所定労働時間 + 時間外労働時間

puts "日数: #{日数}"
puts "休日数: #{休日数}"
puts "有休数: #{有休数}"
puts "所定就業日数: #{所定就業日数}"
puts "所定労働時間: #{所定労働時間}"
puts "所定外労働時間: #{所定外労働時間}"
puts "有休時間: #{有休時間}"
puts "時間外労働時間: #{時間外労働時間}"
puts "総労働時間: #{総労働時間}"

puts "平均残業時間: #{時間外労働時間.to_f / 所定就業日数}"
puts "平均労働時間: #{総労働時間.to_f / 所定就業日数}"
