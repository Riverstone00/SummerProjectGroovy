# Simple PowerShell script to upload test data to Firestore

$projectId = "everycourse-911af"
$baseUrl = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents"

Write-Host "Starting Firebase data upload..." -ForegroundColor Green

# User data
Write-Host "Adding user data..." -ForegroundColor Cyan

$userData = @{
    fields = @{
        email = @{ stringValue = "test1@example.com" }
        displayName = @{ stringValue = "김철수" }
        age = @{ integerValue = "25" }
        gender = @{ stringValue = "male" }
        isStudent = @{ booleanValue = $false }
    }
}

try {
    $userJson = $userData | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/users?documentId=user-001" -Method Post -Body $userJson -ContentType "application/json"
    Write-Host "User added successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Student user data (not verified yet)
Write-Host "Adding unverified student user..." -ForegroundColor Cyan

$studentData = @{
    fields = @{
        email = @{ stringValue = "student@university.ac.kr" }
        displayName = @{ stringValue = "이대학" }
        age = @{ integerValue = "21" }
        gender = @{ stringValue = "female" }
        isStudent = @{ booleanValue = $false }  # 아직 인증 안됨
        emailVerified = @{ booleanValue = $false }
        studentVerificationStatus = @{ stringValue = "none" }
    }
}

try {
    $studentJson = $studentData | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/users?documentId=user-student" -Method Post -Body $studentJson -ContentType "application/json"
    Write-Host "Student user added successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Verified student user (already verified)
Write-Host "Adding verified student user..." -ForegroundColor Cyan

$verifiedStudentData = @{
    fields = @{
        email = @{ stringValue = "verified@snu.ac.kr" }
        displayName = @{ stringValue = "김서울" }
        age = @{ integerValue = "22" }
        gender = @{ stringValue = "male" }
        isStudent = @{ booleanValue = $true }  # 인증 완료!
        emailVerified = @{ booleanValue = $true }
        studentVerificationStatus = @{ stringValue = "verified" }
        universityEmail = @{ stringValue = "verified@snu.ac.kr" }
    }
}

try {
    $verifiedJson = $verifiedStudentData | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/users?documentId=user-verified-student" -Method Post -Body $verifiedJson -ContentType "application/json"
    Write-Host "Verified student user added successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Course data
Write-Host "Adding course data..." -ForegroundColor Cyan

$courseData = @{
    fields = @{
        title = @{ stringValue = "Gangnam Romantic Date Course" }
        hashtags = @{
            arrayValue = @{
                values = @(
                    @{ stringValue = "#gangnam" },
                    @{ stringValue = "#romantic" },
                    @{ stringValue = "#dinner" }
                )
            }
        }
        location = @{ stringValue = "Gangnam" }
        category = @{ stringValue = "date" }
        placeId = @{ stringValue = "place-001" }
    }
}

try {
    $courseJson = $courseData | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/courses?documentId=test-course-hashtag" -Method Post -Body $courseJson -ContentType "application/json"
    Write-Host "Course added successfully!" -ForegroundColor Green
    Write-Host "Firebase Functions will be triggered automatically!" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Upload completed!" -ForegroundColor Green
