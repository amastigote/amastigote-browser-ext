#noinspection SpellCheckingInspection

siteMap =
  v2ex: ['v2ex.com/', ' - V2EX']
  csdn: ['blog.csdn.net/', ' - CSDN博客']
  cnblogs: ['cnblogs.com/', ' - 博客园']
  stackoverflow: ['stackoverflow.com/', ' - Stack Overflow']
  oschina: ['oschina.net/', ' - 开源中国社区']
  freebuf: ['freebuf.com/', ' - FreeBuf.COM | 关注黑客与极客']

@removeSuffix = (url, title) ->
  keys = Object.getOwnPropertyNames(siteMap)
  for key in keys
    if url.indexOf(siteMap[key][0]) != -1
      return title.replace(siteMap[key][1], '')
  return title
