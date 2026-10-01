# Run with Windows PowerShell 5.1 on .NET Framework 4.8.
# Generates a different random salt for each account. Paste results into the seed.
param([int]$Count = 12)

$random = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try {
    for ($i = 0; $i -lt $Count; $i++) {
        $salt = New-Object byte[] 16
        $random.GetBytes($salt)
        $derive = [System.Security.Cryptography.Rfc2898DeriveBytes]::new(
            'Password123', $salt, 100000, [System.Security.Cryptography.HashAlgorithmName]::SHA256)
        try {
            $hash = $derive.GetBytes(32)
            'PBKDF2$100000$' + [Convert]::ToBase64String($salt) + '$' + [Convert]::ToBase64String($hash)
        }
        finally { $derive.Dispose() }
    }
}
finally { $random.Dispose() }
