# PowerShell script to upload test data to Firebase using REST API
Write-Host "Starting Firebase test data upload..." -ForegroundColor Green

# Firebase project URL
$baseUrl = "https://firestore.googleapis.com/v1/projects/everycourse-e7654/databases/(default)/documents"

# Regular user data
Write-Host "Adding regular users..." -ForegroundColor Cyan

$userData1 = @{
    fields = @{
        email = @{ stringValue = "user1@gmail.com" }
        displayName = @{ stringValue = "김철수" }
        age = @{ integerValue = "25" }
        gender = @{ stringValue = "male" }
        isStudent = @{ booleanValue = $false }
    }
}

try {
    $json1 = $userData1 | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/users?documentId=user1" -Method Post -Body $json1 -ContentType "application/json"
    Write-Host "User1 added successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error adding user1: $($_.Exception.Message)" -ForegroundColor Red
}

# Unverified student user
Write-Host "Adding unverified student user..." -ForegroundColor Cyan

$studentData = @{
    fields = @{
        email = @{ stringValue = "student@university.ac.kr" }
        displayName = @{ stringValue = "이대학" }
        age = @{ integerValue = "21" }
        gender = @{ stringValue = "female" }
        isStudent = @{ booleanValue = $false }
        emailVerified = @{ booleanValue = $false }
        studentVerificationStatus = @{ stringValue = "none" }
    }
}

try {
    $studentJson = $studentData | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/users?documentId=user-student" -Method Post -Body $studentJson -ContentType "application/json"
    Write-Host "Student user added successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error adding student: $($_.Exception.Message)" -ForegroundColor Red
}

# Verified student user
Write-Host "Adding verified student user..." -ForegroundColor Cyan

$verifiedStudentData = @{
    fields = @{
        email = @{ stringValue = "verified@snu.ac.kr" }
        displayName = @{ stringValue = "김서울" }
        age = @{ integerValue = "22" }
        gender = @{ stringValue = "male" }
        isStudent = @{ booleanValue = $true }
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
    Write-Host "Error adding verified student: $($_.Exception.Message)" -ForegroundColor Red
}

# Course data (created by verified student)
Write-Host "Adding course data..." -ForegroundColor Cyan

$courseData = @{
    fields = @{
        title = @{ stringValue = "대학생 연애 기초" }
        instructor = @{ stringValue = "김서울" }
        description = @{ stringValue = "대학생을 위한 건전한 연애 가이드" }
        category = @{ stringValue = "연애" }
        createdBy = @{ stringValue = "user-verified-student" }
        isVerifiedInstructor = @{ booleanValue = $true }
        showStudentBadge = @{ booleanValue = $true }
        duration = @{ stringValue = "2주" }
        difficulty = @{ stringValue = "beginner" }
    }
}

try {
    $courseJson = $courseData | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/courses?documentId=course-student" -Method Post -Body $courseJson -ContentType "application/json"
    Write-Host "Course added successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error adding course: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Upload completed!" -ForegroundColor Green
Write-Host "Test data uploaded with simplified student verification structure:" -ForegroundColor Yellow
Write-Host "- user1: Regular user (isStudent=false)" -ForegroundColor White
Write-Host "- user-student: Unverified student (isStudent=false)" -ForegroundColor White  
Write-Host "- user-verified-student: Verified student (isStudent=true)" -ForegroundColor White
Write-Host "- course-student: Course with student badge enabled" -ForegroundColor White
