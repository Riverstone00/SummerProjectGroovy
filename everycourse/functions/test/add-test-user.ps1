# PowerShell script to add a test user directly to Firebase
Write-Host "Adding test user to Firebase..." -ForegroundColor Green

# Firebase project URL
$baseUrl = "https://firestore.googleapis.com/v1/projects/everycourse-911af/databases/(default)/documents"

# Get access token
Write-Host "Getting Firebase access token..." -ForegroundColor Yellow
$tokenResult = firebase auth:print-access-token
$accessToken = $tokenResult

Write-Host "Access token obtained" -ForegroundColor Green

# Test user data
$testUser = @{
    fields = @{
        email = @{ stringValue = "testuser@gmail.com" }
        displayName = @{ stringValue = "Test User" }
        age = @{ integerValue = "22" }
        gender = @{ stringValue = "male" }
    }
}

try {
    $json = $testUser | ConvertTo-Json -Depth 10
    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-RestMethod -Uri "$baseUrl/users?documentId=test-user-1" -Method Post -Body $json -Headers $headers
    Write-Host "Test user added successfully!" -ForegroundColor Green
    Write-Host "This should trigger the createUserProfile function automatically" -ForegroundColor Yellow
    
} catch {
    Write-Host "Error adding user: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host "Done!" -ForegroundColor Green
