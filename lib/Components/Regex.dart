bool regex({required String pattern, required String input}) {
  return (input.isNotEmpty && input.trim() != "") ? new RegExp(pattern).hasMatch(input) : false;
}
