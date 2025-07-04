#/!/bin/sh

pacs=$(expac -Qs --timefmt="%y/%m/%d" "%l|{%w}{%G}%n|%d" | \
	sort | \
	sed 's|{[^}]*}||g')

num_of_pacs=$(echo "$pacs" | wc -l)

echo "$pacs" | column -s "|" -t -o " | " -W3
printf "\nTotal: %d\n" "$num_of_pacs"
