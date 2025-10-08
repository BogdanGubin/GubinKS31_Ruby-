
# c **/*" без "*"

require 'json'

files = Dir.glob("C:/Users/Губин/OneDrive/Рабочий стол/12/**/*") 
scannedfiles = files.count { |f| File.file?(f) }
paths = []
savedifdedup_bytes = 0
sizebytes = 0

keywords = ["copy", "COPY", "копия"]
files.each do |x|
  sizebytes += File.stat(x).size
  if ( keywords.any? { |word| x.include?(word) })
      paths  << x
  end
end

paths.each do |i| savedifdedup_bytes += File.stat(i).size end

duplicates = {
  "scanned_files": scannedfiles,
  "groups": [
    {
      "size_bytes": sizebytes,
      "saved_if_dedup_bytes": savedifdedup_bytes,
      "files":  paths
    }
  ]
}

File.write("duplicates.json", JSON.pretty_generate(duplicates))
