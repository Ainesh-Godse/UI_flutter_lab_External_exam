import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  // Fetch a random quote from the API
  Future<Map<String, String>> fetchRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/quotes/random'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Return a formatted map with the quote and author
        return {
          'text': data['quote'] ?? 'No quote found.',
          'author': data['author'] ?? 'Unknown',
        };
      } else {
        throw Exception('Failed to load quote (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Re-throw the error so the UI can catch it and show an error state
      throw Exception('Network error: Could not fetch quote.');
    }
  }
}