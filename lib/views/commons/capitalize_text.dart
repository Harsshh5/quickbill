String capitalizeEachWord(String input) {
  if (input.trim().isEmpty) return '';

  return input
      .split(' ')
      .map((word) =>
  word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
      .join(' ');
}
