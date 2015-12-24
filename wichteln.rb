# created by martin.ankerl@gmail.com
require 'json'

h = JSON.load(File.read(ARGV[0]))

require "pp"

def rules_ok(from, to, forbidden)
  ft = [from, to].transpose
  
  # check self-wichtel
  found = ft.detect { |a, b| a == b }
  return false unless found.nil?
  
  # check not allowed pairs
  in_pairs = ft.find do |a, b|
    forbidden.find do |forbidden_set|
      forbidden_set.include?(a) and forbidden_set.include?(b)
    end
  end
  return false unless in_pairs.nil?
  
  true
end

def sanity_check_ok(names, forbidden)
  # check if forbidden only contains valid names
  fn = forbidden.flatten.sort.uniq
  name_not_found = fn.find do |forbidden_name|
    not names.include?(forbidden_name)
  end
  if name_not_found
    puts "Name '#{name_not_found}' not in list of names!"
    return false
  end
  true
end

def generate(names, forbidden)
  return nil unless sanity_check_ok(names, forbidden)
  from = names
  to = names.shuffle
  num_checks = 0
  begin
    to = names.shuffle
    num_checks += 1
  end while not rules_ok(from, to, forbidden)
  [[from, to].transpose, num_checks]
end

names = h["names"]
forbidden = h["forbidden"]
total_trials = 0
1000.times do 
  wichtel, trials = generate(names, forbidden)
  total_trials += trials
end
total_trials /= 1000.0

wichtel, trials = generate(names, forbidden)
wichtel.each do |from, to|
  puts "#{from} => #{to}"
end
puts
puts "Gezogen nach #{trials} Versuchen (Durchschnittlich werden #{total_trials} Versuche benötigt)"