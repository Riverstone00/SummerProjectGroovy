const https = require('https');
const fs = require('fs');

// Firebase REST API를 사용해서 데이터 추가
const projectId = 'everycourse-911af';
const baseUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/`;

// Firebase 인증 토큰 가져오기 (Firebase CLI 토큰 사용)
async function getAccessToken() {
  return new Promise((resolve, reject) => {
    const { exec } = require('child_process');
    exec('firebase auth:print-access-token', (error, stdout, stderr) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(stdout.trim());
    });
  });
}

// Firestore에 문서 추가
async function addDocument(collection, docId, data) {
  const token = await getAccessToken();
  
  const postData = JSON.stringify({
    fields: convertToFirestoreFormat(data)
  });

  const options = {
    hostname: 'firestore.googleapis.com',
    port: 443,
    path: `/v1/projects/${projectId}/databases/(default)/documents/${collection}?documentId=${docId}`,
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          console.log(`✅ ${collection}/${docId} 추가됨`);
          resolve(JSON.parse(data));
        } else {
          console.error(`❌ ${collection}/${docId} 추가 실패:`, data);
          reject(new Error(data));
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.write(postData);
    req.end();
  });
}

// JavaScript 객체를 Firestore 형식으로 변환
function convertToFirestoreFormat(obj) {
  const result = {};
  
  for (const [key, value] of Object.entries(obj)) {
    if (typeof value === 'string') {
      result[key] = { stringValue: value };
    } else if (typeof value === 'number') {
      result[key] = { integerValue: value.toString() };
    } else if (Array.isArray(value)) {
      result[key] = {
        arrayValue: {
          values: value.map(item => ({ stringValue: item }))
        }
      };
    } else if (value && typeof value === 'object' && value.createdAt) {
      // 타임스탬프 처리는 생략하고 현재 시간으로 설정
      result[key] = { timestampValue: new Date().toISOString() };
    }
  }
  
  return result;
}

// 메인 함수
async function main() {
  console.log('🚀 Firebase REST API로 데이터 업로드 시작...\n');

  try {
    // 사용자 데이터 추가
    console.log('👥 사용자 데이터 추가 중...');
    const usersData = JSON.parse(fs.readFileSync('./users-data.json', 'utf8'));
    
    for (const [userId, userData] of Object.entries(usersData.users)) {
      const cleanUserData = { ...userData };
      delete cleanUserData.createdAt; // 타임스탬프는 서버에서 처리
      await addDocument('users', userId, cleanUserData);
    }

    // 코스 데이터 추가
    console.log('\n📚 코스 데이터 추가 중...');
    const coursesData = JSON.parse(fs.readFileSync('./test-data.json', 'utf8'));
    
    for (const [courseId, courseData] of Object.entries(coursesData.courses)) {
      const cleanCourseData = { ...courseData };
      delete cleanCourseData.createdAt;
      await addDocument('courses', courseId, cleanCourseData);
    }

    console.log('\n🎉 모든 데이터 업로드 완료!');
    console.log('Firebase Functions가 자동으로 트리거됩니다.');
    
  } catch (error) {
    console.error('❌ 업로드 실패:', error.message);
  }
}

main();
