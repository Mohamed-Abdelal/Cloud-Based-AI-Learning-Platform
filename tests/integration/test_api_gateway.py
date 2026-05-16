"""
Integration tests for API Gateway service
"""
import pytest
import requests
from unittest.mock import patch, MagicMock


@pytest.fixture
def api_url():
    return "http://localhost:8080"


@pytest.fixture
def mock_database():
    """Mock database connection"""
    with patch('psycopg2.connect') as mock_connect:
        mock_conn = MagicMock()
        mock_connect.return_value = mock_conn
        yield mock_conn


class TestAPIGatewayIntegration:
    """Integration tests for API Gateway"""

    def test_health_check(self, api_url):
        """Test health check endpoint"""
        response = requests.get(f"{api_url}/health", timeout=5)
        assert response.status_code == 200
        assert response.json()['status'] == 'healthy'

    def test_tts_service_integration(self, api_url, mock_database):
        """Test TTS service integration"""
        payload = {
            'text': 'Hello World',
            'voice': 'en-US',
            'format': 'mp3'
        }
        
        response = requests.post(
            f"{api_url}/api/v1/tts/synthesize",
            json=payload,
            timeout=10
        )
        
        assert response.status_code == 200
        assert 'audio_url' in response.json()

    def test_chat_service_integration(self, api_url, mock_database):
        """Test Chat service integration"""
        payload = {
            'message': 'What is cloud computing?',
            'conversation_id': 'test-conv-123'
        }
        
        response = requests.post(
            f"{api_url}/api/v1/chat/message",
            json=payload,
            timeout=10
        )
        
        assert response.status_code == 200
        assert 'response' in response.json()
        assert 'message_id' in response.json()

    def test_error_handling(self, api_url):
        """Test error handling"""
        # Missing required field
        response = requests.post(
            f"{api_url}/api/v1/tts/synthesize",
            json={},
            timeout=5
        )
        
        assert response.status_code == 400
        assert 'error' in response.json()

    def test_authentication(self, api_url):
        """Test authentication mechanism"""
        # Request without API key
        response = requests.get(
            f"{api_url}/api/v1/secure/data",
            timeout=5
        )
        
        assert response.status_code == 401

    def test_rate_limiting(self, api_url):
        """Test rate limiting"""
        # Send multiple requests rapidly
        for i in range(150):
            response = requests.get(
                f"{api_url}/health",
                timeout=5
            )
            
            if i < 100:
                assert response.status_code == 200
            else:
                # Should be rate limited after 100 requests
                assert response.status_code in [429, 200]


class TestServiceDiscovery:
    """Test service discovery and inter-service communication"""

    def test_service_registry(self, api_url):
        """Test service registry endpoint"""
        response = requests.get(
            f"{api_url}/api/v1/services",
            timeout=5
        )
        
        assert response.status_code == 200
        services = response.json()
        assert any(s['name'] == 'tts-service' for s in services)
        assert any(s['name'] == 'chat-service' for s in services)
