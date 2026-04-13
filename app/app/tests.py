"""
Sample Tests for the app.

"""

from django.test import SimpleTestCase
from app import calc

class CalcTests(SimpleTestCase):
    """Tests for the calc module."""
    def test_add_numbers(self):
        """Test adding two numbers together."""
        result = calc.add(5, 3)
        self.assertEqual(result, 8)

    def test_subtract_numbers(self):
        """Test subtracting two numbers."""
        result = calc.subtract(5, 3)
        self.assertEqual(result, 2)