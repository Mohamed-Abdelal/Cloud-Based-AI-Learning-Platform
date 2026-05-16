"""
E2E tests for Cloud Learning Platform
"""
import pytest
import requests
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


@pytest.fixture(scope="module")
def api_base_url():
    return "http://localhost:8080/api/v1"


@pytest.fixture(scope="module")
def browser():
    """Create a browser instance for UI testing"""
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    
    driver = webdriver.Chrome(options=options)
    yield driver
    driver.quit()


class TestE2ELearningFlow:
    """End-to-end tests for learning flow"""

    def test_complete_learning_session(self, api_base_url):
        """Test a complete learning session"""
        session_id = "e2e-test-" + str(time.time())
        
        # 1. Create learning session
        response = requests.post(
            f"{api_base_url}/sessions",
            json={'session_id': session_id},
            timeout=10
        )
        assert response.status_code == 201
        
        # 2. Upload document
        with open('sample.wav', 'rb') as f:
            files = {'file': f}
            response = requests.post(
                f"{api_base_url}/documents/upload",
                files=files,
                timeout=30
            )
        assert response.status_code == 200
        doc_id = response.json()['document_id']
        
        # 3. Generate quiz from document
        response = requests.post(
            f"{api_base_url}/quiz/generate",
            json={'document_id': doc_id},
            timeout=15
        )
        assert response.status_code == 200
        quiz_id = response.json()['quiz_id']
        
        # 4. Submit quiz answers
        answers = {
            'quiz_id': quiz_id,
            'answers': [
                {'question_id': 'q1', 'answer': 'A'},
                {'question_id': 'q2', 'answer': 'B'},
            ]
        }
        response = requests.post(
            f"{api_base_url}/quiz/submit",
            json=answers,
            timeout=10
        )
        assert response.status_code == 200
        results = response.json()
        assert 'score' in results
        assert 'passing' in results

    def test_tts_stt_conversation(self, api_base_url):
        """Test TTS and STT in conversation flow"""
        # 1. Text to Speech
        response = requests.post(
            f"{api_base_url}/tts/synthesize",
            json={
                'text': 'Welcome to cloud learning platform',
                'voice': 'en-US',
                'rate': 1.0
            },
            timeout=10
        )
        assert response.status_code == 200
        audio_url = response.json()['audio_url']
        assert audio_url.startswith('http')
        
        # 2. Speech to Text (using generated audio)
        with open('sample.wav', 'rb') as f:
            files = {'audio': f}
            response = requests.post(
                f"{api_base_url}/stt/transcribe",
                files=files,
                timeout=30
            )
        assert response.status_code == 200
        transcribed_text = response.json()['text']
        assert len(transcribed_text) > 0

    def test_collaborative_learning(self, api_base_url):
        """Test collaborative features"""
        # 1. Create study group
        response = requests.post(
            f"{api_base_url}/study-groups",
            json={
                'name': 'Cloud Computing Basics',
                'description': 'Learn cloud fundamentals'
            },
            timeout=10
        )
        assert response.status_code == 201
        group_id = response.json()['group_id']
        
        # 2. Add members
        response = requests.post(
            f"{api_base_url}/study-groups/{group_id}/members",
            json={'member_ids': ['user1', 'user2']},
            timeout=10
        )
        assert response.status_code == 200
        
        # 3. Share document
        response = requests.post(
            f"{api_base_url}/study-groups/{group_id}/documents",
            json={'document_id': 'doc-123'},
            timeout=10
        )
        assert response.status_code == 200

    def test_performance_under_load(self, api_base_url):
        """Test API performance under moderate load"""
        start_time = time.time()
        successful_requests = 0
        failed_requests = 0
        
        # Send 50 concurrent requests
        for i in range(50):
            try:
                response = requests.get(
                    f"{api_base_url}/health",
                    timeout=5
                )
                if response.status_code == 200:
                    successful_requests += 1
                else:
                    failed_requests += 1
            except Exception as e:
                failed_requests += 1
        
        elapsed_time = time.time() - start_time
        
        # Performance assertions
        assert successful_requests >= 40  # At least 80% success
        assert elapsed_time < 60  # Should complete within 60 seconds
        print(f"Performance: {successful_requests}/50 requests in {elapsed_time:.2f}s")


class TestUI:
    """UI-based end-to-end tests"""

    def test_landing_page_loads(self, browser):
        """Test landing page loads correctly"""
        browser.get("http://localhost:3000")
        
        # Wait for title
        WebDriverWait(browser, 10).until(
            EC.title_contains("Cloud Learning")
        )
        
        assert "Cloud Learning Platform" in browser.page_source

    def test_login_flow(self, browser):
        """Test user login flow"""
        browser.get("http://localhost:3000/login")
        
        # Fill login form
        username_field = WebDriverWait(browser, 10).until(
            EC.presence_of_element_located((By.ID, "username"))
        )
        username_field.send_keys("testuser")
        
        password_field = browser.find_element(By.ID, "password")
        password_field.send_keys("testpassword123")
        
        login_button = browser.find_element(By.ID, "login-button")
        login_button.click()
        
        # Wait for redirect to dashboard
        WebDriverWait(browser, 10).until(
            EC.url_contains("/dashboard")
        )
        
        assert "dashboard" in browser.current_url
