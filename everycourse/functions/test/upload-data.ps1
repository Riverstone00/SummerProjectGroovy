# PowerShell 스크립트로 Firebase REST API 호출

$projectId = "everycourse-911af"
$baseUrl = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents"

Write-Host "🚀 Firebase REST API로 데이터 업로드 시작..." -ForegroundColor Green

# Firebase 토큰 가져오기 (Google 로그인 필요)
try {
    $token = (gcloud auth print-access-token)
} catch {
    Write-Host "❌ Google Cloud SDK가 설치되어 있지 않습니다." -ForegroundColor Red
    Write-Host "대신 Firebase 프로젝트 키를 사용합니다." -ForegroundColor Yellow
    
    # API 키 사용 방식으로 변경
    $apiKey = "AIzaSyC_your_api_key_here"  # Firebase 프로젝트 설정에서 가져와야 함
    $baseUrl = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents"
}

# 사용자 데이터 추가
Write-Host "👥 사용자 데이터 추가 중..." -ForegroundColor Cyan

$userData = @{
    fields = @{
        email = @{ stringValue = "test1@example.com" }
        displayName = @{ stringValue = "김철수" }
        age = @{ integerValue = "25" }
        gender = @{ stringValue = "male" }
        interests = @{
            arrayValue = @{
                values = @(
                    @{ stringValue = "데이트" },
                    @{ stringValue = "카페" },
                    @{ stringValue = "영화" }
                )
            }
        }
    }
}

$userJson = $userData | ConvertTo-Json -Depth 10
$userResponse = Invoke-RestMethod -Uri "$baseUrl/users?documentId=user-001" -Method Post -Body $userJson -ContentType "application/json"

Write-Host "✅ 사용자 user-001 추가됨" -ForegroundColor Green

# 코스 데이터 추가
Write-Host "📚 코스 데이터 추가 중..." -ForegroundColor Cyan

$courseData = @{
    fields = @{
        title = @{ stringValue = "강남 로맨틱 데이트 코스" }
        hashtags = @{
            arrayValue = @{
                values = @(
                    @{ stringValue = "#강남데이트" },
                    @{ stringValue = "#로맨틱" },
                    @{ stringValue = "#저녁식사" },
                    @{ stringValue = "#카페" },
                    @{ stringValue = "#야경" }
                )
            }
        }
        location = @{ stringValue = "강남구" }
        category = @{ stringValue = "데이트" }
        placeId = @{ stringValue = "place-001" }
        description = @{ stringValue = "강남에서 즐기는 로맨틱한 저녁 데이트 코스" }
    }
}

$courseJson = $courseData | ConvertTo-Json -Depth 10
$courseResponse = Invoke-RestMethod -Uri "$baseUrl/courses?documentId=test-course-hashtag" -Method Post -Body $courseJson -ContentType "application/json"

Write-Host "✅ 코스 test-course-hashtag 추가됨" -ForegroundColor Green
Write-Host "🎉 데이터 업로드 완료! Firebase Functions가 자동으로 트리거됩니다." -ForegroundColor Green
