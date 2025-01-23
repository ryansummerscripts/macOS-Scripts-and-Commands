#!/bin/bash

function folder_dialog()
{
  local result=$(osascript << EOT
    tell application "Finder"
      activate
      set fpath to POSIX path of (choose folder)
      return fpath
    end tell
  EOT)

  echo "$result"
}

# Ask for folder
lib=$(folder_dialog)

if [ ! -d "$lib" ]; then
  echo "🥁 Invalid Kontakt library path"
  read -p "🎹 Press Enter to continue..."
  exit 1
fi

# Path must begin with "/Volumes"
if [[ "$lib" != /Volumes/* ]]; then
  vol=`ls -l /Volumes | grep ' -> /' | awk '{$1=""; $2=""; $3=""; $4=""; $5=""; $6=""; $7=""; $8=""; print $0}' | awk '{$1=$1};1'`
  vol=${vol/ -> \//}
  lib=/Volumes/$vol$lib
fi

xml=/var/tmp/kontaktLibraryHints.xml

find "$lib" -iname "*.nicnt" -o -iname "*_info.nkx" -type f | while read file
do
  # Extract library version (`.nicnt` only)
  cver=

  if [[ "$file" = *.nicnt ]]; then
    cver=`dd skip=66 count=10 bs=1 if="$file" 2> /dev/null | sed 's/\x00//g'`
    echo $cver | grep '\d\.\d\.\d' > /dev/null

    if [ $? -ne 0 ]; then
      cver=`dd skip=66 count=6 bs=1 if="$file" 2> /dev/null | sed 's/\x00//g'`
      echo $cver | grep '\d\.\d' > /dev/null
    fi

    [ $? -ne 0 ] && cver=
  else
    # Skip `_info.nkx` if `.nicnt` is present
    ldir=`dirname "$file"`
    hasnicnt=`ls "$ldir" | grep -i '.nicnt' | wc -l`
    if [ $hasnicnt -ne 0 ]; then
      continue
    fi
  fi

  # Extract library installation hints XML tree
  # and remove old `.plist` and `.xml` (if present) while getting its name
  awk '/<ProductHints[ >]/, $NF ~ /<\/ProductHints>/' "$file" | LC_ALL=C sed 's/<\/ProductHints>.*/<\/ProductHints>/' | xmllint --format --recover --encode "UTF-8" - > "$xml"
  name=$(xmllint --xpath "string(//Name)" "$xml")
  regkey=$(xmllint --xpath "string(//RegKey)" "$xml")
  plist="/Library/Preferences/com.native-instruments.$regkey.plist"
  xmldist="/Library/Application Support/Native Instruments/Service Center/$name.xml"

  # Check for bad `.nicnt` (improperly hand-made, unofficial)
  grep -i '<HU>' "$xml" > /dev/null
  nohu=$?
  grep -i '<JDX>' "$xml" > /dev/null
  nojdx=$?
  grep -i '<ProductSpecific>' "$xml" > /dev/null
  nops=$?

  # These encryption keys fool Kontakt into believing
  # that library is legit
  if [ $nohu -ne 0 ] && [ $nojdx -ne 0 ]; then
    cp "$xml" "$xml.tmp"
    if [ $nops -ne 0 ]; then
      cat "$xml.tmp" | sed 's/<\/SNPID>/<\/SNPID>|    <ProductSpecific>|      <HU>6C70AC13E02414D1A552685A1301D859<\/HU>|      <JDX>023733942B73318EAEAD914E3981EC68BE72519A2F5738F828A6A028C4E1DBAC<\/JDX>|      <Visibility type="Number">3<\/Visibility>|    <\/ProductSpecific>/' | tr '|' '\n' > "$xml"
    else
      cat "$xml.tmp" | sed 's/      <Visibility type="Number">/      <HU>6C70AC13E02414D1A552685A1301D859<\/HU>|      <JDX>023733942B73318EAEAD914E3981EC68BE72519A2F5738F828A6A028C4E1DBAC<\/JDX>|      <Visibility type="Number">/' | tr '|' '\n' > "$xml"
    fi
    rm -f "$xml.tmp"
  fi

  # Integrate into Service Center
  sudo mkdir -p  "/Library/Application Support/Native Instruments/Service Center"
  sudo chmod 755 "/Library/Application Support/Native Instruments/Service Center"
  sudo cp "$xml" "$xmldist"
  sudo chmod 755 "$xmldist"

  # Set `ContentDir`
  sudo rm -f "$plist"
  ContentDir=$(echo `dirname "$file"` | tr / :)
  ContentDir=${ContentDir//::/:}
  ContentDir=${ContentDir//::/:}
  sudo defaults write "$plist" ContentDir "${ContentDir#:*:}:"

  # Obtain rest of parameters from extracted XML
  for key in RegKey SNPID Name HU JDX UPID AuthSystem ; do
    val=$(xmllint --xpath "string(//$key)" "$xml")
    if [[ "$val" ]]
    then
      sudo defaults write "$plist" $key "$val"
    fi
  done

  # Write `ContentVersion`
  if [ "$cver" != "" ]; then
    sudo defaults write "$plist" ContentVersion $cver
  fi

  # Get `Visibility`
  vis=$(xmllint --xpath "string(//ProductSpecific/Visibility)" "$xml")
  sudo defaults write "$plist" Visibility -int $vis

  # Review
  cat "$xml"
  defaults read "$plist"
  rm -f "$xml"
  echo
done

echo "🎸 Have fun! 🎻"
read -p "🎹 Press Enter to continue..."
