import httpclient, json, os, parseopt, strutils

var VERSION = "0.0.3"
var USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

proc printHelp() =
  echo "emoji_borrower " & VERSION
  echo "Steal emoji from instances using the Mastodon-compatible API,\n"
  echo "Usage: emoji_borrower [OPTION]\n"
  echo "Options:"
  echo "  -i, --instance=example.com   instance to steal emojis from (required)"
  echo "  -n, --name-includes=word     only steal emoji matching the word (optional)"  
  echo "  -v, --version                prints the version"
  echo "  -h, --help                   prints this"

proc downloadEmoji(url: string, fname: string, instance: string, http_client: HttpClient) =
  if not dirExists(instance):
    createDir(instance)

  var fname_download = instance & "/" & fname
  if not fileExists(fname_download):
    echo "Downloading " & fname & "..."
    http_client.downloadFile(url, fname_download)
  else:
    echo fname & " already exists, skipping..."

proc stealEmoji(instance: string, name_filter: string) =
  var api_url = "https://" & instance & "/api/v1/custom_emojis"
  let http_client = newHttpClient(userAgent=USER_AGENT)
  let json_node = parseJson(http_client.getContent(api_url))

  var emoji_list = jsonNode.getElems()
  for emoji in emoji_list:
    var emoji_url = emoji["url"].str
    var emoji_fname = emoji_url.split("/")[^1]

    var filter = name_filter.toLowerAscii
    if filter != "":
      var emoji_lname = emoji_fname.toLowerAscii
      if not emoji_lname.contains(filter):
        continue

    downloadEmoji(emoji_url, emoji_fname, instance, http_client)
    sleep(75)

proc parseCmdLine(cmdLine: seq) =
  echo "Grabbing list of emoji..."
  var cmdOptions = initOptParser(cmdLine)
  var arg = ""
  var instance = ""
  var name_filter = ""

  while true:
    cmdOptions.next()
    if cmdOptions.kind == cmdEnd:
      break
    elif cmdOptions.kind == cmdLongOption or cmdOptions.kind == cmdShortOption:
      arg = cmdOptions.key
      cmdOptions.next()
      if cmdOptions.kind == cmdArgument:
        if arg == "i" or arg == "instance":
          instance = cmdOptions.key
        elif arg == "n" or arg == "name-includes":
          name_filter = cmdOptions.key
      elif cmdOptions.kind == cmdEnd:
        break

  stealEmoji(instance, name_filter)

let cmdLine = commandLineParams()

if paramCount() == 0:
  printHelp()
elif cmdLine.contains("-v") or cmdLine.contains("--version"):
  echo "emoji_borrower " & VERSION
elif cmdLine.contains("-h") or cmdLine.contains("--help"):
  printhelp()
elif not cmdLine.contains("-i") and not cmdLine.contains("--instance"):
  printhelp()
else:
  parseCmdLine(cmdLine)
