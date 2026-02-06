param ($script)

$data = [Convert]::FromBase64String($script)
$path = [System.IO.Path]::GetTempPath() + "Script.ps1"
Set-Content $path $data -Encoding Byte

$signature = Get-AuthenticodeSignature $path

Remove-Item $path -Force

function Validate-Authenticity($signature)
{
    $certificate = $signature.SignerCertificate

    if ($certificate -eq $null) { return $false }

    $chain = [System.Security.Cryptography.X509Certificates.X509Chain]::new()
    $chain.ChainPolicy.VerificationFlags = 'AllowUnknownCertificateAuthority'

    # Invalid chain
    if (!$chain.Build($certificate)) { return $false }

    # No chain
    if ($chain.ChainElements.Count -lt 1) { return $false }

    $root = $chain.ChainElements[$chain.ChainElements.Count - 1]

    # Invalid root issue
    if ($root.ChainElementStatus.Status -ne 'UntrustedRoot') { return $false }
    
    # Unexpected roo
    if ($root.Certificate.Thumbprint -ne 'E58E29AA5715F4A7D1AE05F8845F8FCF198457D7') { return $false }

    return $true
}

function Validate-Integrity($signature)
{
    return $signature.Status -ne 'HashMismatch'
}

if (!(Validate-Authenticity $signature)) { exit 1 }

if (!(Validate-Integrity $signature)) { exit 2 }
