# encoding: utf-8
#!/usr/bin/env ruby
require 'date'

if ARGV.length != 4
  puts "Ошибка: Неверное количество аргументов."
  puts "Использование: ruby build_calendar.rb teams.txt начальная_дата конечная_дата выходной_файл"
  exit 1
end

teams_file = ARGV[0]
start_date_str = ARGV[1]
end_date_str = ARGV[2]
output_file = ARGV[3]

unless File.exist?(teams_file) && File.readable?(teams_file)
  puts "Ошибка: Файл с командами '#{teams_file}' не существует или недоступен для чтения."
  exit 1
end

def parse_date(str)
  return nil unless str.length == 10 && str[2] == '.' && str[5] == '.'
  day_s, month_s, year_s = str[0..1], str[3..4], str[6..9]
  [day_s, month_s, year_s].each do |part|
    part.each_char { |c| return nil unless c >= '0' && c <= '9' }
  end
  day, month, year = day_s.to_i, month_s.to_i, year_s.to_i
  return nil if day < 1 || day > 31 || month < 1 || month > 12
  begin
    Date.new(year, month, day)
  rescue
    nil
  end
end

start_date = parse_date(start_date_str)
end_date = parse_date(end_date_str)

if start_date.nil? || end_date.nil? || start_date > end_date
  puts "Ошибка: Неверный формат или порядок дат."
  exit 1
end

teams = []
File.readlines(teams_file, encoding: 'UTF-8').each do |line|
  line = line.strip
  next if line.empty?

  i = 0
  while i < line.length && line[i] >= '0' && line[i] <= '9'
    i += 1
  end
  if i < line.length && line[i] == '.'
    rest_start = i + 1
    rest_start += 1 if rest_start < line.length && line[rest_start] == ' '
    content = line[rest_start..]
  else
    content = line
  end

  content = content.strip
  next if content.empty?

  sep_index = content.index(' — ')
  team_name = sep_index ? content[0...sep_index].strip : content
  teams << team_name unless team_name.empty?
end

if teams.empty?
  puts "Ошибка: Не удалось загрузить ни одной команды."
  exit 1
end

if teams.length < 2
  puts "Ошибка: Для проведения матчей требуется минимум 2 команды."
  exit 1
end

eligible_slots = []
current = start_date
while current <= end_date
  wday = current.wday
  if wday == 5 || wday == 6 || wday == 0
    eligible_slots << [current, "12:00"]
    eligible_slots << [current, "15:00"]
  end
  current += 1
end

if eligible_slots.empty?
  puts "Ошибка: В указанном диапазоне нет подходящих дней (пятница, суббота, воскресенье)."
  exit 1
end

matches = []
team_count = teams.length
match_index = 0

eligible_slots.each do |date, time|
  team1 = teams[match_index % team_count]
  team2 = teams[(match_index + 1) % team_count]

  if team1 == team2
    team2 = teams[(match_index + 2) % team_count]
  end

  matches << [date, time, team1, team2]
  match_index += 2 
end

calendar_lines = matches.map do |date, time, t1, t2|
  formatted_date = date.strftime("%d.%m.%Y")
  day_name = date.strftime("%a")
  "#{formatted_date} (#{day_name}) #{time}: #{t1} vs #{t2}"
end

File.write(output_file, calendar_lines.join("\n"), encoding: 'UTF-8')


puts "Команд: #{teams.length}"
puts "Слоты: #{eligible_slots.length}"
puts "Матчей: #{matches.length}"
puts "Результат записан в: #{output_file}"