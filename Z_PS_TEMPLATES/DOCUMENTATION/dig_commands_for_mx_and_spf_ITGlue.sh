
dig +short TXT agclawfirm.com | grep -i spf | pbcopy

dig +short MX agclawfirm.com | awk '{print "Priority: " $1, "Record: " $2}' | pbcopy

dig +short TXT selector._domainkey.agclawfirm.com | pbcopy

# an alias in my zsh - ex mydig agclawfirm.com
mydig() {
  domain=$1
  selector="selector" # Replace with the actual selector if known

  # SPF Record
  echo "SPF Record for $domain:"
  spf=$(dig +short TXT $domain | grep -i spf)
  echo "$spf"

  # MX Record
  echo -e "\nMX Records for $domain:"
  mx=$(dig +short MX $domain | awk '{print "Priority: " $1, "Record: " $2}')
  echo -e "$mx"

  # DKIM Record
  echo -e "\nDKIM Record for $domain with selector $selector:"
  dkim=$(dig +short TXT ${selector}._domainkey.$domain)
  echo "$dkim"

  all_results="SPF Record for $domain:\n$spf\n\nMX Records for $domain:\n$mx\n\nDKIM Record for $domain with selector $selector:\n$dkim"
  echo -e "$all_results" | pbcopy
}

