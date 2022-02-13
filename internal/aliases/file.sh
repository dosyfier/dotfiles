# Files-related shell aliases

# Converts some file's encoding from US-ASCII to UTF-8.
# $1 - The file to transform.
us_ascii_to_utf8() {
  if ! [ -f "$1" ]; then
    echo "Error! File $1 cannot be found!"

  else
    utf16_temp_file=$(mktemp)
    # shellcheck disable=SC2064
    # Expansion is expected right now, when registering the trap
    trap "rm -f $utf16_temp_file" EXIT

    # A 2-steps transformation is required since US-ASCII is simply a subset of
    # UTF-8 (i.e. iconv -f us-ascii -t utf-8 would not have any effect).
    # Hence the use of some intermediary encoding: UTF-16, which forces iconv 
    # to alter the file to handle and, in the end, to transform it into UTF-8.
    iconv -f us-ascii -t utf-16 -o "$utf16_temp_file" "$1"
    iconv -f utf-16le -t utf-8 -o "$1" "$utf16_temp_file"

    echo "Done! Conversion successful for file $1."
  fi
}
