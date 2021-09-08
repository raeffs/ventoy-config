
$root = $PSScriptRoot
$source = "$($root)\src\ventoy"
$destination = "$($root)\ventoy"
$images = "$($root)\boot-images"

$config = Get-Content "$($source)\ventoy.json" | ConvertFrom-Json
$menuAliasDefinitions = Get-Content "$($root)\src\menu-alias.json" | ConvertFrom-Json

# copy to destination
Copy-Item -Path "$($source)\*" -Destination $destination -Recurse -Force

$menuAlias = @()

# create alias for images as ventoy does not support any pattern matching
Get-ChildItem $images -Recurse -File | ForEach-Object {
  $current = $_

  $menuAliasDefinitions | ? { $current.Name -match $_.pattern } | ForEach-Object {
    $alias = $current.Name -replace $_.pattern, $_.alias
    $path = (Resolve-Path $current.FullName -Relative) -replace "\\", "/" -replace "\./", "/"
    $properties = @{ image = $path; alias = $alias }
    $menuAlias += New-Object psobject -Property $properties
  }
}

$config.menu_alias += $menuAlias

$config | ConvertTo-Json | Out-File "$($destination)\ventoy.json" -Encoding utf8NoBOM
