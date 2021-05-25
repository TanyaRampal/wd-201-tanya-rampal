def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(raw)
  raw.reject { |line|
    line.empty?
  }.map { |line|
    line.strip.split(", ")
  }.reject do |record|
    record[0] != "A" && record[0] != "CNAME"
  end
    .each_with_object({}) do |record, records|
    records[record[1].to_sym] = {
      :type => record[0],
      :destination => record[2],
    }
  end
end

def resolve(dns_records, lookup_chain, domain)
  user_domain = domain.to_sym
  if dns_records[user_domain] != nil
    lookup_chain.push(dns_records[user_domain][:destination])

    if dns_records[user_domain][:type] == "CNAME"
      resolve(dns_records, lookup_chain, dns_records[user_domain][:destination])
    end
  else
    lookup_chain = ["Error: record not found for #{domain}"]
  end
  lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
