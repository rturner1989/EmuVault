export default function walk(obj) {
  if (!obj || typeof obj !== "object") return obj
  if (obj instanceof Date || obj instanceof RegExp) return obj
  if (Array.isArray(obj)) return obj.map(walk)

  return Object.keys(obj).reduce(function (acc, key) {
    const camel = key[0].toLowerCase() + key.slice(1).replace(/([A-Z]+)/g, (_m, x) => {
      return "_" + x.toLowerCase()
    })
    acc[camel] = walk(obj[key])
    return acc
  }, {})
}
