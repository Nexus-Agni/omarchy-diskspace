function humanSize(nbytes) {
  if (!nbytes || nbytes === 0) return "0 B"
  var units = ["B", "KB", "MB", "GB", "TB", "PB"]
  var i = Math.min(Math.floor(Math.log(nbytes) / Math.log(1024)), units.length - 1)
  return (nbytes / Math.pow(1024, i)).toFixed(1) + " " + units[i]
}

function parseDisks(rawStdout) {
  var lines = String(rawStdout || "").trim().split("\n")
  var disks = []
  var seen = {}

  // skip header (line 0)
  for (var i = 1; i < lines.length; i++) {
    var parts = lines[i].trim().split(/\s+/)
    if (parts.length < 6) continue

    var dev = parts[0]
    var fs = parts[1]
    var total = parseInt(parts[2], 10)
    var used = parseInt(parts[3], 10)
    var free = parseInt(parts[4], 10)
    var mount = parts.slice(5).join(" ") // in case mount path has spaces

    if (dev.indexOf("/dev/") !== 0) continue
    if (seen[dev]) continue
    seen[dev] = true

    if (isNaN(total) || isNaN(used)) continue

    var pct = total > 0 ? (used / total) * 100 : 0
    var name = dev.split("/").pop()
    if (mount === "/") name = "System"
    else if (mount === "/boot") name = "Boot"
    else if (mount.indexOf("/home") === 0) name = "Home"
    else if (mount.indexOf("/run/media/") === 0 || mount.indexOf("/mnt/") === 0) {
      var segments = mount.split("/")
      name = segments[segments.length - 1]
    }

    disks.push({
      device: dev,
      mount: mount,
      fstype: fs,
      total: total,
      used: used,
      free: free,
      percent: pct,
      name: name,
      totalStr: humanSize(total),
      usedStr: humanSize(used),
      freeStr: humanSize(free)
    })
  }
  return disks
}

function worstPercent(disks) {
  var w = 0
  for (var i = 0; i < disks.length; i++) {
    if (disks[i].percent > w) w = disks[i].percent
  }
  return w
}
