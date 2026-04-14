"""
Test for the django admin modifications.

"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from django.urls import reverse
from django.test import Client

# from rest_framework import status

User = get_user_model()


class AdminSiteTests(TestCase):
    """Tests for the django admin modifications."""

    def setUp(self):
        """Create user and client."""
        self.client = Client()
        self.admin_user = User.objects.create_superuser(email="admin@example.com", password="adminpass123")  # type: ignore
        self.client.force_login(self.admin_user)
        self.user = User.objects.create_user(
            email="user@example.com", password="userpass123", first_name="Test", last_name="User"
        )  # type: ignore

    def test_users_listed(self):
        """Test that users are listed on user page."""
        url = reverse("admin:core_user_changelist")
        result = self.client.get(url)

        self.assertContains(result, self.user.email)
        self.assertContains(result, self.user.first_name)
        self.assertContains(result, self.user.last_name)

    def test_edit_user_page(self):
        """Test that the user edit page works."""
        url = reverse("admin:core_user_change", args=[self.user.id])
        result = self.client.get(url)

        self.assertEqual(result.status_code, 200)
