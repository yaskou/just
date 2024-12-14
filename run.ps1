param($saveDir='.\data')

$sources = @( #バックアップされるフォルダ
  '/storage/self/primary/Pictures/Screenshots/',
  '/storage/self/primary/Pictures/Instagram/',
  '/storage/self/primary/DCIM/Camera/'
)

if (-not (Test-Path $saveDir)) { #保存先のフォルダが存在しなければ作る
  mkdir $saveDir
}

$devices = adb devices | #オンラインのデバイスを取得
  Select-Object -Skip 1 |
  Where-Object { $_ -match 'device' } |
  ForEach-Object { ($_ -split 'device')[0].Trim() }

$devices | #デバイス毎に保存用フォルダを作成
  Where-Object { (Test-Path (Join-Path $saveDir $_)) -ne $true } |
  ForEach-Object { mkdir (Join-Path $saveDir $_) }

foreach ($device in $devices) {
  foreach ($source in $sources) {
    adb -s $device shell ls $source |
      Where-Object { (Test-Path (Join-Path $saveDir $device $_)) -ne $true } |
      ForEach-Object { #ファイルがコピーされていないなら作成
        adb -s $device pull ($source + $_) (Join-Path $saveDir $device)
      }
  }
}
