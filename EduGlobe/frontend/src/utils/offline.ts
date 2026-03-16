export function setCache<T>(key:string, data:T){ uni.setStorageSync(key, { data, ts:Date.now() }) }
export function getCache<T>(key:string, maxAgeMs=7*24*3600*1000): T|null {
  const v = uni.getStorageSync(key); if(!v) return null
  if(Date.now()-v.ts>maxAgeMs) return null
  return v.data as T
}

