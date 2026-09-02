"""Utility helpers for mega-repo."""

def calculate_sum(numbers: list[int]) -> int:
    """Calculate sum of a list of numbers."""
    return sum(numbers)

def format_filename(name: str, ext: str = "py") -> str:
    """Format a filename with extension."""
    return f"{name}.{ext}"
