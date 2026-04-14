"""
Test cases for models.
"""

from django.test import TestCase
from django.contrib.auth import get_user_model

User = get_user_model()


class ModelTests(TestCase):
    """Test models."""

    def test_create_user_with_email_successful(self):
        """Test creating a new user with an email is successful."""
        email = "test@example.com"
        password = "testpass123"
        user = User.objects.create_user(email=email, password=password)  # type: ignore
        self.assertEqual(user.email, email)
        self.assertTrue(user.check_password(password))

    def test_new_user_email_normalised(self):
        """Test the email for a new user is normalised."""
        sample_emails = [
            ["test1@EXAMPLE.COM", "test1@example.com"],
            ["TEST2@EXAMPLE.COM", "TEST2@example.com"],
            ["Test3@EXAMPLE.COM", "Test3@example.com"],
            ["test4@example.COM", "test4@example.com"],
            # Mixed casing
            ["JoHn.DoE@GMAIL.COM", "JoHn.DoE@gmail.com"],
            ["ADMIN@Yahoo.CoM", "ADMIN@yahoo.com"],
            # Subdomains
            ["user@MAIL.EXAMPLE.COM", "user@mail.example.com"],
            ["support@Sub.Domain.ORG", "support@sub.domain.org"],
            # Plus aliases
            ["person+work@EXAMPLE.COM", "person+work@example.com"],
            ["TEST+FILTER@GMAIL.COM", "TEST+FILTER@gmail.com"],
            # Numbers / underscores / hyphens
            ["user_123@EXAMPLE.COM", "user_123@example.com"],
            ["first-last@DOMAIN.NET", "first-last@domain.net"],
            # Long TLDs / newer domains
            ["name@COMPANY.TECH", "name@company.tech"],
            ["hello@STARTUP.IO", "hello@startup.io"],
            # Country TLDs
            ["contact@BUSINESS.CO.UK", "contact@business.co.uk"],
            ["sales@SHOP.COM.AU", "sales@shop.com.au"],
        ]
        for email, expected in sample_emails:
            user = User.objects.create_user(email=email, password="sample123")  # type: ignore
            self.assertEqual(user.email, expected)

    def test_new_user_without_email_raises_error(self):
        """Test creating a user without an email raises a ValueError."""
        with self.assertRaises(ValueError):
            User.objects.create_user(email="", password="test123")  # type: ignore

    def test_create_superuser(self):
        """Test creating a new superuser."""
        email = "admin@example.com"
        password = "testpass123"
        user = User.objects.create_superuser(email=email, password=password)  # type: ignore
        self.assertEqual(user.email, email)
        self.assertTrue(user.check_password(password))
        self.assertTrue(user.is_staff)
        self.assertTrue(user.is_superuser)
