export function shouldShowClassTab(): Promise<boolean> {
  return new Promise((resolve) => {
    uni.request({
      url: 'https://api.example.com/class/status',
      timeout: 300,
      success: (resp:any)=>{
        try{ resolve(Boolean(resp?.data?.open)) }catch{ resolve(false) }
      },
      fail: ()=> resolve(false)
    })
  })
}

