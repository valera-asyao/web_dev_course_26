# encoding: utf-8
#!/usr/bin/env ruby
require 'date'

if ARGV.length != 4
  puts "Неверное количество аргументов."
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
  day = str[0..1]
  month = str[3..4]
  year = str[6..9]
  return nil unless day.match?(/\A\d\d\z/) && month.match?(/\A\d\d\z/) && year.match?(/\A\d\d\d\d\z/)
  begin
    Date.new(year.to_i, month.to_i, day.to_i)
  rescue
    nil
  end
end

start_date = parse_date(start_date_str)
end_date = parse_date(end_date_str)

if start_date.nil?
  puts "Неверный формат начальной даты.."
  exit 1
end

if end_date.nil?
  puts "Неверный формат конечной даты."
  exit 1
end

if start_date > end_date
  puts "Ошибка: Начальная дата не может быть позже конечной."
  exit 1
end

teams = []
File.readlines(teams_file, encoding: 'UTF-8').each do |line|
  line = line.strip
  next if line.empty?

  dot_index = -1
  i = 0
  while i < line.length
    if line[i] == '.'
      dot_index = i
      break
    end
    break unless line[i].between?('0', '9')
    i += 1
  end

  if dot_index > 0
    if dot_index + 1 < line.length && line[dot_index + 1] == ' '
      line = line[(dot_index + 2)..]
    elsif dot_index + 1 == line.length
      line = line[0...dot_index]
    end
  end

  line = line.strip
  dash_index = line.index(' - ')
  team_name = dash_index ? line[0...dash_index].strip : line

  teams << team_name unless team_name.empty?
end

if teams.empty?
  puts "Файл с командами пустой или не содержит валидных записей."
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
  puts "В указанном диапазоне нет подходящих дней."
  exit 1
end

calendar_entries = []
eligible_slots.each_with_index do |(date, time), idx|
  team = teams[idx % teams.length]
  formatted_date = date.strftime("%d.%m.%Y")
  day_name = date.strftime("%a")
  calendar_entries << "#{formatted_date} (#{day_name}) #{time}: #{team}"
end

File.write(output_file, calendar_entries.join("\n"), encoding: 'UTF-8')

puts "Расписание успешно сгенерировано в файл: #{output_file}"