
$osCaption = gwmi win32_operatingsystem | % caption

# This is the default lock screen folder, which is all we're guaranteed to have out of the box
$sourcepath = "\\srv3\lockscreen$\"

# Find a random image file from the directory
$formats = @("*.jpg","*.png")
$sourcefile = gci "$sourcepath\*" -include $formats -recurse | Get-Random -Count 1 | % Name

$sourcebg = $sourcepath + $sourcefile


$newImagePath = "C:\windows\web\" + "bginfo-" + $sourcefile
$finalImagePath = "C:\windows\web\" + "bginfoR-" + $sourcefile

# Consider this our failsafe image, which we're going to force via GPO
$defaultImagePath = "C:\windows\web\default.jpg"

# Figure out how large the system display is
Add-Type -AssemblyName System.Windows.Forms
$res = [System.Windows.Forms.Screen]::AllScreens | Where-Object {$_.Primary -eq 'True'} | Select-Object Bounds
if (($res -split ',')[3].Substring(10,1) -match '}') {$heightend = 3}
else {$heightend = 4}
$displaywidth = ($res -split ',')[2].Substring(6)
$screenheight = ($res -split ',')[3].Substring(7,$heightend)
$displayheight = $screenheight

# Here's where things get ugly. With some systems, the startup resolution is not our actual display resolution.
# In this case we seem to have 1024x768 as the returned resolution. There's no good way to deal with this, so
# we're going to check for a file created by the login script which should explicitly tell us the resolution.


#Load System.Drawing assembly
[Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

##########################
#[void][System.Reflection.Assembly]::LoadWithPartialName(&quot;System.Drawing&quot;)
$bmpOriginal = [System.Drawing.Image]::FromFile($sourcebg)
 
#hardcoded canvas size...
$canvasWidth = $displaywidth
$canvasHeight = $displayheight
 
#Encoder parameter for image quality
$myEncoder = [System.Drawing.Imaging.Encoder]::Quality
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myEncoder, 100) # Max Quality
# get codec
$myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|where {$_.MimeType -eq 'image/jpeg'}
 
#compute the final ratio to use
$ratioX = $canvasWidth / $bmpOriginal.Width;
$ratioY = $canvasHeight / $bmpOriginal.Height;
$ratio = $ratioY
if($ratioX -gt $ratioY){
$ratio = $ratioX
}

$textvertstart = 20
$texthorstart = 10
 
#create resized bitmap
$newWidth = [int] ($bmpOriginal.Width*$ratio)
$newHeight = [int] ($bmpOriginal.Height*$ratio)
$bmpResized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
$graph = [System.Drawing.Graphics]::FromImage($bmpResized)
 
$graph.Clear([System.Drawing.Color]::White)
$graph.DrawImage($bmpOriginal,0,0 , $newWidth, $newHeight)

if ( $newHeight -gt $canvasHeight )
{
    $addlvertoffset=(($newHeight-$canvasHeight)/2) 
    $textvertstart+=$addlvertoffset
}

if ( $newWidth -gt $canvasWidth )
{
    $addlhoroffset=(($newWidth-$canvasWidth)/2) 
    $texthorstart+=$addlhoroffset
}
 
#save to file
$bmpResized.Save($newImagePath,$myImageCodecInfo, $($encoderParams))
$bmpResized.Dispose()
$bmpOriginal.Dispose()



###############################


$img = [System.Drawing.Image]::FromFile($newImagePath)

#Create a bitmap
$bmp = new-object System.Drawing.Bitmap([int]($img.width)),([int]($img.height))
					
#Intialize Graphics
$gImg = [System.Drawing.Graphics]::FromImage($bmp)
$gImg.SmoothingMode = "AntiAlias"		
$color = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
$font = new-object System.Drawing.Font("Tahoma",30,[Drawing.FontStyle]'Bold' )
					
#Set up the brush for drawing image/watermark string
$myBrush = new-object Drawing.SolidBrush $color
$rect = New-Object Drawing.Rectangle 0,0,$img.Width,$img.Height
#End Brush

$gUnit = [Drawing.GraphicsUnit]::Pixel
$gImg.DrawImage($img,$rect,0,0,$img.Width,$img.Height,$gUnit)



# Computer Name color and font
$color = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
$font = new-object System.Drawing.Font("Tahoma",28,[Drawing.FontStyle]'Bold' )
$myBrush = new-object Drawing.SolidBrush $color
$gImg.DrawString($($env:COMPUTERNAME),$font,$myBrush,$texthorstart,$textvertstart+0)

# other color and font
$font = new-object System.Drawing.Font("Tahoma",10,[Drawing.FontStyle]'Bold' )
$color = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
$myBrush = new-object Drawing.SolidBrush $color

#Uncomment to add IP Address
$ipaddr = (get-netipaddress -AddressFamily IPv4 -PrefixOrigin Dhcp | % IPAddress)
$gImg.DrawString("IP Address: " + $ipaddr,$font,$myBrush,$texthorstart+5,$textvertstart+60)

# OS Friendly Name
# We retrieved $osCaption earlier
$gImg.DrawString($osCaption,$font,$myBrush,$texthorstart+5,$textvertstart+100)

#Debug code to display only on certain PCs, based on name. Adjust the vertical start offset as needed.
#if ( $env:COMPUTERNAME.ToUpper().Contains("PATTERN") )
#{
#    $gImg.DrawString("DW: " + $displaywidth + " DH: " + $displayheight + " CW: " + $canvasWidth + " CH: " + $canvasHeight + " HO: " + $texthorstart,$font,$myBrush,$texthorstart+5,$textvertstart+160)
#}


$bmp.save($defaultImagePath,[System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmp.Dispose()
$img.Dispose()

Remove-Item $newImagePath -Force
