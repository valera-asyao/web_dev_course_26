#!/usr/bin/env ruby
require 'date'

if ARGV.length != 4
   puts "неверное число аргументов"
   exit
 end

teams_file, start_date_str, end_date_str, output_file = ARGV[0], ARGV[1], ARGV[2], ARGV[3]


unless File.exists?(teams_file) && File.readable?(teams_file)
  puts "Файл недоступен для чтения или егор не существует"
end

begin
  start_date = Date.strptime(start_date_str, "%d.%m.%Y")
  rescue
    puts "Неверный формат начальной даты"
    exit 1
  end

begin
  end_date = Date.strptime(end_date_str, "%d.%m.%Y")
  rescue
    puts "Неверный формат конечной даты"
    exit 1
  end

if start_date > end_date
  puts "Начальная дата не может быть позже конечной"
  exit 1
end

teams = []
ile.readlines(teams_file).each do |line|
  line = line.strip
  next if line.empty?

  dot_index = -1
  i = 0
  while i < line.length
    if line[i] == '.'
      dot_index = i
      break
    end
    # Пропускаем цифры в начале
    break unless line[i].between?('0', '9')
    i += 1
  end

  if dot_index > 0
    if dot_index + 1 < line.length && line[dot_index + 1] == ' '
      line = line[(dot_index + 2)..]
    elsif dot_index + 1 == line.length
      line = line[0...dot_index]
    else
    end
  end

  line = line.strip
  dash_index = line.index(' - ')
  if dash_index
    team_name = line[0...dash_index].strip
  else
    team_name = line
  end

  teams << team_name unless team_name.empty?
end

if teams.empty?
  puts "Файл с командами пуст или не содержит подходящих записей"
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
  puts "В указанном диапазоне нет подходящих дней (пятница, суббота, воскресенье)."
  exit 1
end

begin
  File.write(output_file, calendar_entries.join("\n"))

  rescue => e
    puts "Ошибка при записи в файл"
    exit 1
end

puts "Расписание составлено"
