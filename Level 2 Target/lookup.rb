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

def parse_dns(dns)
  single_rec = ""
  dns_records = {}
  dns.each do |line|
    single_rec = line.split(", ").map { |word| word.strip }
    if single_rec[0] == "A" or single_rec[0] == "CNAME"
      dns_records[single_rec[1].to_sym] = {
        :type => single_rec[0],
        :destination => single_rec[2],
      }
    end
  end
  dns_records
end

def resolve(dns_records, lookup_chain, domain)
  if dns_records[domain.to_sym] != nil
    lookup_chain.push(dns_records[domain.to_sym][:destination])

    if dns_records[domain.to_sym][:type] == "CNAME"
      resolve(dns_records, lookup_chain, dns_records[domain.to_sym][:destination])
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
